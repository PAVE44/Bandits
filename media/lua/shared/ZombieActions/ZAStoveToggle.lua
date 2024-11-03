ZombieActions = ZombieActions or {}

ZombieActions.StoveToggle = {}
ZombieActions.StoveToggle.onStart = function(zombie, task)
    return true
end

ZombieActions.StoveToggle.onWorking = function(zombie, task)
    if not zombie:getVariableString("BumpAnimFinished") then
        return false
    else
        return true
    end
end

ZombieActions.StoveToggle.onComplete = function(zombie, task)
    local square = zombie:getCell():getGridSquare(task.x, task.y, task.z)
    if square then
        local objects = square:getObjects()
        for i=0, objects:size()-1 do
            local object = objects:get(i)
            if instanceof(object, "IsoStove") then
                object:Toggle()
            end
        end
    end
    return true
end

