ZombieActions = ZombieActions or {}

ZombieActions.Sleep = {}
ZombieActions.Sleep.onStart = function(zombie, task)
    return true
end

ZombieActions.Sleep.onWorking = function(zombie, task)
    zombie:setBumpType(task.anim)

    if task.x and task.y and task.z and task.facing then
        local dx = 0
        local dy = 0
        local fx = 0 
        local fy = 0
        if task.facing == "S" then
            dx = 0.5
            dy = 0.5
            fx = -20
        elseif task.facing == "N" then
            dx = 0.5
            dy = 0.5
            fx = 20
        elseif task.facing == "E" then
            dx = 0.5
            dy = 0.5
            fy = 20
        elseif task.facing == "W" then
            dx = 0.5
            dy = 0.5
            fy = -20    
        end

        zombie:setX(task.x + dx)
        zombie:setY(task.y + dy)
        zombie:setZ(task.z)
        zombie:faceLocationF(task.x + fx, task.y + fy)
    end
    return false
end

ZombieActions.Sleep.onComplete = function(zombie, task)
    return true
end