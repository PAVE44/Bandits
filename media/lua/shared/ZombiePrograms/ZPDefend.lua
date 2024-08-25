ZombiePrograms = ZombiePrograms or {}

ZombiePrograms.Defend = {}
ZombiePrograms.Defend.Stages = {}

ZombiePrograms.Defend.Init = function(bandit)
end

ZombiePrograms.Defend.GetCapabilities = function()
    -- capabilities are program decided
    local capabilities = {}
    capabilities.melee = true
    capabilities.shoot = true
    capabilities.smashWindow = false
    capabilities.openDoor = true
    capabilities.breakDoor = false
    capabilities.breakObjects = false
    capabilities.unbarricade = false
    capabilities.disableGenerators = false
    capabilities.sabotageCars = false
    return capabilities
end

ZombiePrograms.Defend.Prepare = function(bandit)
    local tasks = {}

    Bandit.ForceStationary(bandit, true)
    Bandit.SetWeapons(bandit, Bandit.GetWeapons(bandit))
    
    -- weapons are spawn, not program decided
    local primary = Bandit.GetBestWeapon(bandit)

    local task = {action="Equip", itemPrimary=primary, itemSecondary=nil}
    table.insert(tasks, task)

    return {status=true, next="Wait", tasks={}}
end

ZombiePrograms.Defend.Wait = function(bandit)

    local tasks = {}

    -- manage sleep
    local gameTime = getGameTime()
    local hour = gameTime:getHour()
    local spotDist = 30
    if (gameTime:getHour() >= 0 and gameTime:getHour() < 7) or (gameTime:getHour() >= 13 and gameTime:getHour() < 14) then
        -- sleeping
        spotDist = 10
        Bandit.SetSleeping(bandit, true)
        BanditBasePlacements.Matress(bandit:getX(), bandit:getY(), bandit:getZ())
        local task = {action="Sleep", anim="Sleep", time=100}
        table.insert(tasks, task)
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

    -- player entered defender's house
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
        if player and not BanditPlayer.IsGhost(player) then
            local playerSquare = player:getSquare()
            local banditSquare = bandit:getSquare()
            if playerSquare and banditSquare and not playerSquare:isOutside() then
                local playerBuilding = playerSquare:getBuilding()
                local banditBuilding = banditSquare:getBuilding()
                if playerBuilding and banditBuilding and playerBuilding:getID() == banditBuilding:getID()then
                    if player:isSneaking() then spotDist = spotDist - 3 end
                    local dist = math.sqrt(math.pow(player:getX() - bandit:getX(), 2) + math.pow(player:getY() - bandit:getY(), 2))
                    if dist <= spotDist then
                        Bandit.Say(bandit, "DEFENDER_SPOTTED")
                        Bandit.SetSleeping(bandit, false)
                        Bandit.ClearTasks(bandit)
                        Bandit.SetProgram(bandit, "Bandit", {})
                        return {status=true, next="Prepare", tasks=tasks}
                    end
                end
            end
        end
    end

    return {status=true, next="Wait", tasks=tasks}
end

