ZombiePrograms = ZombiePrograms or {}

local function predicateAll(item)
    return true
end

ZombiePrograms.Bandit = {}
ZombiePrograms.Bandit.Stages = {}

ZombiePrograms.Bandit.Init = function(bandit)
end

ZombiePrograms.Bandit.Prepare = function(bandit)
    local tasks = {}

    Bandit.ForceStationary(bandit, false)
  
    return {status=true, next="Main", tasks=tasks}
end

ZombiePrograms.Bandit.Main = function(bandit)
    local tasks = {}
    local cell = getCell()
    local bx, by, bz = bandit:getX(), bandit:getY(), bandit:getZ()
    local baseId, base = BanditPlayerBase.GetBaseClosest(bandit)
    local endurance = 0.00
    local health = bandit:getHealth()
    local healthMin = 0.7
    local walkType = "Run"

    if SandboxVars.Bandits.General_RunAway and health < healthMin then
        return {status=true, next="Escape", tasks=tasks}
    end

    local room = bandit:getSquare():getRoom()
    if room then
        local lsList = room:getLightSwitches()
        local distBest = math.huge
        local lsBest
        for i=0, lsList:size()-1 do
            local ls = lsList:get(i)
            local square = ls:getSquare()
            if not ls:isActivated() and square:isFree(false) and (square:haveElectricity() or getWorld():isHydroPowerOn()) then
                local tx, ty, tz = square:getX() + 0.5, square:getY() + 0.5, square:getZ()
                local dist = BanditUtils.DistTo(bx, by, tx, ty)
                if dist < distBest then
                    distBest = dist
                    lsBest = ls
                end
            end
        end

        if lsBest then
            local square = lsBest:getSquare()
            local tx, ty, tz = square:getX() + 0.5, square:getY() + 0.5, square:getZ()
            local dist = BanditUtils.DistTo(bx, by, tx, ty)
            if distBest < 1.2 and bz == tz then
                local task = {action="LightToggle", time=20, active=true, x=tx, y=ty, z=tz}
                table.insert(tasks, task)
                return {status=true, next="Main", tasks=tasks}
            else
                table.insert(tasks, BanditUtils.GetMoveTask(endurance, tx, ty, tz, walkType, dist, false))
                return {status=true, next="Main", tasks=tasks}
            end
        end
    end

    local isElectrician = Bandit.HasExpertise(bandit, Bandit.Expertise.Electrician)
    local isMechanic = Bandit.HasExpertise(bandit, Bandit.Expertise.Mechanic)
    if (isElectrician and SandboxVars.Bandits.General_GeneratorCutoff) or (isMechanic and SandboxVars.Bandits.General_SabotageVehicles) then 
        for z=0, 1 do
            for y=-10, 10 do
                for x=-10, 10 do
                    local tx, ty, tz = bx + x, by + y, z
                    local square = cell:getGridSquare(tx, ty, tz)
                    if square then

                        -- only if outside to prevent defenders shuting down their own genny
                        if isElectrician and bandit:isOutside() then
                            local gen = square:getGenerator()
                            if gen and gen:isActivated() then
                                local dist = BanditUtils.DistTo(bx, by, tx, ty)
                                if dist < 1 then
                                    local task = {action="GeneratorToggle", anim="LootLow", x=tx, y=ty, z=tz, status=false}
                                    table.insert(tasks, task)
                                    return {status=true, next="Main", tasks=tasks}
                                else
                                    table.insert(tasks, BanditUtils.GetMoveTask(endurance, tx, ty, tz, walkType, dist, false))
                                    return {status=true, next="Main", tasks=tasks}
                                end
                            end
                        end

                        -- SandboxVars.Bandits.General_SabotageVehicles and
                        if isMechanic then
                            local vehicle = square:getVehicleContainer()
                            if vehicle and vehicle:isHotwired() then
                                local vx, vy, vz = vehicle:getX(), vehicle:getY(), vehicle:getZ()
                                local partIds = {"TireFrontRight", "TireFrontLeft", "TireRearLeft", "TireRearRight"}
                                for i=1, #partIds do
                                    local partId = partIds[i]
                                    local vehiclePart = vehicle:getPartById(partId)
                                    if vehiclePart then
                                        local item = vehiclePart:getInventoryItem()
                                        if item then
                                            local vector = vehicle:getAreaCenter(partId)
                                            local tx, ty, tz = vector:getX(), vector:getY(), vehicle:getZ()
                                            -- print ("PARTV: " .. partId .. " X:" .. tx .. " Y:" .. ty)

                                            local dist = BanditUtils.DistTo(bx, by, tx, ty)
                                            if dist < 0.8 then
                                                local task = {action="VehicleAction", subaction="Uninstall", sound="RepairWithWrench", partId=partId, vx=vx, vy=vy, vz=vz, fx=vx, fy=vy, time=650}
                                                table.insert(tasks, task)
                                                return {status=true, next="Main", tasks=tasks}
                                            else
                                                table.insert(tasks, BanditUtils.GetMoveTask(endurance, tx, ty, tz, walkType, dist, false))
                                                return {status=true, next="Main", tasks=tasks}
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    if SandboxVars.Bandits.General_Theft then
        local inventory = bandit:getInventory()
        local items = ArrayList.new()
        inventory:getAllEvalRecurse(predicateAll, items)
        if items:size() < 10 then
            if base and Bandit.HasExpertise(bandit, Bandit.Expertise.Thief) then
                local contId, cont = BanditPlayerBase.GetContainerClosest(bandit, baseId)
                if contId then
                    -- select first item
                    local itemType
                    local cnt
                    for k, v in pairs(cont.items) do
                        itemType = k
                        cnt = v
                        break
                    end
                    if itemType then
                        local square = cell:getGridSquare(cont.x, cont.y, cont.z)
                        if square then
                            local asquare = AdjacentFreeTileFinder.Find(square, bandit)
                        
                            if asquare then
                                local dist = BanditUtils.DistTo(bandit:getX(), bandit:getY(), asquare:getX() + 0.5, asquare:getY() + 0.5)
                                if dist > 0.90 or bandit:getZ() ~= asquare:getZ() then
                                    local task = BanditUtils.GetMoveTask(0, asquare:getX(), asquare:getY(), asquare:getZ(), "Run", dist, false)
                                    table.insert(tasks, task)
                                    return {status=true, next="Main", tasks=tasks}
                                elseif bandit:getZ() == asquare:getZ() then
                                    Bandit.Say(bandit, "THIEF_SPOTTED")
                                    if cont.type == "floor" then
                                        -- bandit:addLineChatElement(("pickup " .. itemType), 1, 1, 1)
                                        local task = {action="PickUp", anim="LootLow", itemType=itemType, x=square:getX(), y=square:getY(), z=square:getZ(), cnt=cnt}
                                        table.insert(tasks, task)
                                        return {status=true, next="Main", tasks=tasks}
                                    else
                                        -- bandit:addLineChatElement(("take from container: " .. itemType), 1, 1, 1)
                                        local task = {action="TakeFromContainer", anim="Loot", itemType=itemType, x=square:getX(), y=square:getY(), z=square:getZ(), cnt=cnt}
                                        table.insert(tasks, task)
                                        return {status=true, next="Main", tasks=tasks}
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    if SandboxVars.Bandits.General_SabotageCrops then
        local plant = BanditPlayerBase.GetFarm(bandit)
        if plant then
            local dist = BanditUtils.DistTo(bandit:getX(), bandit:getY(), plant.x + 0.5, plant.y + 0.5)
            if dist > 0.80 then
                table.insert(tasks, BanditUtils.GetMoveTask(0, plant.x, plant.y, plant.z, walkType, dist, false))
                return {status=true, next="Main", tasks=tasks}
            else
                local task = {action="StompPlant", x=plant.x, y=plant.y, z=plant.z, anim="Attack2HStamp", sound="AttackStomp"}
                table.insert(tasks, task)
                return {status=true, next="Main", tasks=tasks}
            end
        end
    end

    local config = {}
    config.mustSee = true
    config.hearDist = 5

    if Bandit.HasExpertise(bandit, Bandit.Expertise.Recon) then
        config.hearDist = 13
    elseif Bandit.HasExpertise(bandit, Bandit.Expertise.Tracker) then
        config.hearDist = 55
    end

    local target, enemy = BanditUtils.GetTarget(bandit, config)
    
    -- engage with target
    if target.x and target.y and target.z then
        local targetSquare = cell:getGridSquare(target.x, target.y, target.z)
        if targetSquare then
            Bandit.SayLocation(bandit, targetSquare)
        end

        local tx, ty, tz = target.x, target.y, target.z
    
        if enemy then
            if target.fx and target.fy and (enemy:isRunning()  or enemy:isSprinting()) then
                tx, ty = target.fx, target.fy
            end
        end

        local walkType = Bandit.GetCombatWalktype(bandit, enemy, target.dist)

        table.insert(tasks, BanditUtils.GetMoveTaskTarget(endurance, tx, ty, tz, target.id, target.player, walkType, target.dist))
        return {status=true, next="Main", tasks=tasks}
    end

    local task = {action="Time", anim="Shrug", time=200}
    table.insert(tasks, task)

    return {status=true, next="Main", tasks=tasks}
end

ZombiePrograms.Bandit.Escape = function(bandit)
    local tasks = {}
    local weapons = Bandit.GetWeapons(bandit)

    local health = bandit:getHealth()

    local endurance = -0.06
    local walkType = "Run"
    if health < 0.8 then
        walkType = "Limp"
        endurance = 0
    end

    local config = {}
    config.mustSee = false
    config.hearDist = 40

    local closestPlayer = BanditUtils.GetClosestPlayerLocation(bandit, config)

    if closestPlayer.x and closestPlayer.y and closestPlayer.z then

        -- calculate random escape direction
        local deltaX = 100 + ZombRand(100)
        local deltaY = 100 + ZombRand(100)

        local rx = ZombRand(2)
        local ry = ZombRand(2)
        if rx == 1 then deltaX = -deltaX end
        if ry == 1 then deltaY = -deltaY end

        table.insert(tasks, BanditUtils.GetMoveTask(endurance, closestPlayer.x+deltaX, closestPlayer.y+deltaY, 0, walkType, 12, false))
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

