ZombieActions = ZombieActions or {}

local function Hit(shooter, item, victim)

    -- Clone the shooter to create a temporary IsoPlayer
    local tempShooter = BanditUtils.CloneIsoPlayer(shooter)

    -- Calculate the distance between the shooter and the victim
    local dist = BanditUtils.DistTo(victim:getX(), victim:getY(), tempShooter:getX(), tempShooter:getY())

    -- Determine accuracy based on SandboxVars and shooter clan
    local brainShooter = BanditBrain.Get(shooter)
    local accuracyBoost = brainShooter.accuracyBoost or 1
    local accuracyLevel = SandboxVars.Bandits.General_OverallAccuracy
    local accuracyCoeff = 0.11
    if accuracyLevel == 1 then
        accuracyCoeff = 0.5
    elseif accuracyLevel == 2 then
        accuracyCoeff = 0.22
    elseif accuracyLevel == 3 then
        accuracyCoeff = 0.11
    elseif accuracyLevel == 4 then
        accuracyCoeff = 0.06
    elseif accuracyLevel == 5 then
        accuracyCoeff = 0.028
    end

    local accuracyThreshold = 100 / (1 + accuracyCoeff * (dist - 1) / accuracyBoost)

    -- Warning, this is not perfect, local player mand remote players will not generate the same 
    -- random number.
    if ZombRand(100) < accuracyThreshold then
        local hitSound = "ZSHit" .. tostring(1 + ZombRand(3))
        victim:playSound(hitSound)
        BanditPlayer.WakeEveryone()
        
        if instanceof(victim, 'IsoPlayer') and SandboxVars.Bandits.General_HitModel == 2 then
            PlayerDamageModel.BulletHit(tempShooter, victim)
        else
            if instanceof(victim, "IsoPlayer") and victim:isSprinting() or (victim:isRunning() and ZombRand(8) == 1) then
                victim:clearVariable("BumpFallType")
                victim:setBumpType("stagger")
                victim:setBumpFall(true)
                victim:setBumpFallType("pushedBehind")
            else
                victim:setHitFromBehind(shooter:isBehind(victim))

                if instanceof(victim, "IsoZombie") then
                    victim:setHitAngle(shooter:getForwardDirection())
                    victim:setPlayerAttackPosition(victim:testDotSide(shooter))
                end

                victim:Hit(item, tempShooter, 6, false, 1, false)
                victim:setAttackedBy(shooter)
                local bodyDamage = victim:getBodyDamage()
                if bodyDamage then
                    local health = bodyDamage:getOverallBodyHealth()
                    health = health + 8
                    if health > 100 then health = 100 end
                    bodyDamage:setOverallBodyHealth(health)
                end
            end

            victim:addBlood(0.6)

            BanditCompatibility.Splash(victim, item, tempShooter)
            
            if instanceof(victim, "IsoPlayer") then
                BanditCompatibility.PlayerVoiceSound(victim, "PainFromFallHigh")
            end

            if victim:getHealth() <= 0 then victim:Kill(getCell():getFakeZombieForHit(), true) end
        end
    else
        local missSound = "ZSMiss".. tostring(1 + ZombRand(8))
        -- victim:getSquare():playSound(missSound)
    end

    -- Clean up the temporary player after use
    tempShooter:removeFromWorld()
    tempShooter = nil

    return true
end

