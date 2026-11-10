ZombieActions = ZombieActions or {}

ZombieActions.Move = {}
ZombieActions.Move.onStart = function(zombie, task)

    zombie:setVariable("BanditWalkType", task.walkType)
    
    local square = zombie:getCurrentSquare()
    if not square:isFree(false) then
        if task.x > zombie:getX() then
            zombie:setX(zombie:getX() + 0.05)
            -- zombie:addLineChatElement("BLOCKED NEW X: " .. (zombie:getX() + 0.1), 0.8, 0.8, 0.1)
        else
            zombie:setX(zombie:getX() - 0.05)
        end
        if task.y > zombie:getY() then
            zombie:setY(zombie:getY() + 0.05)
        else
            zombie:setY(zombie:getY() - 0.05)
        end
    end

    local dist = BanditUtils.DistTo(task.x, task.y, zombie:getX(), zombie:getY())
    if dist < 0.2 then

        return true
    end

    if BanditUtils.IsController(zombie) then
        zombie:getPathFindBehavior2():pathToLocationF(task.x, task.y, task.z)
        -- force PathFindState: it owns path2 and runs PathFindBehavior2.update() itself
        zombie:setVariable("bPathfind", true)
        zombie:setVariable("bMoving", false)
        task.moveTicks = 0
    end

    return true
end

ZombieActions.Move.onWorking = function(zombie, task)

    --zombie:setCollideType(nil)

    local collided = zombie:isCollidedWithDoor() or zombie:isCollidedThisFrame() or zombie:isCollided()
    if collided then return false end

    zombie:setVariable("BanditWalkType", task.walkType)

    if BanditCompatibility.GetGameVersion() >= 42 then
        if task.backwards then
            zombie:setAnimatingBackwards(true)
        else
            zombie:setAnimatingBackwards(false)
        end
    end

    if BanditUtils.IsController(zombie) then

        -- the state machine needs a few ticks to enter PathFindState, which clears bPathfind when the path ends
        task.moveTicks = (task.moveTicks or 0) + 1
        if task.moveTicks > 3 and not zombie:getVariableBoolean("bPathfind") then
            return true
        end
    end

    return false
end

ZombieActions.Move.onComplete = function(zombie, task)
    if BanditUtils.IsController(zombie) then
        local finder = zombie:getPathFindBehavior2()
        finder:cancel()
        finder:reset()
        zombie:setPath2(nil)
    end
    return true
end
