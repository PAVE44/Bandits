ZombieActions = ZombieActions or {}

ZombieActions.Time = {}
ZombieActions.Time.onStart = function(zombie, task)
    return true
end

ZombieActions.Time.onWorking = function(zombie, task)
    if not zombie:getVariableString("BumpAnimFinished") then
        return false
    else
        return true
    end
end

ZombieActions.Time.onComplete = function(zombie, task)
    return true
end