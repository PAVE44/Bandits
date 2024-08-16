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
    local world = getWorld()
    local cell = getCell()
    local cm = world:getClimateManager()
    local dls = cm:getDayLightStrength()

    Bandit.SetWeapons(bandit, Bandit.GetWeapons(bandit))
    
    -- weapons are spawn, not program decided
    local primary = Bandit.GetBestWeapon(bandit)

    local secondary
    if dls < 0.3 then
        if SandboxVars.Bandits.General_CarryTorches then
            local hands = bandit:getVariableString("BanditPrimaryType")
            if hands == "barehand" or hands == "onehanded" or hands == "handgun" then
                secondary = "Base.HandTorch"
            end
        end
    end

    local task = {action="Equip", itemPrimary=primary, itemSecondary=secondary}
    table.insert(tasks, task)

    return {status=true, next="Wait", tasks={}}
end

ZombiePrograms.BaseGuard.Wait = function(bandit)
    local tasks = {}

    if gamemode == "Multiplayer" then
        playerList = getOnlinePlayers()
    else
        playerList = IsoPlayer.getPlayers()
    end

    for i=0, playerList:size()-1 do
        local player = playerList:get(i)
        
        if player and bandit:CanSee(player) then
            Bandit.SetProgram(bandit, "Bandit", {})
            return {status=true, next="Prepare", tasks=tasks}
        end
    end

    local task = {action="Time", anim="Smoke", time=250}
    table.insert(tasks, task)

    return {status=true, next="Wait", tasks=tasks}
end

ZombiePrograms.BaseGuard.Sleep = function(bandit)

    local tasks = {}

    local continueSleep = true
    local world = getWorld()
    local playerList = {}
    if gamemode == "Multiplayer" then
        playerList = getOnlinePlayers()
    else
        playerList = IsoPlayer.getPlayers()
    end
    for i=0, playerList:size()-1 do
        local player = playerList:get(i)
        
        if player and bandit:CanSee(player) then -- and not player:isGhostMode()
            local dist = math.sqrt(math.pow(player:getX() - bandit:getX(), 2) + math.pow(player:getY() - bandit:getY(), 2))
            if player:isSneaking() and dist < 2 then
                continueSleep = false
            elseif dist<4 then
                continueSleep = false
            end
        end
    end

    if continueSleep then
        Bandit.SetSleeping(bandit, true)
        local task = {action="Sleep", anim="Sleep", time=100}
        table.insert(tasks, task)
        return {status=true, next="Sleep", tasks=tasks}
    else
        local task = {action="Time", lock=true, anim="GetUp", time=150}
        Bandit.ClearTasks(bandit)
        Bandit.AddTask(bandit, task)
        Bandit.SetSleeping(bandit, false)
        Bandit.SetProgram(bandit, "Bandit", {})
        return {status=true, next="Follow", tasks=tasks}
    end
    
end