-- Bresenham's line of fire to detect what needs to destroyed between shooter and target
local function ManageLineOfFire (shooter, victim)
    local cell = getCell()
    local player = getPlayer()
    
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
                        local partRandom = ZombRand(30)

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
                        else
                            return false
                        end

                        if vehiclePart and vehiclePart:getInventoryItem() then
                            
                            local vehiclePartId = vehiclePart:getId()

                            if vehiclePart:getCondition() <= 0 then
                                vehiclePart:setInventoryItem(nil)
                            end

                            if partRandom <= 4 then
                                local dmg = 12
                                vehiclePart:damage(dmg)
                                local args = {x=square:getX(), y=square:getY(), id=vehiclePartId, dmg=dmg}
                                sendClientCommand(player, 'Commands', 'VehiclePartDamage', args)

                                square:playSound("BreakGlassItem")
                                return false
                            elseif partRandom <= 12 then
                                local dmg = 12
                                vehiclePart:damage(dmg)
                                local args = {x=square:getX(), y=square:getY(), id=vehiclePartId, dmg=dmg}
                                sendClientCommand(player, 'Commands', 'VehiclePartDamage', args)

                                if vehiclePart:getCondition() <= 0 then
                                    square:playSound("SmashWindow")
                                else
                                    square:playSound("BreakGlassItem")
                                    return false
                                end
                            elseif partRandom <= 17 then
                                local dmg = 9
                                vehiclePart:damage(dmg)
                                local args = {x=square:getX(), y=square:getY(), id=vehiclePartId, dmg=dmg}
                                sendClientCommand(player, 'Commands', 'VehiclePartDamage', args)

                                square:playSound("HitVehiclePartWithWeapon")
                                if vehiclePart:getCondition() > 0 then
                                    return false
                                end
                            elseif partRandom <= 21 then
                                local dmg = 7
                                vehiclePart:damage(dmg)
                                local args = {x=square:getX(), y=square:getY(), id=vehiclePartId, dmg=dmg}
                                sendClientCommand(player, 'Commands', 'VehiclePartDamage', args)

                                if vehiclePart:getCondition() <= 0 then
                                    square:playSound("VehicleTireExplode")
                                end
                                return false
                            end

			                vehicle:updatePartStats()
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
            D = D - 2 * dx
        end
        D = D + 2 * dy
    end



    return true
end

ZombieActions.Shoot = {}
ZombieActions.Shoot.onStart = function(zombie, task)
    zombie:setBumpType(task.anim)
    return true
end

ZombieActions.Shoot.onWorking = function(zombie, task)
    zombie:faceLocationF(task.x, task.y)

    if task.time <= 0 then return true end

    if zombie:getBumpType() ~= task.anim then 
        zombie:setBumpType(task.anim)
    end

    return false
end

ZombieActions.Shoot.onComplete = function(zombie, task)

    local bumpType = zombie:getBumpType()
    if bumpType ~= task.anim then return true end

    local shooter = zombie
    local cell = shooter:getSquare():getCell()

    -- local item = InventoryItemFactory.CreateItem("Base.AssaultRifle2")
    -- ATROShoot(shooter, item)

    local brainShooter = BanditBrain.Get(shooter)
    local weapon = brainShooter.weapons[task.slot]
    weapon.bulletsLeft = weapon.bulletsLeft - 1
    Bandit.UpdateItemsToSpawnAtDeath(shooter)
    
    BanditCompatibility.StartMuzzleFlash(shooter)
    
    shooter:playSound(weapon.shotSound)

    --[[local te = FBORenderTracerEffects.getInstance()
    te:addEffect(shooter, 24)

    local test = shooter:getAnimationPlayer()
    local test2 = test:isReady()]]
    
    -- this adds world sound that attract zombies, it must be on cooldown
    -- otherwise too many sounds disorient zombies. 
    if not brainShooter.sound or brainShooter.sound == 0 then
        addSound(getPlayer(), shooter:getX(), shooter:getY(), shooter:getZ(), 40, 100)
        brainShooter.sound = 1
        -- BanditBrain.Update(shooter, brainShooter)
    end

    for dx=-2, 2 do
        for dy=-2, 2 do
            local square = cell:getGridSquare(task.x + dx, task.y + dy, task.z)

            if square then
                local victim

                if brainShooter.hostile then
                    victim = square:getPlayer()
                end

                if not victim and math.abs(dx) <= 1 and math.abs(dy) <= 1 then
                    local testVictim = square:getZombie()

                    if testVictim then
                        local brainVictim = BanditBrain.Get(testVictim)
                        if not brainVictim or not brainVictim.clan or brainShooter.clan ~= brainVictim.clan or (brainShooter.hostile and not brainVictim.hostile) then 
                            victim = testVictim
                        end
                    end
                end
                
                if victim then
                    if BanditUtils.GetCharacterID(shooter) ~= BanditUtils.GetCharacterID(victim) then 
                        local res = ManageLineOfFire(shooter, victim)
                        local finalCheck = BanditUtils.LineClear(shooter, victim)
                        if res and finalCheck then
                            local item = BanditCompatibility.InstanceItem(weapon.name)
                            Hit(shooter, item, victim)
                        end
                        zombie:setBumpDone(true)
                        return true
                        
                    end
                end
            end
        end
    end


    return true
end