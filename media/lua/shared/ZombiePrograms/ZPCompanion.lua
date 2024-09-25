ZombiePrograms = ZombiePrograms or {}

ZombiePrograms.Companion = {}
ZombiePrograms.Companion.Stages = {}

ZombiePrograms.Companion.Init = function(bandit)
end

ZombiePrograms.Companion.GetCapabilities = function()
    -- capabilities are program decided
    local capabilities = {}
    capabilities.melee = true
    capabilities.shoot = true
    capabilities.smashWindow = true
    capabilities.openDoor = true
    capabilities.breakDoor = true
    capabilities.breakObjects = true
    capabilities.unbarricade = false
    capabilities.disableGenerators = false
    capabilities.sabotageCars = false
    return capabilities
end

ZombiePrograms.Companion.Prepare = function(bandit)
    local tasks = {}
    local world = getWorld()
    local cm = world:getClimateManager()
    local dls = cm:getDayLightStrength()

    Bandit.ForceStationary(bandit, false)
    Bandit.SetWeapons(bandit, Bandit.GetWeapons(bandit))
    
    local primary = Bandit.GetBestWeapon(bandit)

    local secondary
    if SandboxVars.Bandits.General_CarryTorches and dls < 0.3 then
        secondary = "Base.HandTorch"
    end

    local task = {action="Equip", itemPrimary=primary, itemSecondary=secondary}
    table.insert(tasks, task)

    return {status=true, next="Follow", tasks=tasks}
end

