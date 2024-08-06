ZombieActions = ZombieActions or {}

ZombieActions.Move = {}
ZombieActions.Move.onStart = function(zombie, task)
    local x
    local y
    local z

    if not task.mode then task.mode = "EXACT" end

    if task.mode == "STANDNEXT" then
        if zombie:getX() > task.x then
            x = task.x + 1.1
        elseif zombie:getX() < task.x then
            x = task.x - 1.1
        elseif zombie:getX() == task.x then
            x = task.x
        end

        if zombie:getY() > task.y then
            y = task.y + 1.1
        elseif zombie:getY() < task.y then
            y = task.y - 1.1
        elseif zombie:getY() == task.y then
            y = task.y
        end

        z = task.z

    elseif task.mode == "EXACT" then
        x = task.x + 0.5
        y = task.y + 0.5
        z = task.z
    end

    -- print ("MOVE ORDER: X:" .. x .. " Y:" .. y .. " Z:" .. z)
    
    zombie:getPathFindBehavior2():pathToLocation(x, y, z)
    -- zombie:getPathFindBehavior2():moveToPoint(x, y, z)

    --zombie:getPathFindBehavior2():pathToCharacter(getPlayer())
    

    -- zombie:pathToLocationF(x, y, z)
    zombie:getPathFindBehavior2():cancel()
    zombie:setPath2(nil)
    zombie:setWalkType(task.walkType)
    
    return true
end

ZombieActions.Move.onWorking = function(zombie, task)
    local cell = getCell()
    -- zombie:changeState(ZombieIdleState.instance())
    -- zombie:setVariable("bMoving", true)
    if ZombRand(1000) == 1 then
        zombie:getPathFindBehavior2():pathToLocation(task.x+1, task.y+1, task.z)
        zombie:getPathFindBehavior2():cancel()
        zombie:setPath2(nil)
        -- print ("ANTISTUCK")
    end
    zombie:setWalkType(task.walkType)

    local result = zombie:getPathFindBehavior2():update()
    if result == BehaviorResult.Failed then
        -- print ("PATH FAILED")
        return true
    end
    if result == BehaviorResult.Succeeded then
        -- print ("PATH SUCCEED")
        return true
    end

    return false
end

ZombieActions.Move.onComplete = function(zombie, task)
    -- print ("PATH CANCELLED")
    zombie:getPathFindBehavior2():cancel()
    return true
end



