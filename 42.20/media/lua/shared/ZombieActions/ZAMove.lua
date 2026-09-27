ZombieActions = ZombieActions or {}

ZombieActions.Move = {}
ZombieActions.Move.onStart = function(zombie, task)

    zombie:setVariable("BanditWalkType", task.walkType)
    --zombie:setCollideType("wall")

    local square = zombie:getCurrentSquare()
    if not square:isFree(false) then
        if task.x > zombie:getX() then
            zombie:setX(zombie:getX() + 0.05)
            zombie:addLineChatElement("BLOCKED NEW X: " .. (zombie:getX() + 0.1), 0.8, 0.8, 0.1)
        else
            zombie:setX(zombie:getX() - 0.05)
        end
        if task.y > zombie:getY() then
            zombie:setY(zombie:getY() + 0.05)
        else
            zombie:setY(zombie:getY() - 0.05)
        end
    end
    if BanditUtils.IsController(zombie) then
        zombie:getPathFindBehavior2():pathToLocation(task.x, task.y, task.z)
        zombie:getPathFindBehavior2():update()
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
        local finder = zombie:getPathFindBehavior2()
        finder:cancel()
        finder:reset()
        zombie:setPath2(nil)
    end
    return true
end



