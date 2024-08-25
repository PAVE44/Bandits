ZombiePrograms = ZombiePrograms or {}

ZombiePrograms.BaseGuard = {}
ZombiePrograms.BaseGuard.Stages = {}

ZombiePrograms.BaseGuard.Init = function(bandit)
end

ZombiePrograms.BaseGuard.GetCapabilities = function()
    -- capabilities are program decided
    local capabilities = {}
    capabilities.melee = true
    capabilities.shoot = true
    capabilities.smashWindow = true
    capabilities.openDoor = true
    capabilities.breakDoor = true
    capabilities.breakObjects = true
    capabilities.unbarricade = true
    capabilities.disableGenerators = false
    capabilities.sabotageCars = false
    return capabilities
end

ZombiePrograms.BaseGuard.Prepare = function(bandit)
    local tasks = {}

    Bandit.ForceStationary(bandit, true)
    Bandit.SetWeapons(bandit, Bandit.GetWeapons(bandit))
    
    -- weapons are spawn, not program decided
    local primary = Bandit.GetBestWeapon(bandit)

    local task = {action="Equip", itemPrimary=primary, itemSecondary=nil}
    table.insert(tasks, task)

    return {status=true, next="Wait", tasks={}}
end

ZombiePrograms.BaseGuard.Wait = function(bandit)
    local tasks = {}

    -- manage sleep
    local gameTime = getGameTime()
    local hour = gameTime:getHour() 

    -- idle
    local spotDist = 30
    if gameTime:getHour() >= 0 and gameTime:getHour() < 7 then
        -- sleeping
        spotDist = 5
        Bandit.SetSleeping(bandit, true)
        local task = {action="Sleep", anim="Sleep", time=100}
        table.insert(tasks, task)
    elseif (gameTime:getHour() >= 7 and gameTime:getHour() < 8) or (gameTime:getHour() >= 12 and gameTime:getHour() < 13) or (gameTime:getHour() >= 19 and gameTime:getHour() < 22) then
        -- resting / eating
        spotDist = 20
        Bandit.SetSleeping(bandit, true)
        local action = ZombRand(50)
        if action == 0 then
            local task = {action="Sleep", anim="SitRubHands", time=200}
            table.insert(tasks, task)
        elseif action == 1 then
            local task = {action="Sleep", anim="SitMaking", time=100}
            table.insert(tasks, task)
            table.insert(tasks, task)
            table.insert(tasks, task)
        elseif action < 30 then
            local task = {action="Sleep", anim="SitAction", time=200}
            table.insert(tasks, task)
        else
            local task = {action="Sleep", anim="Sit", time=200}
            table.insert(tasks, task)
        end
    else
        -- guarding
        Bandit.SetSleeping(bandit, false)
        local action = ZombRand(50)
        if action == 0 then
            local task = {action="Time", anim="Cough", time=200}
            table.insert(tasks, task)
        elseif action == 1 then
            local task = {action="Time", anim="ChewNails", time=200}
            table.insert(tasks, task)
        elseif action == 2 then
            local task = {action="Time", anim="Smoke", time=200}
            table.insert(tasks, task)
            table.insert(tasks, task)
            table.insert(tasks, task)
        else
            local task = {action="Time", anim="ShiftWeight", time=200}
            table.insert(tasks, task)
        end
    end

    -- player spotted
    local world = getWorld()
    local gamemode = world:getGameMode()
    local playerList = {}
    if gamemode == "Multiplayer" then
        playerList = getOnlinePlayers()
    else
        playerList = IsoPlayer.getPlayers()
    end
    for i=0, playerList:size()-1 do
        local player = playerList:get(i)
        if player and bandit:CanSee(player) and not BanditPlayer.IsGhost(player) then
            if player:isSneaking() then spotDist = spotDist - 3 end
            local dist = math.sqrt(math.pow(player:getX() - bandit:getX(), 2) + math.pow(player:getY() - bandit:getY(), 2))
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

    return {status=true, next="Wait", tasks=tasks}
end

