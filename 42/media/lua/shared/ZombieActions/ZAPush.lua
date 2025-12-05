ZombieActions = ZombieActions or {}

local function ShovePlayer (attacker, player)
    local facing = player:isFacingObject(attacker, 0.5)

    player:clearVariable("BumpFallType")
    player:setBumpType("stagger")

    if BanditUtils.BanditRand(3) == 1 then
        player:setBumpFall(true)
    else
        player:setBumpFall(false)
    end

    if facing then
        player:setBumpFallType("pushedFront")
    else
        player:setBumpFallType("pushedBehind")
    end
end

local function ShoveZombie (attacker, zombie)
    local facing = zombie:isFacingObject(attacker, 0.5)
    zombie:setOnFloor(true)
    if facing then
        -- zombie:setBumpType("ZombiePushedFront")
        --[[
        zombie:setStaggerBack(true)
        zombie:setKnockedDown(true)
        zombie:setHitReaction("ShotBelly")
        ]]
        
        
        zombie:setFallOnFront(false)
    else
        zombie:setFallOnFront(true)
        -- zombie:setBumpType("ZombiePushedBack")
    end
    zombie:setKnockedDown(true)
end

ZombieActions.Push = {}
ZombieActions.Push.onStart = function(bandit, task)

    local anim = "Shove"

    if anim then
        task.anim = anim
        bandit:setBumpType(anim)
    else
        return false
    end

    return true
end

ZombieActions.Push.onWorking = function(bandit, task)
    bandit:faceLocation(task.x, task.y)

    local bumpType = bandit:getBumpType()
    if bumpType ~= task.anim then return false end

    if not task.hit and task.time <= 40 then

        task.hit = true

        local asn = bandit:getActionStateName()
        -- print ("SHOVE AS:" .. asn)
        if asn == "getup" or asn == "getup-fromonback" or asn == "getup-fromonfront" or asn == "getup-fromsitting"
                 or asn =="staggerback" or asn == "staggerback-knockeddown" or asn == "falldown" then return false end

        local enemy = BanditZombie.Cache[task.eid]
        if enemy then 
            local brainBandit = BanditBrain.Get(bandit)
            local brainEnemy = BanditBrain.Get(enemy)
            if BanditUtils.AreEnemies(brainEnemy, brainBandit) then
            -- if not brainEnemy or not brainEnemy.clan or brainBandit.clan ~= brainEnemy.clan or (brainBandit.hostile and not brainEnemy.hostile) then 
                ShoveZombie (bandit, enemy)
            end
        end

        if Bandit.IsHostile(bandit) then
            local playerList = BanditPlayer.GetPlayers()
            for i=0, playerList:size()-1 do
                local player = playerList:get(i)
                if player then
                    local eid = BanditUtils.GetCharacterID(player)
                    if player:isAlive() and eid == task.eid then
                        ShovePlayer (bandit, player)
                    end
                end
            end
        end
    end
    return false
end

ZombieActions.Push.onComplete = function(bandit, task)
    return true
end