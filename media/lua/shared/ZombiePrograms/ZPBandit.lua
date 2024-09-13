ZombiePrograms = ZombiePrograms or {}



local function IsWater(square)
    local objects = square:getObjects()
    for i=0, objects:size()-1 do
        local object = objects:get(i)
        local properties = object:getProperties()
        if properties then
            local water = properties:Is(IsoFlagType.water)
            if water then
                return true
            end
        end
    end
    return false
end

ZombiePrograms.Bandit = {}
ZombiePrograms.Bandit.Stages = {}

ZombiePrograms.Bandit.Init = function(bandit)
end

ZombiePrograms.Bandit.GetCapabilities = function()
    -- capabilities are program decided
    local capabilities = {}
    capabilities.melee = true
    capabilities.shoot = true
    capabilities.smashWindow = true
    capabilities.openDoor = true
    capabilities.breakDoor = true
    capabilities.breakObjects = true
    capabilities.unbarricade = true
    capabilities.disableGenerators = true
    capabilities.sabotageCars = true
    return capabilities
end

ZombiePrograms.Bandit.Prepare = function(bandit)
    local tasks = {}
    local world = getWorld()
    local cell = getCell()
    local cm = world:getClimateManager()
    local dls = cm:getDayLightStrength()

    Bandit.ForceStationary(bandit, false)
    Bandit.SetWeapons(bandit, Bandit.GetWeapons(bandit))
    
    -- weapons are spawn, not program decided
    local primary = Bandit.GetBestWeapon(bandit)

    local secondary
    if SandboxVars.Bandits.General_CarryTorches and dls < 0.3 then
        secondary = "Base.HandTorch"
    end

    local task = {action="Equip", itemPrimary=primary, itemSecondary=secondary}
    table.insert(tasks, task)

    return {status=true, next="Follow", tasks=tasks}
end

