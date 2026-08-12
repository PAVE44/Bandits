ZombieActions = ZombieActions or {}

ZombieActions.Turn = {}
ZombieActions.Turn.onStart = function(zombie, task)
    return true
end

ZombieActions.Turn.onWorking = function(zombie, task)
    -- zombie:addLineChatElement(task.action .. task.time, 0.5, 0.5, 0.5)
    if zombie:getBumpType() ~= task.anim then return true end
    return false
--[[
    if not zombie:getVariableString("BumpAnimFinished") then
        return false
    else
        return true
    end
    ]]
    
end

ZombieActions.Turn.onComplete = function(zombie, task)
    -- zombie:setDirectionAngle(task.dir)
    --zombie:setForwardDirection(task.x, task.y)
    zombie:faceLocationF(task.x, task.y)
    return true
end