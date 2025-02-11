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
            if instanceof(victim, "IsoPlayer") and victim:isSprinting() or (victim:isRunning() and ZombRand(12) == 1) then
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
        victim:getSquare():playSound(missSound)
    end

    -- Clean up the temporary player after use
    tempShooter:removeFromWorld()
    tempShooter = nil

    return true
end

local vehicleParts = {
    [1] = {name="HeadlightLeft", dmg=18, sndHit="BreakGlassItem", sndDest="SmashWindow"},
    [2] = {name="HeadlightRight", dmg=18, sndHit="BreakGlassItem", sndDest="SmashWindow"},
    [3] = {name="HeadlightRearLeft", dmg=18, sndHit="BreakGlassItem", sndDest="SmashWindow"},
    [4] = {name="HeadlightRearRight", dmg=18, sndHit="BreakGlassItem", sndDest="SmashWindow"},
    [5] = {name="Windshield", dmg=20, sndHit="BreakGlassItem", sndDest="SmashWindow"},
    [6] = {name="WindshieldRear", dmg=20, sndHit="BreakGlassItem", sndDest="SmashWindow"},
    [7] = {name="WindowFrontRight", dmg=20, sndHit="BreakGlassItem", sndDest="SmashWindow"},
    [8] = {name="WindowFrontLeft", dmg=20, sndHit="BreakGlassItem", sndDest="SmashWindow"},
    [9] = {name="WindowRearRight", dmg=20, sndHit="BreakGlassItem", sndDest="SmashWindow"},
    [10] = {name="WindowRearLeft", dmg=20, sndHit="BreakGlassItem", sndDest="SmashWindow"},
    [11] = {name="WindowMiddleLeft", dmg=20, sndHit="BreakGlassItem", sndDest="SmashWindow"},
    [12] = {name="WindowMiddleRight", dmg=20, sndHit="BreakGlassItem", sndDest="SmashWindow"},
    [13] = {name="DoorFrontRight", dmg=10, sndHit="HitVehiclePartWithWeapon", sndDest="HitVehiclePartWithWeapon"},
    [14] = {name="DoorFrontLeft", dmg=10, sndHit="HitVehiclePartWithWeapon", sndDest="HitVehiclePartWithWeapon"},
    [15] = {name="DoorRearRight", dmg=10, sndHit="HitVehiclePartWithWeapon", sndDest="HitVehiclePartWithWeapon"},
    [16] = {name="DoorRearLeft", dmg=10, sndHit="HitVehiclePartWithWeapon", sndDest="HitVehiclePartWithWeapon"},
    [17] = {name="EngineDoor", dmg=10, sndHit="HitVehiclePartWithWeapon", sndDest="HitVehiclePartWithWeapon"},
    [18] = {name="TireFrontRight", dmg=8, sndHit="VehicleTireExplode", sndDest="VehicleTireExplode"},
    [19] = {name="TireFrontLeft", dmg=8, sndHit="VehicleTireExplode", sndDest="VehicleTireExplode"},
    [20] = {name="TireRearLeft", dmg=8, sndHit="VehicleTireExplode", sndDest="VehicleTireExplode"},
    [21] = {name="TireRearRight", dmg=8, sndHit="VehicleTireExplode", sndDest="VehicleTireExplode"}
}

local sounds = {
    ["WoodDoor"] = "HitBarricadePlank",
    ["MetalDoor"] = "HitBarricadeMetal",
}
-- Bresenham's line of fire to detect what needs to destroyed between shooter and target

local function thump (object, thumper)
    local health = object:getHealth()
    print ("thumpable health: " .. object:getHealth())
    health = health - 20
    if health < 0 then health = 0 end
    if health == 0 then
        object:destroy()
    else
        object:setHealth(health)
        object:Thump(thumper)
    end
end

