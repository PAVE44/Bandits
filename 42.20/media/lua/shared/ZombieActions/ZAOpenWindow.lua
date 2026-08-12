ZombieActions = ZombieActions or {}

ZombieActions.OpenWindow = {}
ZombieActions.OpenWindow.onStart = function(zombie, task)
    return true
end

ZombieActions.OpenWindow.onWorking = function(zombie, task)
    zombie:faceLocationF(task.x, task.y)

    local square = zombie:getCell():getGridSquare(task.x, task.y, task.z)
    local window = square and square:getWindow()
    if not window or window:IsOpen() or window:isSmashed() then return true end

    if zombie:getBumpType() ~= task.anim then return true end
    return false
end

ZombieActions.OpenWindow.onComplete = function(zombie, task)

    local cell = zombie:getSquare():getCell()
    local square = cell:getGridSquare(task.x, task.y, task.z)
    if square then
        local window = square:getWindow()
        if window and not window:IsOpen() and not window:isSmashed() then
            window:ToggleWindow(zombie)
            zombie:playSound("OpenWindow")
        end
    end
    return true
end