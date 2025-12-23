ZombieActions = ZombieActions or {}

ZombieActions.GeneratorToggle = {}
ZombieActions.GeneratorToggle.onStart = function(zombie, task)
    return true
end

ZombieActions.GeneratorToggle.onWorking = function(zombie, task)
    zombie:faceLocation(task.x, task.y)
    if zombie:getBumpType() ~= task.anim then return true end
    return false
end

ZombieActions.GeneratorToggle.onComplete = function(zombie, task)
    local square = zombie:getCell():getGridSquare(task.x, task.y, task.z)
    if square then
        local generator = square:getGenerator()
        if generator then
            generator:setActivated(task.status)
        end
    end
    return true
end

