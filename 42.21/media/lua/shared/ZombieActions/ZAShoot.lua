--[[
rework

 - firing animations
 - need to detect short and long burts based on weapon
 - shooting angle should be used for multifloor 
 - there are no long shoot animations for upper floor for handgun
 - rifle full auto animation need to be cut

 - logic needs to change:

onStart
 - first compute landing square based on char stats like accuracy, global sandbox settings and chance, chance should be deterministic based on rnd[3] and game minute, and bullets left
 - weapon reloads should sync weapons in brains for multiplayer sync
 - projectile starts 
 - animation start
 - based on distance a bullet landing realization is calculated
 - shoot sound

onWaiting
 - onWaiting realizes bullet reaching the target in the precalculated tick,
 - does not repeat animation

onCOmplete 
 - world sound atraction with cooldown
 - spent round sound
 
 ]]
ZombieActions = ZombieActions or {}

ZombieActions.Shoot = {}
ZombieActions.Shoot.onStart = function(bandit, task)

    local brain = BanditBrain.Get(bandit)
    local bx, by, bz, bd = bandit:getX(), bandit:getY(), bandit:getZ(), bandit:getDirectionAngle()

    local weapon = brain.weapons[task.slot]
    local weaponItem = BanditCompatibility.InstanceItem(weapon.name)
    weaponItem = BanditUtils.ModifyWeapon(weaponItem, brain)

    -- establish animation time
    local recoilDelay = weaponItem:getRecoilDelay()
    task.recoilDelay = recoilDelay
    task.tick = recoilDelay

    -- fire tick
    local fireDelay = 1
    task.tickFire = task.recoilDelay - fireDelay

    -- shell ground tick
    if not weaponItem:isManuallyRemoveSpentRounds() then
        local shellDelay = 50
        task.tickShell = task.recoilDelay - fireDelay - shellDelay
    end

    -- remember enemy location
    local enemy = BanditZombie.Cache[task.eid] or BanditPlayer.GetPlayerById(task.eid)
    if not enemy then return true end
    local ex, ey, ez = enemy:getX(), enemy:getY(), enemy:getZ()
    bandit:faceLocationF(ex, ey)

    -- establish bullet landing tick
    -- local dist = BanditUtils.DistTo(bx, by, task.ex, task.ey)
    local reachDelay = 2 -- math.floor(dist / 5)
    task.tickAtTarget = task.recoilDelay - fireDelay - reachDelay

    -- handle animation
    local weaponType = WeaponType.getWeaponType(weaponItem)
    if weaponType == WeaponType.FIREARM then
        task.anim2 = "AimRifle"
        if weaponItem:getFireMode() == "Auto" then
            task.anim = "AttackRifleSmallAuto"
            task.auto = true
        else
            if recoilDelay >= 28 then
                task.anim = "AttackRifle"
            else
                task.anim = "AttackRifleSmall"
            end
        end
    elseif weaponType == WeaponType.HANDGUN then
        task.anim2 = "AimPistol"
        if recoilDelay >= 15 then
            task.anim = "AttackHandgun"
        else
            task.anim = "AttackHandgunSmall"
        end
    end
    bandit:setBumpType(task.anim)

    -- apply a slight random offset to the firing direction (degrees)
    local maxAimOffset = 5
    if task.auto then
        maxAimOffset = maxAimOffset * 1.8
    end
    local aimOffset = ZombRandFloat(0, 2 * maxAimOffset) - maxAimOffset
    task.fireAngle = bandit:getDirectionAngle() + aimOffset

    -- calculate target point
    local offsetRad = math.rad(aimOffset)
    task.cosO, task.sinO = math.cos(offsetRad), math.sin(offsetRad)

    -- weapon:getStopPower() [float]

    return true
end

