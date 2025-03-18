ZombieActions = ZombieActions or {}

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

local function getProjectileCount(reloadType)
    local projectiles = 1
    if reloadType == "shotgun" or reloadType == "doublebarrelshotgun" or reloadType == "doublebarrelshotgunsawn" then
        projectiles = 5
    end
    return projectiles
end

local function hit(shooter, item, victim)

    -- Clone the shooter to create a temporary IsoPlayer
    local tempShooter = BanditUtils.CloneIsoPlayer(shooter)

    -- Calculate the distance between the shooter and the victim
    local dist = BanditUtils.DistTo(victim:getX(), victim:getY(), tempShooter:getX(), tempShooter:getY())

    -- Determine accuracy based on SandboxVars and shooter clan
    local brainShooter = BanditBrain.Get(shooter)
    local accuracyBoost = brainShooter.accuracyBoost or 1

    -- Logistic curve
    local function calculateHitChance(distance, accuracy)
        local baseChance = 9000  -- 90% hit chance at point blank
        local d50 = 16 + accuracy -- Distance where hit chance is 50%
        local k = 0.2   -- Steepness of falloff
        return baseChance / (1 + math.exp(k * (distance - d50)))
    end

    local accuracyLevelMap = {-5, -2, 0, 2, 5}
    local accuracyLevel = SandboxVars.Bandits.General_OverallAccuracy

    -- general sandbox setting for accuracy 
    local sightGeneral = accuracyLevelMap[accuracyLevel] or 0

    -- accuracy set in bandit creator
    local sightCharacter = brainShooter.accuracyBoost or 0

    -- individual accuracy set after spawn
    local sightIndividual = 0

    local accuracyThreshold = calculateHitChance(dist, sightGeneral + sightCharacter + sightIndividual)

    -- Warning, this is not perfect, local player mand remote players will not generate the same 
    -- random number.
    if ZombRand(10000) < accuracyThreshold then
        if instanceof(victim, "IsoPlayer") then
            BanditPlayer.WakeEveryone()

            local hitSound = "ZSHit" .. tostring(1 + ZombRand(3))
            victim:playSound(hitSound)

            BanditCompatibility.PlayerVoiceSound(victim, "PainFromFallHigh")
            victim:setHitFromBehind(shooter:isBehind(victim))

            victim:addBlood(0.6)
            BanditCompatibility.Splash(victim, item, tempShooter)
            
            local bodyDamage = victim:getBodyDamage()
            if bodyDamage then
                local health = bodyDamage:getOverallBodyHealth()
                health = health + 8
                if health > 100 then health = 100 end
                bodyDamage:setOverallBodyHealth(health)
            end
            
            if (victim:isSprinting() or victim:isRunning()) and ZombRand(12) == 1 then
                victim:clearVariable("BumpFallType")
                victim:setBumpType("stagger")
                victim:setBumpFall(true)
                victim:setBumpFallType("pushedBehind")
            end
            
        elseif instanceof(victim, "IsoZombie") then
            victim:setHitFromBehind(shooter:isBehind(victim))
            victim:setHitAngle(shooter:getForwardDirection())
            victim:setPlayerAttackPosition(victim:testDotSide(shooter))
            victim:Hit(item, tempShooter, 6, false, 1, false)
            victim:setAttackedBy(shooter)
            victim:addBlood(0.6)
            BanditCompatibility.Splash(victim, item, tempShooter)
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


