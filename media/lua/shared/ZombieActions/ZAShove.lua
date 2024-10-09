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
    if facing then
        zombie:setBumpType("ZombiePushedFront")
    else
        zombie:setBumpType("ZombiePushedBack")
    end
end

ZombieActions.Shove = {}
ZombieActions.Shove.onStart = function(bandit, task)

    local anim = "Shove"

    if anim then
        task.anim = anim
        Bandit.UpdateTask(bandit, task)
        bandit:setBumpType(anim)
    else
        return false
    end

    return true
end

ZombieActions.Shove.onWorking = function(bandit, task)
    bandit:faceLocation(task.x, task.y)
    
    local bumpType = bandit:getBumpType()
    if bumpType ~= task.anim then return false end

    return true
end

ZombieActions.Shove.onComplete = function(bandit, task)

    local enemy = BanditZombie.GetInstanceById(task.eid)
    if enemy then 
        local brainBandit = BanditBrain.Get(bandit)
        local brainEnemy = BanditBrain.Get(enemy)
        if not brainEnemy or not brainEnemy.clan or brainBandit.clan ~= brainEnemy.clan or (brainBandit.hostile and not brainEnemy.hostile) then 
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

    return true
end