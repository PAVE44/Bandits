ZombieActions = ZombieActions or {}

ZombieActions.Die = {}
ZombieActions.Die.onStart = function(zombie, task)
    zombie:clearAttachedItems()
    return true
end

ZombieActions.Die.onWorking = function(zombie, task)
    if not zombie:getVariableString("BumpAnimFinished") then
        return false
    else
        return true
    end
end

ZombieActions.Die.onComplete = function(zombie, task)
    --zombie:Kill(getCell():getFakeZombieForHit(), true)

    zombie:setHealth(0)
    zombie:clearAttachedItems()
    zombie:changeState(ZombieOnGroundState.instance())
    zombie:setAttackedBy(getCell():getFakeZombieForHit())
    zombie:becomeCorpse()

    return true
end