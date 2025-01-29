ZombieActions = ZombieActions or {}

ZombieActions.Aim = {}
ZombieActions.Aim.onStart = function(zombie, task)
    return true
end

ZombieActions.Aim.onWorking = function(zombie, task)
    zombie:faceLocationF(task.x, task.y)
    if zombie:getBumpType() ~= task.anim then return true end
    return false
end

ZombieActions.Aim.onComplete = function(zombie, task)
    Bandit.SetAim(zombie, true)
    return true
end