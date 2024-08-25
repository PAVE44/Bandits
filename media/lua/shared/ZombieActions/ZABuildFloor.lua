ZombieActions = ZombieActions or {}

ZombieActions.BuildFloor = {}
ZombieActions.BuildFloor.onStart = function(zombie, task)
    return true
end

ZombieActions.BuildFloor.onWorking = function(zombie, task)
    zombie:faceLocation(task.x, task.y)
    --if asn == "bumped" then
    if task.time == 0 then
        return true
    end
    if zombie:getVariableString("BumpAnimFinished") then
        zombie:setVariable("BumpAnimFinished", false)
        zombie:setBumpType(task.anim)
        if not zombie:getEmitter():isPlaying(task.sound) then
            zombie:playSound(task.sound)
        end
    end
    return false
end

ZombieActions.BuildFloor.onComplete = function(zombie, task)
    local square = getCell():getGridSquare(task.x, task.y, 0)

    if square then
        local objects = square:getObjects()
        for i=0, objects:size()-1 do
            local object = objects:get(i)
            local properties = object:getProperties()
            if properties then
                local water = properties:Is(IsoFlagType.water)
                if water then

                    local floor = IsoObject.new(square, "carpentry_02_56", "")
                    square:AddSpecialObject(floor)
                    floor:transmitCompleteItemToServer()

                    if isClient() then
                        sledgeDestroy(object)
                    else
                        square:transmitRemoveItemFromSquare(object)
                    end

                    return true
                end
            end
        end
    end

    return true
end