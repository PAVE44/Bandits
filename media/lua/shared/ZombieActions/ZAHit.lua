ZombieActions = ZombieActions or {}

local function Hit(attacker, item, victim)
    -- Clone the attacker to create a temporary IsoPlayer
    local tempAttacker = BanditUtils.CloneIsoPlayer(attacker)

    -- Calculate distance between attacker and victim
    local dist = math.sqrt(math.pow(tempAttacker:getX() - victim:getX(), 2) + math.pow(tempAttacker:getY() - victim:getY(), 2))
    local range = item:getMaxRange()
    if dist < range + 0.1 then
        victim:forceAwake()

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
                victim:Hit(item, tempAttacker, 3, false, 1, false)
                local bodyDamage = victim:getBodyDamage()
                if bodyDamage then
                    local health = bodyDamage:getOverallBodyHealth()
                    health = health + 8
                    if health > 100 then health = 100 end
                    bodyDamage:setOverallBodyHealth(health)
                end
            end
            victim:addBlood(0.6)
            SwipeStatePlayer.splash(victim, item, tempAttacker)

            if victim:getHealth() <= 0 then 
                victim:Kill(getCell():getFakeZombieForHit(), true) 
            end
        end
        victim:playSound(hitSound)
    end

    -- Clean up the temporary player after use
    tempAttacker:removeFromWorld()
    tempAttacker = nil
end

ZombieActions.Hit = {}
ZombieActions.Hit.onStart = function(bandit, task)
    local anim = false

    if task.prone then
        local attacks = {"Attack2HFloor", "Attack2HStamp"}
        anim = attacks[1+ZombRand(#attacks)]
    else
        local meleeItem = InventoryItemFactory.CreateItem(task.weapon)
        local meleeItemType = WeaponType.getWeaponType(meleeItem)

        local hands = bandit:getVariableString("BanditPrimaryType")
        local attacks = false
        if meleeItemType == WeaponType.twohanded then
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

        --[[
        if bandit:isPrimaryEquipped("AuthenticZClothing.Chainsaw") then
            attacks = {"AttackChainsaw1", "AttackChainsaw2"}
        end]]

        if attacks then 
            anim = attacks[1+ZombRand(#attacks)]
            -- print (anim)
        end
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

    if task.time == 51 then
        local item = InventoryItemFactory.CreateItem(task.weapon)
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
            local playerList = BanditPlayer.GetPlayers()
            for i=0, playerList:size()-1 do
                local player = playerList:get(i)
                if player then
                    local eid = BanditUtils.GetCharacterID(player)
                    if player:isAlive() and eid == task.eid then
                        Hit (bandit, item, player)
                        if task.weapon ~= "AuthenticZClothing.Chainsaw" then return false end
                    end
                end
            end
        end
        return false

    end
    
    if bandit:getVariableString("BumpAnimFinished") then
        return true
    end

    return false
end

ZombieActions.Hit.onComplete = function(bandit, task)
    return true
end