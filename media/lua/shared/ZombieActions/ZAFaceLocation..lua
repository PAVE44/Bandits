ZombieActions = ZombieActions or {}

ZombieActions.FaceLocation = {}
ZombieActions.FaceLocation.onStart = function(zombie, task)
    zombie:faceLocation(task.x, task.y)
    return true
end

ZombieActions.FaceLocation.onWorking = function(zombie, task)
    if task.time == 0 then
        return true
    end

    return false
end

ZombieActions.FaceLocation.onComplete = function(zombie, task)
    return true
end

