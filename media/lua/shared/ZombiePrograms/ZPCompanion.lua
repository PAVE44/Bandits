ZombiePrograms = ZombiePrograms or {}

ZombiePrograms.Companion = {}
ZombiePrograms.Companion.Stages = {}

ZombiePrograms.Companion.Init = function(bandit)
end

ZombiePrograms.Companion.GetCapabilities = function()
    -- capabilities are program decided
    local capabilities = {}
    capabilities.melee = true
    capabilities.shoot = true
    capabilities.smashWindow = true
    capabilities.openDoor = true
    capabilities.breakDoor = true
    capabilities.breakObjects = true
    capabilities.unbarricade = false
    capabilities.disableGenerators = false
    capabilities.sabotageCars = false
    return capabilities
end

ZombiePrograms.Companion.Prepare = function(bandit)
    local tasks = {}
    local world = getWorld()
    local cell = getCell()
    local cm = world:getClimateManager()
    local dls = cm:getDayLightStrength()

    Bandit.SetWeapons(bandit, Bandit.GetWeapons(bandit))
    
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

    return {status=true, next="Follow", tasks=tasks}
end

ZombiePrograms.Companion.Follow = function(bandit)
    local tasks = {}
    local weapons = Bandit.GetWeapons(bandit)

    -- update walk type
    local world = getWorld()
    local gamemode = world:getGameMode()
    local cell = getCell()
    local cm = world:getClimateManager()
    local dls = cm:getDayLightStrength()
    local weapons = Bandit.GetWeapons(bandit)
    local outOfAmmo = Bandit.IsOutOfAmmo(bandit)
 
    local master
    if gamemode == "Multiplayer" then
        master = getPlayerByOnlineID(Bandit.GetMaster(bandit))
    else
        master = getPlayer()
    end

    if master then

        walkType = "Walk"
        local endurance = 0.00
        if master:isRunning() or master:isSprinting() then
            walkType = "Run"
            endurance = -0.07
        elseif master:isSneaking() then
            walkType = "SneakWalk"
            endurance = -0.01
        end

        if master:isAiming() and not outOfAmmo then
            walkType = "WalkAim"
            endurance = 0
        end
    
        local health = bandit:getHealth()
        if health < 0.4 then
            walkType = "Limp"
            endurance = 0
        end 

        local dist = math.sqrt(math.pow(bandit:getX() - master:getX(), 2) + math.pow(bandit:getY() - master:getY(), 2))

        local minDist = 4
        if dist > minDist then

            -- must be deterministic, not random (same for all clients)
            local id = BanditUtils.GetCharacterID(bandit)

            local dx = (id % 4) - 2
            local dy = (id % 5) - 2.5
            local dxf = ((id % 10) - 5) / 10
            local dyf = ((id % 11) - 5) / 10

            -- Move and GoTo generally do the same thing with a different method
            -- GoTo uses one-time move order, provides better synchronization in multiplayer, not perfect on larger distance
            -- Move uses constant updatating, it a better algorithm but introduces desync in multiplayer
            local gamemode = getWorld():getGameMode()
            local task
            if gamemode == "Multiplayer" then
                if dist > 30 then
                    task = {action="Move", time=25, endurance=endurance, x=master:getX()+dx+dxf, y=master:getY()+dy+dyf, z=master:getZ(), walkType=walkType}
                else
                    task = {action="GoTo", time=50, endurance=endurance, x=master:getX()+dx+dxf, y=master:getY()+dy+dyf, z=master:getZ(), walkType=walkType}
                end
            else
                task = {action="Move", time=50, endurance=endurance, x=master:getX() - 1 + ZombRand(3) + ZombRandFloat(-0.5, 0.5), y=master:getY() - 1 + ZombRand(3) + ZombRandFloat(-0.5, 0.5), z=master:getZ(), walkType=walkType}
                -- task = {action="Move", time=50, x=x+dx+dxf, y=y+dy+dyf, z=z, walkType=walkType}
            end
            table.insert(tasks, task)

        end
    else
        local task = {action="Time", anim="Shrug", time=200}
        table.insert(tasks, task)
    end

    return {status=true, next="Follow", tasks=tasks}
end