local function ManageLineOfFire (shooter, victim)
    local cell = getCell()

    local x0 = math.floor(shooter:getX())
    local y0 = math.floor(shooter:getY())
    local x1 = math.floor(victim:getX())
    local y1 = math.floor(victim:getY())
    local z = victim:getZ()

    local dx = math.abs(x1 - x0)
    local dy = math.abs(y1 - y0)
    local sx = (x0 < x1) and 1 or -1
    local sy = (y0 < y1) and 1 or -1
    local err = dx - dy

    local cx, cy, cz = x0, y0, z

    local function checkWindow(square, shooter)
        local window = square:getWindow()
        if window then
            if (window:getNorth() and (y0 < cy or y1 < cy)) or 
               (not window:getNorth() and (x0 < cx or x1 < cx)) then
                local barricade = window:getBarricadeOnSameSquare()
                if not barricade then
                    barricade = window:getBarricadeOnOppositeSquare()
                end
                local smash = false
                if barricade then
                    if barricade:isMetal() then
                        barricade:Thump(shooter)
                        square:playSound("HitBarricadeMetal")
                        return true
                    else -- wood
                        barricade:Thump(shooter)
                        local p = barricade:getNumPlanks()
                        if p >= 2 then
                            square:playSound("HitBarricadePlank")
                            return true
                        end
                    end
                end
                if not window:isSmashed() then
                    square:playSound("SmashWindow")
                    window:smashWindow()
                end
            end
        end
        return false
    end

    local function checkDoor(square, shooter)
        local snds = sounds
        local door = square:getIsoDoor()
        if door and not door:IsOpen() then
            if (door:getNorth() and (y0 < cy or y1 < cy)) or 
               (not door:getNorth() and (x0 < cx or x1 < cx)) then
                -- small chance to shoot through a small window in door
                if ZombRand(10) > 1 then 
                    local sprite = door:getSprite()
                    local props = sprite:getProperties()
                    if props:Is("DoorSound") then
                        doorSound = props:Val("DoorSound")
                        if snds[doorSound] then
                            square:playSound(snds[doorSound])
                        end
                    end

                    thump(door, shooter)
                    
                    return true
                end
            end
        end
        return false
    end

    local function checkVehicle(square, shooter)
        local player = getPlayer()
        local vp = vehicleParts
        local vehicle = square:getVehicleContainer()
        if vehicle then
            local partRandom = ZombRand(30)
            local vehiclePart
            local dmg
            if vp[partRandom] then
                vehiclePart = vehicle:getPartById(vp[partRandom].name)
                if vehiclePart and vehiclePart:getInventoryItem() then
                    
                    local vehiclePartId = vehiclePart:getId()

                    local dmg = vp[partRandom].dmg
                    vehiclePart:damage(dmg)

                    if vehiclePart:getCondition() <= 0 then
                        vehiclePart:setInventoryItem(nil)
                        square:playSound(vp[partRandom].sndDest)
                    else
                        square:playSound(vp[partRandom].sndHit)
                        return true
                    end

                    vehicle:updatePartStats()
                    
                    local args = {x=square:getX(), y=square:getY(), id=vehiclePartId, dmg=dmg}
                    sendClientCommand(player, 'Commands', 'VehiclePartDamage', args)
                    
                end
            end
        end
        return false
    end

    while true do
        
        local square = cell:getGridSquare(cx, cy, cz)
        if square then

            local obstacle
            -- manage window obstacle
            obstacle = checkWindow(square, shooter)
            if obstacle then return false end

            -- manage for door obstacle
            obstacle = checkDoor(square, shooter)
            if obstacle then return false end

            -- manage vehicle obstacle
            obstacle = checkVehicle(square, shooter)
            if obstacle then return false end
            
        end

        if cx == x1 and cy == y1 then break end
        local e2 = 2 * err
        if e2 > -dy then
            err = err - dy
            cx = cx + sx
        end
        if e2 < dx then
            err = err + dx
            cy = cy + sy
        end
    end
    
    -- no bullet stop
    return true
end


local function ManageLineOfFire2 (shooter, victim)
    local cell = getCell()
    local player = getPlayer()
    local vp = vehicleParts
    local x0 = math.floor(shooter:getX())
    local y0 = math.floor(shooter:getY())
    local x1 = math.floor(victim:getX())
    local y1 = math.floor(victim:getY())

    if x0 > x1 then x0, x1 = x1, x0 end
    if y0 > y1 then y0, y1 = y1, y0 end

    local dx = x1 - x0
    local dy = y1 - y0
    local D = 2 * dy - dx
    local y = y0
    
    for x = x0, x1 do
        -- for sx = -1, 1 do
            -- for sy = -1, 1 do

                local square = cell:getGridSquare(x, y, 0)

                if square then

                    local sx = square:getX()
                    local sy = square:getY()
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
                        local dmg
                        if vp[partRandom] then
                            vehiclePart = vehicle:getPartById(vp[partRandom].name)
                            if vehiclePart and vehiclePart:getInventoryItem() then
                                
                                local vehiclePartId = vehiclePart:getId()

                                local dmg = vp[partRandom].dmg
                                vehiclePart:damage(dmg)

                                local gothrough = true
                                if vehiclePart:getCondition() <= 0 then
                                    vehiclePart:setInventoryItem(nil)
                                    square:playSound(vp[partRandom].sndDest)
                                else
                                    square:playSound(vp[partRandom].sndHit)
                                    gothrough = false
                                end

                                vehicle:updatePartStats()
                                
                                local args = {x=square:getX(), y=square:getY(), id=vehiclePartId, dmg=dmg}
                                sendClientCommand(player, 'Commands', 'VehiclePartDamage', args)
                                
                                if not gothrough then return end
                            end
                        end
                    end

                    -- cant shoot through the closed door (although bandits can see through them)
                    local door = square:getIsoDoor()
                    if door and not door:IsOpen() then
                        if door:getNorth() then
                            if y0 < sy or y1 < sy then
                                return false
                            end
                        end
                    end
                end
            -- end
        -- end

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