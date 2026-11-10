ZombieActions = ZombieActions or {}

ZombieActions.ClimbFence = {}
ZombieActions.ClimbFence.onStart = function(zombie, task)
    task.tick = 0
    return true
end

ZombieActions.ClimbFence.onWorking = function(zombie, task)

    if zombie:getBumpType() ~= task.anim then return true end

    if task.tick > 50 then
        local fd = zombie:getForwardDirection()
        fd:setLength(0.005)
        zombie:setX(zombie:getX() + fd:getX())
        zombie:setY(zombie:getY() + fd:getY())
    end

    task.tick = task.tick + 1
    return false

end

ZombieActions.ClimbFence.onComplete = function(zombie, task)
    return true
end