ZombiePrograms.Companion.Follow = function(bandit)
    local tasks = {}
    local world = getWorld()
    local cm = world:getClimateManager()
    local cell = getCell()
    -- local weapons = Bandit.GetWeapons(bandit)
 
    -- If at guardpost, switch to the CompanionGuard program.
    local atGuardpost = BanditGuardpost.At(bandit)
    if atGuardpost then
        print ("AT GUARDPOST")
        Bandit.SetProgram(bandit, "CompanionGuard", {})
        return {status=true, next="Prepare", tasks=tasks}
    end
    
    -- Companion logic depends on one of the players who is the master od the companion
    -- if there is no master, there is nothing to do.
    local master = BanditPlayer.GetMasterPlayer(bandit)
    if not master then
        local task = {action="Time", anim="Shrug", time=200}
        table.insert(tasks, task)
        return {status=true, next="Follow", tasks=tasks}
    end
    
    -- update walktype
    local walkType = "Walk"
    local endurance = 0.00
    local vehicle = master:getVehicle()
    local dist = math.sqrt(math.pow(bandit:getX() - master:getX(), 2) + math.pow(bandit:getY() - master:getY(), 2))

    if master:isRunning() or master:isSprinting() or vehicle then
        walkType = "Run"
        endurance = -0.07
    elseif master:isSneaking() and dist<12 then
        walkType = "SneakWalk"
        endurance = -0.01
    end

    local outOfAmmo = Bandit.IsOutOfAmmo(bandit)
    if master:isAiming() and not outOfAmmo and dist < 8 then
        walkType = "WalkAim"
        endurance = 0
    end

    local health = bandit:getHealth()
    if health < 0.4 then
        walkType = "Limp"
        endurance = 0
    end 
   
    -- If the player is in the vehicle, the companion should join him.
    -- If the player exits the vehicle, so should the companion.
    if SandboxVars.Bandits.General_EnterVehicles then
        if vehicle then
            if dist < 2.2 then
                local bvehicle = bandit:getVehicle()
                if bvehicle then
                    bandit:changeState(ZombieOnGroundState.instance())
                    return {status=true, next="Follow", tasks=tasks}
                else
                    print ("ENTER VEH")
                    local vx = bandit:getForwardDirection():getX()
                    local vy = bandit:getForwardDirection():getY()
                    local forwardVector = Vector3f.new(vx, vy, 0)

                    for seat=1, 10 do
                        if vehicle:isSeatInstalled(seat) and not vehicle:isSeatOccupied(seat) then
                            bandit:enterVehicle(vehicle, seat, forwardVector)
                            bandit:playSound("VehicleDoorOpen")
                            break
                        end
                    end
                end
            end
        else
            local bvehicle = bandit:getVehicle()
            if bvehicle then
                print ("EXIT VEH")
                -- After exiting the vehicle, the companion is in the ongroundstate.
                -- Additionally he is under the car. This is fixed in BanditUpdate loop. 
                bandit:setVariable("BanditImmediateAnim", true)
                bvehicle:exit(bandit)
                bandit:playSound("VehicleDoorClose")
            end
        end
    end

    -- Companions intention is to generally stay with the player
    -- however, if the enemy is close, the companion should engage
    -- but only if player is not too far, kind of a proactive defense.
    if dist < 20 then
        local closestZombie = BanditUtils.GetClosestZombieLocation(bandit)
        local closestBandit = BanditUtils.GetClosestEnemyBanditLocation(bandit)
        local closestEnemy = closestZombie

        if closestBandit.dist < closestZombie.dist then 
            closestEnemy = closestBandit 
        end

        if closestEnemy.dist < 8 then
            -- We are trying to save the player, so the friendly should act with high motivation
            -- that translates to running pace (even despite limping) and minimal endurance loss.
            walkType = "Run"
            endurance = -0.01
            table.insert(tasks, BanditUtils.GetMoveTask(endurance, closestEnemy.x, closestEnemy.y, closestEnemy.z, walkType, closestEnemy.dist))
            return {status=true, next="Follow", tasks=tasks}
        end
    end
    
    -- look for guns
    if Bandit.IsOutOfAmmo(bandit) then

        -- deadbodies
        for z=0, 2 do
            for y=-12, 12 do
                for x=-12, 12 do
                    local square = cell:getGridSquare(bandit:getX() + x, bandit:getY() + y, z)
                    if square then
                        local body = square:getDeadBody()
                        if body then

                            -- we found one body, but there my be more bodies on that square and we need to check all
                            local objects = square:getStaticMovingObjects()
                            for i=0, objects:size()-1 do
                                local object = objects:get(i)
                                if instanceof (object, "IsoDeadBody") then
                                    local body = object
                                    container = body:getContainer()
                                    if container and not container:isEmpty() then
                                        local subTasks = BanditPrograms.Container.Loot(bandit, body, container)
                                        if #subTasks > 0 then
                                            for _, subTask in pairs(subTasks) do
                                                table.insert(tasks, subTask)
                                            end
                                            return {status=true, next="Prepare", tasks=tasks}
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        -- containers in rooms
        local room = bandit:getSquare():getRoom()
        if room then
            local roomDef = room:getRoomDef()
            for x=roomDef:getX(), roomDef:getX2() do
                for y=roomDef:getY(), roomDef:getY2() do
                    local square = cell:getGridSquare(x, y, roomDef:getZ())
                    if square then
                        local objects = square:getObjects()
                        for i=0, objects:size() - 1 do
                            local object = objects:get(i)
                            local container = object:getContainer()
                            if container and not container:isEmpty() then
                                local subTasks = BanditPrograms.Container.Loot(bandit, object, container)
                                if #subTasks > 0 then
                                    for _, subTask in pairs(subTasks) do
                                        table.insert(tasks, subTask)
                                    end
                                    return {status=true, next="Prepare", tasks=tasks}
                                end
                            end
                        end
                    end
                end
            end
        end 
    end

    -- If there is a guardpost in the vicinity, take it.
    local guardpost = BanditGuardpost.GetClosestFree(bandit, 40)
    if guardpost then
        table.insert(tasks, BanditUtils.GetMoveTask(endurance, guardpost.x, guardpost.y, guardpost.z, walkType, dist))
        return {status=true, next="Follow", tasks=tasks}
    end

    -- companion fishing
    local gameTime = getGameTime()
    local hour = gameTime:getHour()
    if (hour >= 4 and hour < 7) or (hour >= 18 and hour < 22) then
        local vectors = {}
        table.insert(vectors, {x=0, y=-1}) --12
        table.insert(vectors, {x=1, y=-1}) -- 1.30
        table.insert(vectors, {x=1, y=0}) -- 3
        table.insert(vectors, {x=1, y=1}) -- 4.30
        table.insert(vectors, {x=0, y=1}) -- 6
        table.insert(vectors, {x=-1, y=1}) -- 7.30
        table.insert(vectors, {x=-1, y=0}) -- 9
        table.insert(vectors, {x=-1, y=-1}) -- 10.30
        
        local bx = bandit:getX()
        local by = bandit:getY()
        local wx
        local wy
        local wd = 31
        local wsquare
        for _, vector in pairs(vectors) do
            for i=1, 30 do
                local x = bx + vector.x * i
                local y = by + vector.y * i
                local square = cell:getGridSquare(x, y, 0)
                if square and BanditUtils.IsWater(square) then
                    if i < wd then
                        wx, wy, wd = x, y, i
                        wsquare = square
                        break
                    end
                end
            end
        end

        if wx and wy then
            local asquare = AdjacentFreeTileFinder.Find(wsquare, bandit)
            if asquare then
                local tx = asquare:getX()
                local ty = asquare:getY()

                local dist = math.sqrt(math.pow(tx - bx, 2) + math.pow(ty - by, 2))
                if dist < 1.2 then
                    print ("should fish")
                    local task = {action="Fishing", time=1000, x=wx, y=wy}
                    table.insert(tasks, task)
                    return {status=true, next="Follow", tasks=tasks}
                else
                    table.insert(tasks, BanditUtils.GetMoveTask(endurance, tx, ty, 0, "Run", dist))
                    return {status=true, next="Follow", tasks=tasks}
                end
            end
        end
    end

    -- companion foraging
    local dls = cm:getDayLightStrength()
    local rain = cm:getRainIntensity()
    local fog = cm:getFogIntensity()
    local zoneData = forageSystem.getForageZoneAt(bandit:getX(), bandit:getY())

    local inZone = false
    local zone = getWorld():getMetaGrid():getZoneAt(bandit:getX(), bandit:getY(), 0)
    if zone then
        local zoneType = zone:getType()
        if zoneType == "Forest" or zoneType == "DeepForest" or zoneType == "Vegitation" or zoneType == "FarmLand" then
            inZone = true
        end
    end

    if zoneData and inZone and dls > 0.9 and rain < 0.3 and fog < 0.2 then
        local month = getGameTime():getMonth() + 1
        local timeOfDay = forageSystem.getTimeOfDay() or "isDay"
        local weatherType = forageSystem.getWeatherType() or "isNormal"
        local lootTable = forageSystem.lootTables[zoneData.name][month][timeOfDay][weatherType]
        
        local itemType, catName = forageSystem.pickRandomItemType(lootTable)
        if itemType and catName then
            local item = InventoryItemFactory.CreateItem(itemType)
            if instanceof (item, "Food") then
                local test1 = item:getProteins()
                local test2 = item:getCalories()
                local test3 = item:getCarbohydrates()
                local test4 = item:isSpice()

                print ("found: " .. itemType)
                local task = {action="Drop", anim="Forage", itemType=itemType, time=400}
                table.insert(tasks, task)

                -- local task2 = {action="Single", anim="Eat", time=400}
                -- table.insert(tasks, task2)
                -- local task3 = {action="Single", anim="Eat", time=400}
                -- table.insert(tasks, task3)
                return {status=true, next="Follow", tasks=tasks}
            end
        end
    end

    -- follow the player.
    local minDist = 1
    if dist > minDist then
        local id = BanditUtils.GetCharacterID(bandit)

        local theta = master:getDirectionAngle() * math.pi / 180
        local lx = 3 * math.cos(theta)
        local ly = 3 * math.sin(theta)

        local dx = master:getX() - lx
        local dy = master:getY() - ly
        local dz = master:getZ()
        local dxf = ((id % 10) - 5) / 10
        local dyf = ((id % 11) - 5) / 10
        table.insert(tasks, BanditUtils.GetMoveTask(endurance, dx+dxf, dy+dyf, dz, walkType, dist))
    end

    return {status=true, next="Follow", tasks=tasks}
end
