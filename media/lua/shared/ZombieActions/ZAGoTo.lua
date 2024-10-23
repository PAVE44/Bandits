ZombieActions = ZombieActions or {}

ZombieActions.GoTo = {}
ZombieActions.GoTo.onStart = function(zombie, task)

    local dx = math.abs(zombie:getX() - task.x)
    local dy = math.abs(zombie:getY() - task.y)
    
    if task.closeSlow then
        if dx <= 2 and dy <= 2 and zombie:getZ() == task.z then
            task.walkType = "WalkAim"
        elseif dx <= 3 and dy <= 3 and zombie:getZ() == task.z then
            task.walkType = "Walk"
        end
    end

    zombie:setVariable("BanditWalkType", task.walkType)

    if not Bandit.IsMoving(zombie) then
        dist = math.sqrt(math.pow(zombie:getX() - task.x, 2) + math.pow(zombie:getY() - task.y, 2))
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
        local dx = math.abs(zombie:getX() - task.x)
        local dy = math.abs(zombie:getY() - task.y)
        if dx <= 0.02 and dy <= 0.02 and zombie:getZ() == task.z then
            -- print ("PATH DISTANCE REACHED")
        else
            zombie:pathToLocationF(task.x + 0.5, task.y + 0.5, task.z)
            -- zombie:setVariable("BanditWalkType", "WalkAim")
            --zombie:setWalkType(task.walkType)
        end
    end
   
    return true
end

ZombieActions.GoTo.onWorking = function(zombie, task)

    return false
end

ZombieActions.GoTo.onComplete = function(zombie, task)
    return true
end