local function manageLineOfFire (shooter, enemy, weaponItem)

    local cell = getCell()

    local x0 = math.floor(shooter:getX())
    local y0 = math.floor(shooter:getY())
    local x1 = math.floor(enemy:getX())
    local y1 = math.floor(enemy:getY())
    local z = enemy:getZ()

    local dx = math.abs(x1 - x0)
    local dy = math.abs(y1 - y0)
    local sx = (x0 < x1) and 1 or -1
    local sy = (y0 < y1) and 1 or -1
    local err = dx - dy

    local cx, cy, cz = x0, y0, z

    local vp = vehicleParts
    local snds = sounds
    local player = getSpecificPlayer(0)
    local piercing = weaponItem:isPiercingBullets()
    local projectiles = getProjectileCount(weaponItem:getWeaponReloadType())

    -- Bresenham's line of fire to detect what needs to destroyed between shooter and target
    local i = 0
    while true do

        -- last iterations
        local list = {}
        if cx == x1 and cy == y1 then
            for x = -2, 2 do
                for y = -2, 2 do
                    table.insert(list, {x = cx + x, y = cy + y, z=cz})
                end
            end
        else
            table.insert(list, {x=cx, y=cy, z=cz})
        end

        for _, c in pairs(list) do
            local square = cell:getGridSquare(c.x, c.y, c.z)
            if i > 1 and square then

                local obstacle

                -- manage wall obstacle
                local isWall = square:getWallFull()
                if isWall then
                    square:playSound("BulletImpact")
                    -- return false
                end

                -- manage window obstacle
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
                                return false
                            else -- wood
                                barricade:Thump(shooter)
                                local p = barricade:getNumPlanks()
                                if p >= 2 then
                                    square:playSound("HitBarricadePlank")
                                    return false
                                end
                            end
                        end
                        if not window:isSmashed() then
                            square:playSound("SmashWindow")
                            window:smashWindow()
                        end
                    end
                end

                -- manage for door obstacle
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
        
                            return false
                        end
                    end
                end

                -- manage vehicle obstacle
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
                                return false
                            end
        
                            vehicle:updatePartStats()
        
                            local args = {x=square:getX(), y=square:getY(), id=vehiclePartId, dmg=dmg}
                            sendClientCommand(player, 'Commands', 'VehiclePartDamage', args)
        
                        end
                    end
                end

                -- manage character "obstacles"
                local chrs = square:getMovingObjects()
                local wasHit = false
                for i=0, math.min(chrs:size()-1, projectiles) do
                    local chr = chrs:get(i)
                    if instanceof(chr, "IsoZombie") or instanceof(chr, "IsoPlayer") then
                        if BanditUtils.GetCharacterID(shooter) ~= BanditUtils.GetCharacterID(chr) then 
                            hit(shooter, weaponItem, chr)
                            wasHit = true
                        end
                    end
                end
                if not piercing and wasHit then return false end

            end
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
        i = i + 1
    end

    -- no bullet stop
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
    local sx, sy, sz, sd = shooter:getX(), shooter:getY(), shooter:getZ(), shooter:getDirectionAngle()
    local brainShooter = BanditBrain.Get(shooter)
    local weapon = brainShooter.weapons[task.slot]
    local weaponItem = BanditCompatibility.InstanceItem(weapon.name)

    local enemy = BanditZombie.Cache[task.eid] or BanditPlayer.GetPlayerById(task.eid)
    if not enemy then return true end

    -- deplete round
    weapon.bulletsLeft = weapon.bulletsLeft - 1
    Bandit.UpdateItemsToSpawnAtDeath(shooter)


    -- handle flash and projectile
    BanditCompatibility.StartMuzzleFlash(shooter)
    local reloadType = weaponItem:getWeaponReloadType()
    local projectiles = getProjectileCount(reloadType)
    BanditProjectile.Add(sx, sy, sz, sd, projectiles)

    -- handle real and "world" sound 
    local emitter = getWorld():getFreeEmitter(sx, sy, sz)
    emitter:playSound(weaponItem:getSwingSound())

    if not brainShooter.sound or brainShooter.sound == 0 then
        addSound(getSpecificPlayer(0), sx, sy, sz, 40, 100)
        brainShooter.sound = 1
    end

    -- manage line of fire damage to characters and objects
    if BanditUtils.LineClear(shooter, enemy) then
        manageLineOfFire(shooter, enemy, weaponItem)
    end

    -- handle post-shot things
    if not weaponItem:isManuallyRemoveSpentRounds() then
        shooter:playSound(weaponItem:getShellFallSound())
    end

    if weaponItem:isRackAfterShoot() then
        weapon.racked = false
    end

    return true
end