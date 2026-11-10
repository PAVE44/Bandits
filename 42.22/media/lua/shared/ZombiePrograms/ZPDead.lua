ZombiePrograms = ZombiePrograms or {}

local function predicateAll(item)
    return true
end

ZombiePrograms.Dead = {}
ZombiePrograms.Dead.Stages = {}

ZombiePrograms.Dead.Init = function(bandit)
end

ZombiePrograms.Dead.Prepare = function(bandit)
    local tasks = {}

    Bandit.ForceStationary(bandit, true)
  
    return {status=true, next="Main", tasks=tasks}
end

ZombiePrograms.Dead.Main = function(bandit)
    local tasks = {}

    bandit:setHealth(0)
    bandit:clearAttachedItems()
    bandit:changeState(ZombieOnGroundState.instance())
    bandit:setAttackedBy(getCell():getFakeZombieForHit())
    bandit:die()

    return {status=true, next="Main", tasks=tasks}
end