ZombieActions.Shoot.onWorking = function(bandit, task)
    if bandit:getBumpType() ~= task.anim then 
        local elapsed = 1000 - task.time
        local reqTime = task.recoilDelay
        if task.auto then
            reqTime = reqTime * 0.25
        end
        if elapsed > reqTime then
            return true 
        else
            bandit:setBumpType(task.anim2)
        end
    end

    local enemy = BanditZombie.Cache[task.eid] or BanditPlayer.GetPlayerById(task.eid)
    if not enemy then return true end

    local ex, ey, ez = enemy:getX(), enemy:getY(), enemy:getZ()
    local bx, by, bz = bandit:getX(), bandit:getY(), bandit:getZ()

    local dx, dy = ex - bx, ey - by
    local tx = bx + dx * task.cosO - dy * task.sinO
    local ty = by + dx * task.sinO + dy * task.cosO
    local tz = ez

    -- bandit:faceLocationF(tx, ty)
    
    if task.tick == task.tickFire then
        local brain = BanditBrain.Get(bandit)

        -- handle sound
        local bx, by, bz = bandit:getX(), bandit:getY(), bandit:getZ()
        local weapon = brain.weapons[task.slot]
        local weaponItem = BanditCompatibility.InstanceItem(weapon.name)
        weaponItem = BanditUtils.ModifyWeapon(weaponItem, brain)

        local emitter = getWorld():getFreeEmitter(bx, by, bz)
        -- local emitter = bandit:getEmitter()
        local swingSound = weaponItem:getSwingSound()
        -- emitter:stopAll()
        emitter:playSound(swingSound)
        -- emitter:setParameterValueByName(long, "CameraZoom", 1.0)

        -- update weapon stats here
        weapon.bulletsLeft = weapon.bulletsLeft - 1
        if weaponItem:isRackAfterShoot() then
            weapon.racked = false
        end
        if weapon.bulletsLeft <= 0 then
            --weapon.racked = false
        end

        -- handle flash and projectile
        BanditCompatibility.StartMuzzleFlash(bandit)
        local reloadType = weaponItem:getWeaponReloadType()
        local projectiles = BanditUtils.GetProjectileCount(reloadType)
        BanditProjectile.Add(brain.id, bx, by, bz, task.fireAngle, projectiles)

        if not brain.shotCooldown or brain.shotCooldown + 5000 < getTimestampMs() then
            local radius = weaponItem:getSoundRadius()
            local volume = weaponItem:getSoundVolume()
            local zombieList = BanditZombie.CacheLightZ
            for id, zombie in pairs(zombieList) do
                local dist = math.abs(bx - zombie.x) + math.abs(by - zombie.y)
                if dist < radius then
                    local zombie = BanditZombie.Cache[id]
                    if zombie and not zombie:isMoving() then
                        local asn = zombie:getActionStateName()
                        if asn == "idle" then
                            zombie:spottedNew(bandit, true)
                            zombie:addAggro(bandit, 1)
                            zombie:setTarget(bandit)
                        end
                    end
                end
            end
            brain.shotCooldown = getTimestampMs()
        end

        -- print (task.tick .. " FIRE "  .. task.anim)
    elseif task.tick == task.tickAtTarget then
        local brain = BanditBrain.Get(bandit)
        local weapon = brain.weapons[task.slot]
        local weaponItem = BanditCompatibility.InstanceItem(weapon.name)
        weaponItem = BanditUtils.ModifyWeapon(weaponItem, brain)

        if BanditUtils.LineClear(bandit, enemy) then
            BanditUtils.ManageLineOfFire(bandit, math.floor(tx), math.floor(ty), math.floor(tz), weaponItem)
        end
    elseif task.tick == task.tickShell then
        local bx, by, bz = bandit:getX(), bandit:getY(), bandit:getZ()
        local brain = BanditBrain.Get(bandit)
        local weapon = brain.weapons[task.slot]
        local weaponItem = BanditCompatibility.InstanceItem(weapon.name)
        weaponItem = BanditUtils.ModifyWeapon(weaponItem, brain)
        local emitter = getWorld():getFreeEmitter(bx, by, bz)
        local shellFallSound = weaponItem:getShellFallSound()
        emitter:playSound(shellFallSound)
    else
        -- print (task.tick .. " VOID " .. task.anim)
    end
    
    task.tick = task.tick - 1

    return false
end

ZombieActions.Shoot.onCompleteOld = function(bandit, task)

    --[[
    local bumpType = bandit:getBumpType()
    if bumpType ~= task.anim then return true end

    local shooter = bandit
    local sx, sy, sz, sd = shooter:getX(), shooter:getY(), shooter:getZ(), shooter:getDirectionAngle()
    local brainShooter = BanditBrain.Get(shooter)
    local weapon = brainShooter.weapons[task.slot]
    local weaponItem = BanditCompatibility.InstanceItem(weapon.name)
    if not weaponItem then return true end

    weaponItem = BanditUtils.ModifyWeapon(weaponItem, brainShooter)

    local enemy = BanditZombie.Cache[task.eid] or BanditPlayer.GetPlayerById(task.eid)
    if not enemy then return true end

    if not BanditUtils.IsFacing(sx, sy, sd, enemy:getX(), enemy:getY(), 5) then 
        return true
    end

    -- deplete round
    weapon.bulletsLeft = weapon.bulletsLeft - 1
    -- Bandit.UpdateItemsToSpawnAtDeath(shooter, brainShooter)

    -- apply a slight random offset to the firing direction (degrees)
    local maxAimOffset = 5
    local aimOffset = ZombRandFloat(0, 2 * maxAimOffset) - maxAimOffset
    local fireAngle = sd + aimOffset

    -- rotate the shooter->enemy vector by the aim offset to get the actual impact point
    local ex, ey, ez = enemy:getX(), enemy:getY(), enemy:getZ()
    local offsetRad = math.rad(aimOffset)
    local cosO, sinO = math.cos(offsetRad), math.sin(offsetRad)
    local dx, dy = ex - sx, ey - sy
    local tx = sx + dx * cosO - dy * sinO
    local ty = sy + dx * sinO + dy * cosO
    local tz = ez

    -- handle flash and projectile
    BanditCompatibility.StartMuzzleFlash(shooter)
    local reloadType = weaponItem:getWeaponReloadType()
    local projectiles = BanditUtils.GetProjectileCount(reloadType)
    BanditProjectile.Add(brainShooter.id, sx, sy, sz, fireAngle, projectiles)

    -- handle real and "world" sound 
    -- local emitter = getWorld():getFreeEmitter(sx, sy, sz)
    local emitter = shooter:getEmitter()
    local swingSound = weaponItem:getSwingSound()
    -- emitter:stopAll()
    local long = emitter:playSound(swingSound)
    -- emitter:setParameterValueByName(long, "CameraZoom", 1.0)

    -- alert nearby zombies
    

    -- manage line of fire damage to characters and objects
    if BanditUtils.LineClear(shooter, enemy) then
        BanditUtils.ManageLineOfFire(shooter, math.floor(tx), math.floor(ty), math.floor(tz), weaponItem)
    end

    -- handle post-shot things
    if not weaponItem:isManuallyRemoveSpentRounds() then
        shooter:playSound(weaponItem:getShellFallSound())
    end

    if weaponItem:isRackAfterShoot() then
        weapon.racked = false
    end

    ]]

    return true
end