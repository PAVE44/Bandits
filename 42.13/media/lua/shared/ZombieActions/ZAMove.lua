ZombieActions = ZombieActions or {}

ZombieActions.Move = {}
ZombieActions.Move.onStart = function(zombie, task)

    local square = zombie:getSquare()
    if not square:isFree(false) then
        if BanditUtils.HasAccessSquare(square) then
            local fd = zombie:getForwardDirection()
            fd:setLength(0.025)
            zombie:setX(zombie:getX() + fd:getX())
            zombie:setY(zombie:getY() + fd:getY())
        end
    end

    zombie:setVariable("BanditWalkType", task.walkType)
    zombie:getPathFindBehavior2():reset()
    zombie:getPathFindBehavior2():cancel()
    zombie:setPath2(nil)

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

    if not task.tid then
        if BanditUtils.IsController(zombie) then
            zombie:getPathFindBehavior2():pathToLocation(task.x, task.y, task.z)
            zombie:getPathFindBehavior2():cancel()
            zombie:setPath2(nil)
        end
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

    if BanditUtils.IsController(zombie) then
        local cell = getCell()

        if task.tid then
            -- MODIFICATION START: Logic to handle moving toward a specific target ID (tid)
            local target = nil
            if task.isPlayer then
                local player = getPlayer()
                -- Streamlined redundant code as it does the same thing.
                if BanditUtils.GetCharacterID(player) == task.tid then
                    target = player
                end
            else
                target = BanditZombie.Cache[task.tid]
            end

            if target then
                -- NEW: Check distance to target. 
                -- If we are within 1.5 tiles, the 'Move' task is complete.
                -- This allows the zombie to transition to the next task (like Attack).
                local dist = BanditUtils.DistTo(zombie:getX(), zombie:getY(), target:getX(), target:getY())
                if dist < 1.5 then
                    return true -- Task successfully finished
                end

                if target:getZ() == zombie:getZ() then
                    zombie:faceThisObject(target)
                end
                
                -- This triggers pathfinding updates every tick. 
                -- Returning 'true' above prevents this from running infinitely.
                zombie:pathToCharacter(target)
            else
                -- Target is lost or dead, complete the task to prevent 'slow' prints and stalling
                return true 
            end
            -- MODIFICATION END
        else
            local result = zombie:getPathFindBehavior2():update()
            if result == BehaviorResult.Failed then
                return true
            end
            if result == BehaviorResult.Succeeded then
                return true
            end
        end
    end

    return false
end

ZombieActions.Move.onComplete = function(zombie, task)
    return true
end