ZombiePrograms.Bandit.Follow = function(bandit)
    local tasks = {}
    local weapons = Bandit.GetWeapons(bandit)

    -- update walk type
    local world = getWorld()
    local cell = getCell()
    local cm = world:getClimateManager()
    local dls = cm:getDayLightStrength()
    local weapons = Bandit.GetWeapons(bandit)
    local outOfAmmo = Bandit.IsOutOfAmmo(bandit)
    local hands = bandit:getVariableString("BanditPrimaryType")
 
    local walkType = "Run"
    local endurance = -0.06
    local secondary
    if dls < 0.3 then
        if SandboxVars.Bandits.General_SneakAtNight then
            walkType = "SneakWalk"
            endurance = 0
        end
    end

    if bandit:isInARoom() then
        if outOfAmmo then
            walkType = "Run"
        else
            walkType = "WalkAim"
        end
    end

    local health = bandit:getHealth()
    if health < 0.5 then
        walkType = "Limp"
        endurance = 0
    end 
 
    local handweapon = bandit:getVariableString("BanditWeapon") 
    
    if SandboxVars.Bandits.General_RunAway and health < 0.7 then
        return {status=true, next="Escape", tasks=tasks}
    end

    if SandboxVars.Bandits.General_GeneratorCutoff or SandboxVars.Bandits.General_SabotageVehicles then 
        for z=0, 2 do
            for y=-12, 12 do
                for x=-12, 12 do
                    local square = cell:getGridSquare(bandit:getX() + x, bandit:getY() + y, z)
                    if square then

                        if SandboxVars.Bandits.General_GeneratorCutoff then
                            local gen = square:getGenerator()
                            if gen and gen:isActivated() then
                                table.insert(tasks, BanditUtils.GetMoveTask(endurance, bandit:getX()+x, bandit:getY()+y, z, walkType, 12))
                                return {status=true, next="TurnOffGenerator", tasks=tasks}
                            end
                        end

                        if SandboxVars.Bandits.General_SabotageVehicles then
                            local vehicle = square:getVehicleContainer()
                            if vehicle and vehicle:isHotwired() and not vehicle:getDriver() then
                                local vx = square:getX()
                                local vy = square:getY()
                                local vz = square:getZ()
                                local test0 = vehicle:isHotwired()
                                local test1 = vehicle:isEngineRunning()
                                local vehiclePart = vehicle:getPartById("TireRearLeft")
                                local vehiclePartSquare = vehiclePart:getSquare()
                                local vpx = vehiclePartSquare:getX()
                                local vpy = vehiclePartSquare:getY()
                                local vpz = vehiclePartSquare:getZ()

                                table.insert(tasks, BanditUtils.GetMoveTask(endurance, vx, vy, vz, walkType, 12))
                                return {status=true, next="SabotageVehicle", tasks=tasks}
                            end
                        end
                    end
                end
            end
        end
    end

    local target = {}

    local closestZombie = BanditUtils.GetClosestZombieLocation(bandit)
    local closestBandit = BanditUtils.GetClosestEnemyBanditLocation(bandit)
    local closestPlayer = BanditUtils.GetClosestPlayerLocation(bandit, false)

    target = closestZombie
    if closestBandit.dist < closestZombie.dist then
        target = closestBandit
    end

    if Bandit.IsHostile(bandit) and closestPlayer.dist < closestBandit.dist then
        target = closestPlayer
    end

    if target.x and target.y and target.z then

        local targetSquare = cell:getGridSquare(target.x, target.y, target.z)
        local banditSquare = bandit:getSquare()
        if targetSquare and banditSquare then
            local targetBuilding = targetSquare:getBuilding()
            local banditBuilding = banditSquare:getBuilding()
            local x = 100

            if targetBuilding and not banditBuilding then
                Bandit.Say(bandit, "INSIDE")
            end
            if not targetBuilding and banditBuilding then
                Bandit.Say(bandit, "OUTSIDE")
            end
            if targetBuilding and banditBuilding then
                if bandit:getZ() < target.z then
                    Bandit.Say(bandit, "UPSTAIRS")
                else
                    local room = targetSquare:getRoom()
                    if room then
                        local roomName = room:getName()
                        if roomName == "kitchen" then
                            Bandit.Say(bandit, "ROOM_KITCHEN")
                        end
                        if roomName == "bathroom" then
                            Bandit.Say(bandit, "ROOM_BATHROOM")
                        end
                    end
                end
            end
        end

        -- out of ammo, get close
        local minDist = 2
        if outOfAmmo then
            minDist = 0.5
        end

        if target.dist > minDist then

            -- detect water to build a bridge
            if SandboxVars.Bandits.General_BuildBridge then 
                local path = BanditUtils.Bresenham(math.floor(bandit:getX() + 0.5), math.floor(bandit:getY() + 0.5), math.floor(target.x + 0.5), math.floor(target.y + 0.5))
                local last = {}
                for _, coords in pairs(path) do
                    local square = cell:getGridSquare(coords.x, coords.y, 0)
                    if square then
                        if IsWater(square) then
                            -- local as = AdjacentFreeTileFinder.Find(square, bandit)
                            if last.x and last.y then
                                -- print ("go build bridge from x: " .. last.x .. " y: " .. last.y .. " to x:" .. coords.x .. " y:" .. coords.y)
                                table.insert(tasks, BanditUtils.GetMoveTask(endurance, last.x, last.y, 0, walkType, target.dist))

                                if math.floor(bandit:getX()) == last.x and math.floor(bandit:getY()) == last.y then
                                    -- in position
                                    return {status=true, next="BuildBridge", tasks=tasks}
                                else
                                    --not there yet
                                    return {status=true, next="Follow", tasks=tasks}
                                end
                            end
                        else
                            last = coords
                        end
                        
                    end
                end
            end

            -- must be deterministic, not random (same for all clients)
            local id = BanditUtils.GetCharacterID(bandit)

            local dx = 0
            local dy = 0
            local dxf = ((id % 10) - 5) / 10
            local dyf = ((id % 11) - 5) / 10


            table.insert(tasks, BanditUtils.GetMoveTask(endurance, target.x+dx+dxf, target.y+dy+dyf, target.z, walkType, target.dist))
        end
    else
        local task = {action="Time", anim="Shrug", time=200}
        table.insert(tasks, task)
    end

    return {status=true, next="Follow", tasks=tasks}
end

ZombiePrograms.Bandit.Escape = function(bandit)
    local tasks = {}
    local weapons = Bandit.GetWeapons(bandit)

    local health = bandit:getHealth()

    if health >= 1.0 then
        return {status=true, next="Follow", tasks=tasks}
    end

    if SandboxVars.Bandits.General_Surrender and health < 0.12 then
        bandit:setPrimaryHandItem(nil)
        if weapons.melee then
            local item = InventoryItemFactory.CreateItem(weapons.melee)
            if item then
                bandit:getSquare():AddWorldInventoryItem(item, ZombRandFloat(0.2, 0.8), ZombRandFloat(0.2, 0.8), 0)
                weapons.melee = nil
            end
        end
        if weapons.primary and weapons.primary.name then
            local item = InventoryItemFactory.CreateItem(weapons.primary.name)
            if item then
                bandit:getSquare():AddWorldInventoryItem(item, ZombRandFloat(0.2, 0.8), ZombRandFloat(0.2, 0.8), 0)
                weapons.primary = nil
            end
        end
        if weapons.secondary and weapons.secondary.name then
            local item = InventoryItemFactory.CreateItem(weapons.secondary.name)
            if item then
                bandit:getSquare():AddWorldInventoryItem(item, ZombRandFloat(0.2, 0.8), ZombRandFloat(0.2, 0.8), 0)
                weapons.secondary = nil
            end
        end
        Bandit.SetWeapons(bandit, weapons)
        return {status=true, next="Surrender", tasks=tasks}
    end

    local endurance = -0.06
    local walkType = "Run"
    if health < 0.4 then
        walkType = "Limp"
        endurance = 0
    end

    local handweapon = bandit:getVariableString("BanditWeapon")

    local closestPlayer = BanditUtils.GetClosestPlayerLocation(bandit)

    if closestPlayer.x and closestPlayer.y and closestPlayer.z then

        -- calculate random escape direction
        local deltaX = 100 + ZombRand(100)
        local deltaY = 100 + ZombRand(100)

        local rx = ZombRand(2)
        local ry = ZombRand(2)
        if rx == 1 then deltaX = -deltaX end
        if ry == 1 then deltaY = -deltaY end

        table.insert(tasks, BanditUtils.GetMoveTask(endurance, closestPlayer.x+deltaX, closestPlayer.y+deltaY, 0, walkType, 12))
    end
    return {status=true, next="Escape", tasks=tasks}
