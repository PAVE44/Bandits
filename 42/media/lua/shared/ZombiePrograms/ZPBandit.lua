ZombiePrograms = ZombiePrograms or {}

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
    local world = getWorld()
    local cell = getCell()
    local cm = world:getClimateManager()
    local dls = cm:getDayLightStrength()
    local bx, by, bz = bandit:getX(), bandit:getY(), bandit:getZ()
    local outOfAmmo = Bandit.IsOutOfAmmo(bandit)
    local walkType = "Run"
    local endurance = -0.06

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
    if health < 0.8 then
        walkType = "Limp"
        endurance = 0
    end 
 
    local healthMin = 0.7

    if SandboxVars.Bandits.General_RunAway and health < healthMin then
        return {status=true, next="Escape", tasks=tasks}
    end

    if SandboxVars.Bandits.General_GeneratorCutoff or SandboxVars.Bandits.General_SabotageVehicles then 
        for z=0, 1 do
            for y=-10, 10 do
                for x=-10, 10 do
                    local tx, ty, tz = bx + x, by + y, z
                    local square = cell:getGridSquare(tx, ty, tz)
                    if square then

                        -- only if outside to prevent defenders shuting down their own genny
                        if SandboxVars.Bandits.General_GeneratorCutoff and Bandit.HasExpertise(bandit, Bandit.Expertise.Electrician) and bandit:isOutside() then
                            local gen = square:getGenerator()
                            if gen and gen:isActivated() then
                                local dist = BanditUtils.DistTo(bx, by, tx, ty)
                                if dist < 1 then
                                    local task = {action="GeneratorToggle", anim="LootLow", x=tx, y=ty, z=tz, status=false}
                                    table.insert(tasks, task)
                                else
                                    table.insert(tasks, BanditUtils.GetMoveTask(endurance, tx, ty, tz, walkType, dist, false))
                                    return {status=true, next="Main", tasks=tasks}
                                end
                            end
                        end

                        if SandboxVars.Bandits.General_SabotageVehicles and Bandit.HasExpertise(bandit, Bandit.Expertise.Mechanic) then
                            local vehicle = square:getVehicleContainer()
                            if vehicle and vehicle:isHotwired() and not vehicle:getDriver() then
                                local vx, vy, vz = square:getX(), square:getY(), square:getZ()
                                local test0 = vehicle:isHotwired()
                                local test1 = vehicle:isEngineRunning()
                                local vehiclePart = vehicle:getPartById("TireRearLeft")
                                local vehiclePartSquare = vehiclePart:getSquare()
                                -- local vpx, vpy, vpz = vehiclePartSquare:getX(), vehiclePartSquare:getY(), vehiclePartSquare:getZ()

                                table.insert(tasks, BanditUtils.GetMoveTask(endurance, vx, vy, vz, walkType, 12, false))
                                return {status=true, next="Main", tasks=tasks}
                            end
                        end
                    end
                end
            end
        end
    end

    local target = {}
    local enemy

    local target, enemy = BanditUtils.GetTarget(bandit)
    
    -- engage with target
    if target.x and target.y and target.z then
        local targetSquare = cell:getGridSquare(target.x, target.y, target.z)
        if targetSquare then
            Bandit.SayLocation(bandit, targetSquare)
        end

        local tx, ty, tz = target.x, target.y, target.z
        
        local closeSlow = true
        local engageUpfront = false
        if enemy then
            local weapon = enemy:getPrimaryHandItem()
            if weapon and weapon:IsWeapon() then
                local weaponType = WeaponType.getWeaponType(weapon)
                if weaponType == WeaponType.firearm or weaponType == WeaponType.handgun then
                    closeSlow = false
                end
            end

            if target.fx and target.fy and (enemy:isRunning()  or enemy:isSprinting()) then
                engageUpfront = true
            end
        end
        
        if engageUpfront then
            tx, ty = target.fx, target.fy
        end

        table.insert(tasks, BanditUtils.GetMoveTask(endurance, tx, ty, tz, walkType, target.dist, closeSlow))
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

    local closestPlayer = BanditUtils.GetClosestPlayerLocation(bandit)

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
        return {status=true, next="Main", tasks=tasks}
    end
end

