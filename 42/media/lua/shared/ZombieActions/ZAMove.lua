ZombieActions = ZombieActions or {}

ZombieActions.Move = {}
ZombieActions.Move.onStart = function(zombie, task)

    if not zombie:getSquare():isFree(false) then
        local asquare = AdjacentFreeTileFinder.Find(zombie:getSquare(), zombie)
        if asquare then
            zombie:setX(asquare:getX() + 0.5)
            zombie:setY(asquare:getY() + 0.5)
        end
    end

    zombie:setVariable("BanditWalkType", task.walkType)

    if not Bandit.IsMoving(zombie) then
        local dist = BanditUtils.DistTo(zombie:getX(), zombie:getY(), task.x, task.y)
        if dist > 2 then
            local bump
            if task.walkType == "Run" then
                bump = "IdleToRun"
            elseif task.walkType == "Walk" then
                bump = "IdleToWalk"
            end

            if bump then
                zombie:setBumpType(bump)
            end
        end
        Bandit.SetMoving(zombie, true)
    elseif task.walkType == "Run" then
        local shouldTurn = false
        local faceDir = zombie:getDirectionAngle()
        local targetDir = BanditUtils.CalcAngle(zombie:getX(), zombie:getY(), task.x, task.y)
        local angleDifference = faceDir - targetDir
        if angleDifference > 180 then
            angleDifference = angleDifference - 360
        elseif angleDifference < -180 then
            angleDifference = angleDifference + 360
        end
        if math.abs(angleDifference) > 130 then
            shouldTurn = true
            local bump = "IdleToRun"
            zombie:faceLocation(task.x, task.y)
            zombie:setBumpType(bump)
        end
    end

    if BanditUtils.IsController(zombie) then
        zombie:getPathFindBehavior2():reset()
        zombie:getPathFindBehavior2():pathToLocation(task.x, task.y, task.z)
        zombie:getPathFindBehavior2():cancel()
        zombie:setPath2(nil)
    end

    return true
end

ZombieActions.Move.onWorking = function(zombie, task)

    zombie:setVariable("BanditWalkType", task.walkType)

    if BanditCompatibility.GetGameVersion() >= 42 then
        if task.backwards then
            zombie:setAnimatingBackwards(true)
        else
            zombie:setAnimatingBackwards(false)
        end
    end

    --[[
    if zombie:getSquare():isFree(false) then
        zombie:setCollidable(true)
    else
        zombie:setCollidable(false)
    end]]
    -- local finder = zombie:getFinder()
    if BanditUtils.IsController(zombie) then
        local cell = getCell()

        --[[if ZombRand(1000) == 1 then
            zombie:getPathFindBehavior2():pathToLocation(task.x+1, task.y+1, task.z)
            zombie:getPathFindBehavior2():cancel()
            zombie:setPath2(nil)
        end]]

        local result = zombie:getPathFindBehavior2():update()
        if result == BehaviorResult.Failed then
            return true
        end
        if result == BehaviorResult.Succeeded then
            return true
        end
    end

    return false
end

ZombieActions.Move.onComplete = function(zombie, task)
    if BanditUtils.IsController(zombie) then
        zombie:getPathFindBehavior2():cancel()
        zombie:getPathFindBehavior2():reset()
    end
    return true
end



