ZombieActions = ZombieActions or {}

local function Hit (attacker, item, victim)
    local dist = math.sqrt(math.pow(attacker:getX() - victim:getX(), 2) + math.pow(attacker:getY() - victim:getY(), 2))
    -- print ("RANGE:" .. item:getMaxRange() .. " DIST:" .. dist)
    if dist < item:getMaxRange() + 0.4 then
        local veh = victim:getVehicle()
        
        local hitSound
        if veh then
            hitSound = "HitVehicleWindowWithWeapon"
        else
            victim:Hit(item, attacker, 10 + ZombRand(40), false, 1, false)
            victim:addBlood(0.6)
            SwipeStatePlayer.splash(victim, item, attacker)
            hitSound = item:getZombieHitSound()
        end
        victim:playSound(hitSound)
    end
end

ZombieActions.Hit = {}
ZombieActions.Hit.onStart = function(zombie, task)
    local anim = false

    if task.prone then
        local attacks = {"Attack2HFloor", "Attack2HStamp"}
        anim = attacks[1+ZombRand(#attacks)]
    else
        local hands = zombie:getVariableString("BanditPrimaryType")
        local attacks = false
        if hands == "twohanded" then
            attacks = {"Attack2H1", "Attack2H2", "Attack2H3", "Attack2H4"}
        elseif hands == "heavy" then
            attacks = {"Attack2HHeavy1", "Attack2HHeavy2"}
        elseif hands == "onehanded" then
            attacks = {"Attack1H1", "Attack1H2", "Attack1H3", "Attack1H4", "Attack1H5"}
        elseif hands == "spear" then
            attacks = {"AttackS1", "AttackS2"}
        else
            print ("this should not happen")
        end
        if attacks then 
            anim = attacks[1+ZombRand(#attacks)]
            -- print (anim)
        end
    end

    if anim then
        zombie:setBumpType(anim)
    else
        return false
    end

    return true
end

ZombieActions.Hit.onWorking = function(zombie, task)
    zombie:faceLocation(task.x, task.y)

    if task.time == 50 then
        local cell = zombie:getSquare():getCell()
        local square = cell:getGridSquare(task.x, task.y, task.z)
        if square then
            local item = InventoryItemFactory.CreateItem(task.weapon)
            
            local enemy = square:getZombie()
            if enemy then
                local brainAttacker = BanditBrain.Get(zombie)
                local brainEnemy = BanditBrain.Get(enemy)
                if not brainEnemy or not brainEnemy.clan or brainAttacker.clan ~= brainEnemy.clan then 
                    Hit (zombie, item, enemy)
                end
            end

            if Bandit.IsHostile(zombie) then
                local player = square:getPlayer()
                if player then
                    Hit (zombie, item, player)
                end
            end
        end
        return false
    elseif task.time < 50 then

        local asn = zombie:getActionStateName()
        if asn == "bumped" then
            return false
        else
            return true
        end
    end
    return false
end

ZombieActions.Hit.onComplete = function(zombie, task)
    return true
end