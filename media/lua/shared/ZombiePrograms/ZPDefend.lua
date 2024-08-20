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

    Bandit.ForceStationary(bandit, false)
    Bandit.SetWeapons(bandit, Bandit.GetWeapons(bandit))
    
    -- weapons are spawn, not program decided
    local primary = Bandit.GetBestWeapon(bandit)

    local task = {action="Equip", itemPrimary=primary, itemSecondary=nil}
    table.insert(tasks, task)

    return {status=true, next="Defend", tasks={}}
end

ZombiePrograms.Defend.Defend = function(bandit)

    local tasks = {}

    local health = bandit:getHealth()
    local pace = "Run"
    local endurance = -0.07

    if health < 0.4 then
        pace = "Limp"
        endurance = 0
    end

    local player = getPlayer()
    if bandit:CanSee(player) then
        local playerSquare = player:getSquare()
        local banditSquare = bandit:getSquare()
        if playerSquare and banditSquare then
            local playerBuilding = playerSquare:getBuilding()
            local banditBuilding = banditSquare:getBuilding()
            if playerBuilding and banditBuilding then
                if playerBuilding:getID() == banditBuilding:getID() then
                    Bandit.Say(bandit, "DEFENDER_SPOTTED")
                end
            end
        end
    end

    local handweapon = bandit:getVariableString("BanditWeapon")
    local walkType = pace .. handweapon

    local building = bandit:getSquare():getBuilding()
    if building then
        local room = building:getRandomRoom()
        if room then
            local roomDef = room:getRoomDef()
            if roomDef then
                local newSquare = roomDef:getFreeSquare()
                if newSquare then
                    local gamemode = getWorld():getGameMode()
                    local task
                    if gamemode == "Multiplayer" then
                        task = {action="GoTo", endurance=endurance, x=newSquare:getX(), y=newSquare:getY(), z=newSquare:getZ(), walkType=walkType}
                    else
                        task = {action="Move", endurance=endurance, x=newSquare:getX(), y=newSquare:getY(), z=newSquare:getZ(), walkType=walkType}
                    end
                    table.insert(tasks, task)
                end
            end
        end
    else
        Bandit.SetProgram(bandit, "Bandit", {})
        return {status=true, next="Prepare", tasks=tasks}
    end

    return {status=true, next="Defend", tasks=tasks}
end

ZombiePrograms.Defend.Sleep = function(bandit)

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
            if player:isAiming() and dist < 12 then
                continueSleep = false
            elseif player:isRunning() and dist < 6 then
                continueSleep = false
            elseif player:isSneaking() and dist < 2 then
                continueSleep = false
            elseif dist<3 then
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
        return {status=true, next="Defend", tasks=tasks}
    end

    
end

