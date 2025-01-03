ZombieActions = ZombieActions or {}

local function Hit(attacker, item, victim)
    -- Clone the attacker to create a temporary IsoPlayer
    local tempAttacker = BanditUtils.CloneIsoPlayer(attacker)

    -- Calculate distance between attacker and victim
    local dist = BanditUtils.DistTo(victim:getX(), victim:getY(), tempAttacker:getX(), tempAttacker:getY())
    local range = item:getMaxRange()
    if dist < range + 0.2 then
        BanditPlayer.WakeEveryone()

        local hitSound
        local veh = victim:getVehicle()
        
        if veh then
            hitSound = "HitVehicleWindowWithWeapon"
        else
            local chainsaw = tempAttacker:isPrimaryEquipped("AuthenticZClothing.Chainsaw")
            if chainsaw then
                hitSound = "BloodSplatter"
            else
                hitSound = item:getZombieHitSound()
            end
            if victim:isSprinting() or victim:isRunning() and ZombRand(5) == 1 then
                victim:clearVariable("BumpFallType")
                victim:setBumpType("stagger")
                victim:setBumpFall(true)
                victim:setBumpFallType("pushedBehind")
            else
                victim:setHitFromBehind(attacker:isBehind(victim))

                if instanceof(victim, "IsoZombie") then
                    victim:setHitAngle(attacker:getForwardDirection())
                    victim:setPlayerAttackPosition(victim:testDotSide(attacker))
                end

                victim:Hit(item, tempAttacker, 3, false, 1, false)
                victim:setAttackedBy(attacker)
                local bodyDamage = victim:getBodyDamage()
                if bodyDamage then
                    local health = bodyDamage:getOverallBodyHealth()
                    health = health + 12
                    if health > 100 then health = 100 end
                    bodyDamage:setOverallBodyHealth(health)
                end
            end
            victim:addBlood(0.6)
            
            local splatNo = item:getSplatNumber()
            for i=0, splatNo do
                victim:splatBlood(3, 0.3)
            end
            victim:splatBloodFloorBig()
            victim:playBloodSplatterSound()
            if instanceof(victim, "IsoPlayer") then
                victim:playerVoiceSound("PainFromFallHigh")
            end

            if victim:getHealth() <= 0 then 
                victim:Kill(getCell():getFakeZombieForHit(), true) 
            end
        end
        victim:playSound(hitSound)
        -- addSound(getPlayer(), victim:getX(), victim:getY(), victim:getZ(), 4, 50)
    end

    -- Clean up the temporary player after use
    tempAttacker:removeFromWorld()
    tempAttacker = nil
end

ZombieActions.Hit = {}
ZombieActions.Hit.onStart = function(bandit, task)
    local anim 
    local sound

    local enemy = BanditZombie.GetInstanceById(task.eid) or BanditPlayer.GetPlayerById(task.eid)
    if not enemy then return true end
    
    local prone = enemy:isProne() or enemy:getActionStateName() == "onground" or enemy:getActionStateName() == "sitonground" or enemy:getActionStateName() == "climbfence" or enemy:getBumpFallType() == "pushedFront" or enemy:getBumpFallType() == "pushedBehind"
    local meleeItem = instanceItem(task.weapon)
    local meleeItemType = WeaponType.getWeaponType(meleeItem)

    local sound = meleeItem:getSwingSound()
    if bandit:isPrimaryEquipped("AuthenticZClothing.Chainsaw") then
        local emitter = bandit:getEmitter()
        emitter:stopSoundByName("ChainsawIdle")
        sound = "ChainsawAttack1"
    end

    if prone then
        if ZombRand(2) == 0 then
            anim = "Attack2HFloor"
        else
            anim = "Attack2HStamp"
            sound = "AttackStomp"
        end
    else

        local attacks
        if task.weapon == "Base.BareHands" or meleeItemType == WeaponType.barehand then
            attacks = {"AttackBareHands1", "AttackBareHands2", "AttackBareHands3", "AttackBareHands4", "AttackBareHands5", "AttackBareHands6"}
        elseif meleeItemType == WeaponType.twohanded then
            attacks = {"Attack2H1", "Attack2H2", "Attack2H3", "Attack2H4"}
        -- elseif meleeItemType == WeaponType.heavy then
        --    attacks = {"Attack2HHeavy1", "Attack2HHeavy2"}
        elseif meleeItemType == WeaponType.onehanded then
            attacks = {"Attack1H1", "Attack1H2", "Attack1H3", "Attack1H4", "Attack1H5"}
        elseif meleeItemType == WeaponType.spear then
            attacks = {"AttackS1", "AttackS2"}
        elseif meleeItemType == WeaponType.chainsaw then
            attacks = {"AttackChainsaw1", "AttackChainsaw2"}
        else -- two handed / knife ?
            attacks = {"Attack2H1", "Attack2H2", "Attack2H3", "Attack2H4"}
        end

        if attacks then 
            anim = attacks[1+ZombRand(#attacks)]

        end
    end

    if sound then
        bandit:playSound(sound)
    end

    if anim then
        task.anim = anim
        Bandit.UpdateTask(bandit, task)
        bandit:setBumpType(anim)
    else
        return false
    end
    return true
end

ZombieActions.Hit.onWorking = function(bandit, task)
    bandit:faceLocation(task.x, task.y)
    local bumpType = bandit:getBumpType()

    if bumpType ~= task.anim then return false end
    
    if not task.hit and task.time <= 50 then
        task.hit = true
        Bandit.UpdateTask(bandit, task)

        local item = instanceItem(task.weapon)
        local enemy = BanditZombie.GetInstanceById(task.eid)
        if enemy then 
            local brainBandit = BanditBrain.Get(bandit)
            local brainEnemy = BanditBrain.Get(enemy)
            if not brainEnemy or not brainEnemy.clan or brainBandit.clan ~= brainEnemy.clan or (brainBandit.hostile and not brainEnemy.hostile) then 
                Hit (bandit, item, enemy)
                if task.weapon ~= "AuthenticZClothing.Chainsaw" then return false end
            end
        end

        if Bandit.IsHostile(bandit) then
            local player = BanditPlayer.GetPlayerById(task.eid)
            if player then
                local eid = BanditUtils.GetCharacterID(player)
                if player:isAlive() and eid == task.eid then
                    Hit (bandit, item, player)
                    if task.weapon ~= "AuthenticZClothing.Chainsaw" then return false end
                end
            end
        end

        return false

    end
    
    return false
end

ZombieActions.Hit.onComplete = function(bandit, task)
    return true
end