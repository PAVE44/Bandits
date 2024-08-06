ZombieActions = ZombieActions or {}

local function Hit (shooter, victim)
    local dist = math.sqrt(math.pow(shooter:getX() - victim:getX(), 2) + math.pow(shooter:getY() - victim:getY(), 2))

    local accuracyLevel = SandboxVars.Bandits.General_OverallAccuracy
    local accuracyCoeff = 0.1
    if accuracyLevel == 1 then
        accuracyCoeff = 0.5
    elseif accuracyLevel == 2 then
        accuracyCoeff = 0.22
    elseif accuracyLevel == 3 then
        accuracyCoeff = 0.1
    elseif accuracyLevel == 4 then
        accuracyCoeff = 0.042
    elseif accuracyLevel == 5  then
        accuracyCoeff = 0.016
    end

    local accuracyThreshold = 100 / (1 + accuracyCoeff * dist)

    if ZombRand(100) < accuracyThreshold then
        local item = InventoryItemFactory.CreateItem("Base.AssaultRifle2")
        
        local hitSound = "ZSHit" .. tostring(1 + ZombRand(3))
        -- local emitter = getWorld():getFreeEmitter(victim:getX(), victim:getY(), victim:getZ())
        -- print ("------ DIST: " .. (1/dist))
        -- emitter:setVolumeAll(1/dist)
        -- emitter:playSound(hitSound)
        
        victim:playSound(hitSound)
        
        if instanceof(victim, 'IsoPlayer') and SandboxVars.Bandits.General_HitModel == 2 then
            PlayerDamageModel.BulletHit(shooter, victim)
        else
            victim:Hit(item, shooter, 50, false, 1, false)
            victim:addBlood(0.6)
            SwipeStatePlayer.splash(victim, item, shooter)
        end
        
        -- if ZombRand(4) == 0 then player:setBumpType("stagger") end
        -- print ("hit!!")
    else
        local missSound = "ZSMiss".. tostring(1 + ZombRand(8))
        -- print ("miss!!")
        -- victim:getSquare():playSound(missSound)
    end
end

