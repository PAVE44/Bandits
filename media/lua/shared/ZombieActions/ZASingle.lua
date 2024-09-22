ZombieActions = ZombieActions or {}

ZombieActions.Single = {}
ZombieActions.Single.onStart = function(zombie, task)
    return true
end

ZombieActions.Single.onWorking = function(zombie, task)
    if not zombie:getVariableString("BumpAnimFinished") then
        return false
    else
        return true
    end
end

ZombieActions.Single.onComplete = function(zombie, task)
    return true
end