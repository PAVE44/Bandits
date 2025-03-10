ZombieActions = ZombieActions or {}

ZombieActions.Aim = {}
ZombieActions.Aim.onStart = function(zombie, task)
    task.tick = 1
    zombie:setBumpType(task.anim)
    return true
end

ZombieActions.Aim.onWorking = function(zombie, task)
    task.tick = task.tick + 1
    zombie:faceLocationF(task.x, task.y)
    if zombie:getBumpType() ~= task.anim then 
        if task.tick < 10 then
            zombie:setBumpType(task.anim)
        else
            return true
        end
    end
    return false
end

ZombieActions.Aim.onComplete = function(zombie, task)
    Bandit.SetAim(zombie, true)
    print (task.tick .. " " .. task.anim)
    return true
end