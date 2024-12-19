ZombieActions = ZombieActions or {}

ZombieActions.Time = {}
ZombieActions.Time.onStart = function(zombie, task)
    return true
end

ZombieActions.Time.onWorking = function(zombie, task)
    -- zombie:addLineChatElement(task.action .. task.time, 0.5, 0.5, 0.5)
    local bumpType = zombie:getBumpType()
    if bumpType ~= task.anim then
        return true
    end
--[[
    if not zombie:getVariableString("BumpAnimFinished") then
        return false
    else
        return true
    end
    ]]
end

ZombieActions.Time.onComplete = function(zombie, task)
    return true
end