-- Bresenham's line of fire to detect what needs to destroyed between shooter and target
local function ManageLineOfFire (shooter, victim)
    local cell = getCell()

    local x0 = shooter:getX()
    local y0 = shooter:getY()
    local x1 = victim:getX()
    local y1 = victim:getY()

    if x0 > x1 then x0, x1 = x1, x0 end
    if y0 > y1 then y0, y1 = y1, y0 end

    local dx = x1 - x0
    local dy = y1 - y0
    local D = 2 * dy - dx
    local y = y0
    
    for x = x0, x1 do

        for sx = -1, 1 do
            for sy = -1, 1 do

                local square = cell:getGridSquare(math.floor(x + 0.5) + sx, math.floor(y + 0.5) + sy, 0)

                if square then
                    -- smash windows
                    local window = square:getWindow()
                    if window and not window:isSmashed() then
                        square:playSound("SmashWindow")
                        window:smashWindow()
                    end

                    local vehicle = square:getVehicleContainer()
                    if vehicle then
                        local partRandom = ZombRand(50)

                        local vehiclePart
                        if partRandom == 1 then
                            vehiclePart = vehicle:getPartById("HeadlightLeft")
                        elseif partRandom == 2 then
                            vehiclePart = vehicle:getPartById("HeadlightRight")
                        elseif partRandom == 3 then
                            vehiclePart = vehicle:getPartById("HeadlightRearLeft")
                        elseif partRandom == 4 then
                            vehiclePart = vehicle:getPartById("HeadlightRight")
                        elseif partRandom == 5 then
                            vehiclePart = vehicle:getPartById("Windshield")
                        elseif partRandom == 6 then
                            vehiclePart = vehicle:getPartById("WindshieldRear")
                        elseif partRandom == 7 then
                            vehiclePart = vehicle:getPartById("WindowFrontRight")
                        elseif partRandom == 8 then
                            vehiclePart = vehicle:getPartById("WindowFrontLeft")
                        elseif partRandom == 9 then
                            vehiclePart = vehicle:getPartById("WindowRearRight")
                        elseif partRandom == 10 then
                            vehiclePart = vehicle:getPartById("WindowRearLeft")
                        elseif partRandom == 11 then
                            vehiclePart = vehicle:getPartById("WindowMiddleLeft")
                        elseif partRandom == 12 then
                            vehiclePart = vehicle:getPartById("WindowMiddleRight")
                        elseif partRandom == 13 then
                            vehiclePart = vehicle:getPartById("DoorFrontRight")
                        elseif partRandom == 14 then
                            vehiclePart = vehicle:getPartById("DoorFrontLeft")
                        elseif partRandom == 15 then
                            vehiclePart = vehicle:getPartById("DoorRearRight")
                        elseif partRandom == 16 then
                            vehiclePart = vehicle:getPartById("DoorRearLeft")
                        elseif partRandom == 17 then
                            vehiclePart = vehicle:getPartById("EngineDoor")
                        elseif partRandom == 18 then
                            vehiclePart = vehicle:getPartById("TireFrontRight")
                        elseif partRandom == 19 then
                            vehiclePart = vehicle:getPartById("TireFrontLeft")
                        elseif partRandom == 20 then
                            vehiclePart = vehicle:getPartById("TireRearLeft")
                        elseif partRandom == 21 then
                            vehiclePart = vehicle:getPartById("TireRearRight")
                        end

                        if vehiclePart and vehiclePart:getInventoryItem() then
                            
                            if vehiclePart:getCondition() <= 0 then
                                vehiclePart:setInventoryItem(nil)
                                vehicle:transmitPartItem(vehiclePart)
                            end

                            if partRandom <= 12 then
                                vehiclePart:damage(20+ZombRand(10))
                                if vehiclePart:getCondition() <= 0 then
                                    square:playSound("SmashWindow")
                                else
                                    square:playSound("BreakGlassItem")
                                end
                            elseif partRandom <= 17 then
                                vehiclePart:damage(5+ZombRand(5))
                                square:playSound("HitVehiclePartWithWeapon")
                            elseif partRandom <= 21 then
                                vehiclePart:damage(10+ZombRand(30))
                                if vehiclePart:getCondition() <= 0 then
                                    square:playSound("VehicleTireExplode")
                                end
                            end
                        end

                        --
                    end

                    -- cant shoot through the closed door (although bandits can see through them)
                    local door = square:getIsoDoor()
                    if door and not door:IsOpen() then
                        return false
                    end
                end


            end
        end

        if D > 0 then
            y = y + 1
            D = D - 2*dx
        end
        D = D + 2 * dy
    end
    return true
end

ZombieActions.Shoot = {}
ZombieActions.Shoot.onStart = function(zombie, task)
    return true
end

ZombieActions.Shoot.onWorking = function(zombie, task)
    zombie:faceLocationF(task.x, task.y)

    return false
end

ZombieActions.Shoot.onComplete = function(zombie, task)
    local shooter = zombie
    local cell = shooter:getSquare():getCell()

    -- local inAngle = BanditUtils.IsInAngle(zombie, task.x, task.y)
    -- if not inAngle then return true end

    shooter:startMuzzleFlash()
    zombie:playSound(task.weaponSound)
    if ZombRand(10) == 1 then
        addSound(getPlayer(), shooter:getX(), shooter:getY(), shooter:getZ(), 40, 100)
    end

    for dx=-2, 2 do
        for dy=-2, 2 do
            local square = cell:getGridSquare(task.x + dx, task.y + dy, task.z)

            if square then
                local victim
                
                victim = square:getPlayer()
                if not victim and math.abs(dx) <= 1 and math.abs(dy) <= 1 then
                    local testVictim = square:getZombie()

                    if testVictim then
                        local brainShooter = BanditBrain.Get(shooter)
                        local brainVictim = BanditBrain.Get(testVictim)
                        if not brainVictim or not brainVictim.clan or brainShooter.clan ~= brainVictim.clan then 
                            victim = testVictim
                        end
                    end
                end
                
                if victim then
                    if BanditUtils.GetCharacterID(shooter) ~= BanditUtils.GetCharacterID(victim) then 
                        local res = ManageLineOfFire(shooter, victim)
                        if res then
                            Hit(shooter, victim)
                        end
                        
                        break
                    end
                end
            end
        end
    end

    return true
end