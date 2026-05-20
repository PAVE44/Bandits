ZombieActions = ZombieActions or {}

ZombieActions.StoveToggle = {}
ZombieActions.StoveToggle.onStart = function(zombie, task)
    return true
end

ZombieActions.StoveToggle.onWorking = function(zombie, task)
    zombie:faceLocationF(task.x, task.y)
    if zombie:getBumpType() ~= task.anim then return true end
    return false
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

