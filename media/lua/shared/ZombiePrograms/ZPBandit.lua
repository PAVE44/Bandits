ZombiePrograms = ZombiePrograms or {}

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
    if health < 0.4 then
        walkType = "Limp"
        endurance = 0
    end 
 
    local handweapon = bandit:getVariableString("BanditWeapon") 
    
    if SandboxVars.Bandits.General_RunAway and health < 0.6 then
        return {status=true, next="Escape", tasks=tasks}
    end

    for z=0, 2 do
        for y=-12, 12 do
            for x=-12, 12 do
                local square = cell:getGridSquare(bandit:getX() + x, bandit:getY() + y, z)
                if square then
                    local gen = square:getGenerator()
                    if gen and gen:isActivated() then
                        
                        local gamemode = getWorld():getGameMode()
                        local task
                        if gamemode == "Multiplayer" then
                            task = {action="GoTo", time=50, x=bandit:getX() + x, y=bandit:getY() + y, z=z, walkType=walkType}
                        else
                            task = {action="Move", time=50, x=bandit:getX() + x, y=bandit:getY() + y, z=z, walkType=walkType}
                        end
                        table.insert(tasks, task)
                        return {status=true, next="TurnOffGenerator", tasks=tasks}
                    end

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
                        if gamemode == "Multiplayer" then
                            task = {action="GoTo", time=50, x=vx, y=vy, z=vz, walkType=walkType}
                        else
                            task = {action="Move", time=50, x=vx, y=vy, z=vz, walkType=walkType}
                        end
                        table.insert(tasks, task)
                        return {status=true, next="SabotageVehicle", tasks=tasks}
                    end
                end
            end
        end
    end

    local target = {}

    local closestZombie = {}
    closestZombie.x, closestZombie.y, closestZombie.z, closestZombie.dist, closestZombie.id = BanditUtils.GetClosestZombieLocation(bandit)

    local closestBandit = {}
    closestBandit.x, closestBandit.y, closestBandit.z, closestBandit.dist, closestBandit.id = BanditUtils.GetClosestEnemyBanditLocation(bandit)

    local closestPlayer = {}
    closestPlayer.x, closestPlayer.y, closestPlayer.z, closestPlayer.dist, closestPlayer.id = BanditUtils.GetClosestPlayerLocation(bandit, false)

    target = closestZombie
    if closestBandit.dist < closestZombie.dist then
        target = closestBandit
    end

    if closestPlayer.dist < closestBandit.dist then
        target = closestPlayer
    end

    if target.x and target.y and target.z then

        local player = getPlayer()
        local playerSquare = cell:getGridSquare(target.x, target.y, target.z)
        local banditSquare = bandit:getSquare()
        if playerSquare and banditSquare then
            local playerBuilding = playerSquare:getBuilding()
            local banditBuilding = banditSquare:getBuilding()
            local x = 100

            if  playerBuilding and not banditBuilding then
                Bandit.Say(bandit, "INSIDE")
            end
            if not playerBuilding and banditBuilding then
                Bandit.Say(bandit, "OUTSIDE")
            end
            if playerBuilding and banditBuilding then
                if bandit:getZ() < player:getZ() then
                    Bandit.Say(bandit, "UPSTAIRS")
                else
                    local room = playerSquare:getRoom()
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
            minDist = 1.51
        end

        if target.dist > minDist then

            -- if target.dist < 3 then walkType = "Walk" end

            -- must be deterministic, not random (same for all clients)
            local id = BanditUtils.GetCharacterID(bandit)

            local dx = (id % 4) - 2
            local dy = (id % 5) - 2.5
            local dxf = ((id % 10) - 5) / 10
            local dyf = ((id % 11) - 5) / 10

            -- Move and GoTo generally do the same thing with a different method
            -- GoTo uses one-time move order, provides better synchronization in multiplayer, not perfect on larger distance
            -- Move uses constant updatating, it a better algorithm but introduces desync in multiplayer
            local gamemode = getWorld():getGameMode()
            local task
            if gamemode == "Multiplayer" then
                if target.dist > 30 then
                    task = {action="Move", time=25, endurance=endurance, x=target.x+dx+dxf, y=target.y+dy+dyf, z=target.z, walkType=walkType}
                else
                    task = {action="GoTo", time=50, endurance=endurance, x=target.x+dx+dxf, y=target.y+dy+dyf, z=target.z, walkType=walkType}
                end
            else
                task = {action="Move", time=50, endurance=endurance, x=target.x - 1 + ZombRand(3) + ZombRandFloat(-0.5, 0.5), y=target.y - 1 + ZombRand(3) + ZombRandFloat(-0.5, 0.5), z=target.z, walkType=walkType}
                -- task = {action="Move", time=50, x=x+dx+dxf, y=y+dy+dyf, z=z, walkType=walkType}
            end
            table.insert(tasks, task)

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

    local walkType = "Run"
    if health < 0.4 then
        walkType = "Limp"
    end

    local handweapon = bandit:getVariableString("BanditWeapon")

    local x, y, z, dist, playerId = BanditUtils.GetClosestPlayerLocation(bandit)

    if x and y and z then

        -- calculate random escape direction
        local deltaX = 100 + ZombRand(100)
        local deltaY = 100 + ZombRand(100)

        local rx = ZombRand(2)
        local ry = ZombRand(2)
        if rx == 1 then deltaX = -deltaX end
        if ry == 1 then deltaY = -deltaY end

        local gamemode = getWorld():getGameMode()
        local task
        if gamemode == "Multiplayer" then
            task = {action="GoTo", time=250, x=x+deltaX, y=y+deltaY, z=0, walkType=walkType}
        else
            task = {action="Move", time=250, x=x+deltaX, y=y+deltaY, z=0, walkType=walkType}
        end
        table.insert(tasks, task)
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
                    local uninstallPartList = {"Battery", "TireRearLeft", "TireRearRight", "TireFrontRight", "TireFrontLeft"}
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
                        local minDist = 2.5
                        if uninstallPartArea == "Engine" then minDist = 6.4 end
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
