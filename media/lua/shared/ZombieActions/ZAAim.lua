ZombieActions = ZombieActions or {}

ZombieActions.Aim = {}
ZombieActions.Aim.onStart = function(zombie, task)
    return true
end

ZombieActions.Aim.onWorking = function(zombie, task)
    if not zombie:getVariableString("BumpAnimFinished") then
        return false
    else
        return true
    end
end

ZombieActions.Aim.onComplete = function(zombie, task)
    Bandit.SetAim(zombie, true)
    return true
end