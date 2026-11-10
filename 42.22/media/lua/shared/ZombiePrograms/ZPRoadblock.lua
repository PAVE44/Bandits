ZombiePrograms = ZombiePrograms or {}

ZombiePrograms.Roadblock = {}
ZombiePrograms.Roadblock.Stages = {}

ZombiePrograms.Roadblock.Init = function(bandit)
end

ZombiePrograms.Roadblock.Prepare = function(bandit)
    local tasks = {}

    Bandit.ForceStationary(bandit, true)
  
    return {status=true, next="Main", tasks=tasks}
end

ZombiePrograms.Roadblock.Main = function(bandit)
    local tasks = {}

    -- player spotted
    local spotDist = 30
    local playerList = BanditPlayer.GetPlayers()
    for i=0, playerList:size()-1 do
        local player = playerList:get(i)
        if player and bandit:CanSee(player) and not BanditPlayer.IsGhost(player) then
            if player:isSneaking() then spotDist = spotDist - 3 end
            local dist = BanditUtils.DistTo(player:getX(), player:getY(), bandit:getX(), bandit:getY())
            if dist <= spotDist then
                Bandit.Say(bandit, "SPOTTED")
                Bandit.SetSleeping(bandit, false)
                Bandit.ClearTasks(bandit)
                Bandit.SetProgram(bandit, "Bandit", {})
                Bandit.ForceStationary(bandit, false)
                local task = {action="Time", lock=true, anim="GetUp", time=150}
                return {status=true, next="Prepare", tasks=tasks}
            end
        end
    end

    local subTasks = BanditPrograms.Idle(bandit)
    if #subTasks > 0 then
        for _, subTask in pairs(subTasks) do
            table.insert(tasks, subTask)
        end
        return {status=true, next="Main", tasks=tasks}
    end

    return {status=true, next="Main", tasks=tasks}
end

