ZombieActions = ZombieActions or {}

local function Hit(attacker, item, victim)
    -- Clone the attacker to create a temporary IsoPlayer
    local tempAttacker = BanditUtils.CloneIsoPlayer(attacker)

    -- Calculate distance between attacker and victim
    local dist = math.sqrt(math.pow(tempAttacker:getX() - victim:getX(), 2) + math.pow(tempAttacker:getY() - victim:getY(), 2))
    
    if dist < item:getMaxRange() then
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
            victim:Hit(item, tempAttacker, 10 + ZombRand(40), false, 1, false)
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
        bandit:setBumpType(anim)
    else
        return false
    end

    return true
end

ZombieActions.Hit.onWorking = function(bandit, task)
    bandit:faceLocation(task.x, task.y)

    if task.time == 45 then
        local item = InventoryItemFactory.CreateItem(task.weapon)
        local cell = getCell()
        local enemyList = cell:getZombieList()
        for i=0, enemyList:size()-1 do
            local enemy = enemyList:get(i)
            if enemy then
                local eid = BanditUtils.GetCharacterID(enemy)
                if enemy:isAlive() and eid == task.eid then
                    local brainBandit = BanditBrain.Get(bandit)
                    local brainEnemy = BanditBrain.Get(enemy)
                    if not brainEnemy or not brainEnemy.clan or brainBandit.clan ~= brainEnemy.clan or (brainBandit.hostile and not brainEnemy.hostile) then 
                        Hit (bandit, item, enemy)
                        return false
                    end
                end
            end
        end

        local world = getWorld()
        local gamemode = world:getGameMode()
        local playerList = {}
        if gamemode == "Multiplayer" then
            playerList = getOnlinePlayers()
        else
            playerList = IsoPlayer.getPlayers()
        end
 
        if Bandit.IsHostile(bandit) then
            for i=0, playerList:size()-1 do
                local player = playerList:get(i)
                if player then
                    local eid = BanditUtils.GetCharacterID(player)
                    if player:isAlive() and eid == task.eid then
                        Hit (bandit, item, player)
                        return false
                    end
                end
            end
        end
        return false

    elseif task.time < 50 then

        if not bandit:getVariableString("BumpAnimFinished") then
            return false
        else
            return true
        end
    end
    return false
end

ZombieActions.Hit.onComplete = function(bandit, task)
    return true
end