end

ZombiePrograms.Bandit.Surrender = function(bandit)
    local tasks = {}

    if ZombRand(2) == 0 then
        local task = {action="Time", anim="Surrender", time=40}
        table.insert(tasks, task)
    else
        local task = {action="Time", anim="Scramble", time=40}
        table.insert(tasks, task)
    end

    return {status=true, next="Surrender", tasks=tasks}
end

ZombiePrograms.Bandit.TurnOffGenerator = function(bandit)
    local tasks = {}

    local gen = bandit:getSquare():getGenerator()
    if gen and gen:isActivated() then
        local task = {action="Time", anim="LootLow", time=40}
        table.insert(tasks, task)
        local task = {action="Time", anim="LootLow", time=40}
        table.insert(tasks, task)
        
        gen:setActivated(false)
        bandit:getSquare():playSound("WorldEventElectricityShutdown")
    end

    return {status=true, next="Follow", tasks=tasks}
end

ZombiePrograms.Bandit.SabotageVehicle = function(bandit)
    local tasks = {}

    local carfound = false
    for y=-12, 12 do
        for x=-12, 12 do
            local square = getCell():getGridSquare(bandit:getX() + x, bandit:getY() + y, 0)
            if square then
                local vehicle = square:getVehicleContainer()
                if vehicle and vehicle:isHotwired() and not vehicle:getDriver() then
                    local vx = square:getX()
                    local vy = square:getY()
                    local vz = square:getZ()
                    
                    local uninstallPart
                    local uninstallPartList = {"TireRearLeft", "Battery", "TireFrontRight", "TireRearRight", "TireFrontLeft"}
                    for _, p in pairs(uninstallPartList) do
                        local vehiclePart = vehicle:getPartById(p)
                        if vehiclePart and vehiclePart:getInventoryItem() then
                            uninstallPart = vehiclePart
                            break
                        end
                    end

                    if uninstallPart then
                        carfound = true
                        local uninstallPartId = uninstallPart:getId()
                        local uninstallPartArea = uninstallPart:getArea()
                        local uninstallPartSquare = uninstallPart:getSquare()
                        local vpx = uninstallPartSquare:getX()
                        local vpy = uninstallPartSquare:getY()

                        local dist = vehicle:getAreaDist(uninstallPartArea, bandit)
                        local minDist = 3.1
                        if uninstallPartArea == "Engine" then minDist = 5.4 end
                        -- AdjacentFreeTileFinder.Find(source:getSquare(), bandit)
                        if dist > minDist then
                            task = {action="Move", vehiclePartArea=uninstallPartArea, time=50, x=vx, y=vy, z=0, walkType=walkType}
                            table.insert(tasks, task)
                        else
                            local task = {action="VehicleAction", subaction="Uninstall", id=uninstallPartId, area=uninstallPartArea, vx=vx, vy=vy, px=vpx, py=vpy, time=250}
                            table.insert(tasks, task)
                        end
                        break
                    else
                        vehicle:setHotwired(false)
                    end
                end
            end
            if carfound then break end
        end
        if carfound then break end
    end

    if carfound then
        return {status=true, next="SabotageVehicle", tasks=tasks}
    else
        return {status=true, next="Follow", tasks=tasks}
    end
end

ZombiePrograms.Bandit.BuildBridge = function(bandit)
    local tasks = {}

    for dx = -1, 1 do
        for dy = -1, 1 do
            local square = getCell():getGridSquare(bandit:getX() + dx, bandit:getY() + dy, bandit:getZ())
            if square then
                if IsWater(square) then
                    local task = {action="Equip", itemPrimary="Base.Hammer", itemSecondary=nil}
                    table.insert(tasks, task)
                
                    local task = {action="BuildFloor", anim="HammerLow", sound="Hammering", x=square:getX(), y=square:getY(), time=500}
                    table.insert(tasks, task)
                    return {status=true, next="BuildBridge", tasks=tasks}
                end
            end
        end
    end
    return {status=true, next="Follow", tasks=tasks}
end