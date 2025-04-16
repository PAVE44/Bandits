ZombiePrograms = ZombiePrograms or {}

ZombiePrograms.Looter = {}
ZombiePrograms.Looter.Stages = {}

ZombiePrograms.Looter.Init = function(bandit)
end

ZombiePrograms.Looter.Prepare = function(bandit)
    local tasks = {}

    Bandit.ForceStationary(bandit, false)
  
    return {status=true, next="Main", tasks=tasks}
end

ZombiePrograms.Looter.Main = function(bandit)
    local tasks = {}
    local cell = getCell()
    local bx, by, bz = bandit:getX(), bandit:getY(), bandit:getZ()
    local endurance = 0.00

    local config = {}
    config.mustSee = true
    config.hearDist = 7

    if Bandit.HasExpertise(bandit, Bandit.Expertise.Recon) then
        config.hearDist = 20
    elseif Bandit.HasExpertise(bandit, Bandit.Expertise.Tracker) then
        config.hearDist = 60
    end

    local target, enemy = BanditUtils.GetTarget(bandit, config)
    
    -- engage with target
    if target.x and target.y and target.z then
        local targetSquare = cell:getGridSquare(target.x, target.y, target.z)
        if targetSquare then
            Bandit.SayLocation(bandit, targetSquare)
        end

        local tx, ty, tz = target.x, target.y, target.z
    
        if enemy then
            if target.fx and target.fy and (enemy:isRunning()  or enemy:isSprinting()) then
                tx, ty = target.fx, target.fy
            end
        end

        local walkType = Bandit.GetCombatWalktype(bandit, enemy, target.dist)

        table.insert(tasks, BanditUtils.GetMoveTask(endurance, tx, ty, tz, walkType, target.dist))
        return {status=true, next="Main", tasks=tasks}
    end

    local task = {action="Time", anim="Shrug", time=200}
    table.insert(tasks, task)

    return {status=true, next="Main", tasks=tasks}
end

ZombiePrograms.Looter.Wait = function(bandit)
    return {status=true, next="Main", tasks={}}
end

