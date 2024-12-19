ZombieActions = ZombieActions or {}

ZombieActions.Wash = {}
ZombieActions.Wash.onStart = function(zombie, task)
    zombie:playSound("WashYourself")
    return true
end

ZombieActions.Wash.onWorking = function(zombie, task)
    zombie:faceLocation(task.x, task.y)

    if task.time <= 0 then return true end

    if zombie:getBumpType() ~= task.anim then 
        zombie:setBumpType(task.anim)
    end
end

ZombieActions.Wash.onComplete = function(zombie, task)
    zombie:getEmitter():stopAll()

    local visual = zombie:getHumanVisual()
    local waterUsed = 0
    for i=1,BloodBodyPartType.MAX:index() do
        local part = BloodBodyPartType.FromIndex(i-1)
        visual:setBlood(part, 0)
        visual:setDirt(part, 0)
    end
    zombie:resetModelNextFrame()
    -- sendVisual(zombie)

    return true
end

