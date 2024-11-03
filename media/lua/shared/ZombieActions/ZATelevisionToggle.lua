ZombieActions = ZombieActions or {}

ZombieActions.TelevisionToggle = {}
ZombieActions.TelevisionToggle.onStart = function(zombie, task)
    return true
end

ZombieActions.TelevisionToggle.onWorking = function(zombie, task)
    if not zombie:getVariableString("BumpAnimFinished") then
        return false
    else
        return true
    end
end

ZombieActions.TelevisionToggle.onComplete = function(zombie, task)
    local square = zombie:getCell():getGridSquare(task.x, task.y, task.z)
    if square then
        local objects = square:getObjects()
        for i=0, objects:size()-1 do
            local object = objects:get(i)
            if instanceof(object, "IsoTelevision") then
                local dd = object:getDeviceData()
                dd:setIsTurnedOn(not dd:getIsTurnedOn())
            end
        end
    end
    return true
end

