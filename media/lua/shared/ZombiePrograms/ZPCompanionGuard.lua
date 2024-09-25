ZombiePrograms = ZombiePrograms or {}

ZombiePrograms.CompanionGuard = {}
ZombiePrograms.CompanionGuard.Stages = {}

ZombiePrograms.CompanionGuard.Init = function(bandit)
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

ZombiePrograms.CompanionGuard.Prepare = function(bandit)
    local tasks = {}
    local world = getWorld()
    local cell = getCell()
    local cm = world:getClimateManager()
    local dls = cm:getDayLightStrength()

    Bandit.ForceStationary(bandit, true)

    Bandit.SetWeapons(bandit, Bandit.GetWeapons(bandit))
    
    local primary = Bandit.GetBestWeapon(bandit)

    local secondary
    if SandboxVars.Bandits.General_CarryTorches and dls < 0.3 then
        secondary = "Base.HandTorch"
    end

    local task = {action="Equip", itemPrimary=primary, itemSecondary=secondary}
    table.insert(tasks, task)

    return {status=true, next="Guard", tasks=tasks}
end

ZombiePrograms.CompanionGuard.Guard = function(bandit)
    local tasks = {}

    -- GUARD POST MUST BE PRESENT OTHERWISE SWITH PROGRAM
    -- at guardpost, switch program
    local atGuardpost = BanditGuardpost.At(bandit)
    if not atGuardpost then

        -- we abandon the temporary guardpost only if the player is endangered
        local temporaryGuardpost = false
        if not Bandit.IsHostile(bandit) then

            -- loop through players to see who's endangered
            local playerList = BanditPlayer.GetPlayers()
            for i=0, playerList:size()-1 do
                local player = playerList:get(i)
                if player then
                    local dist = math.sqrt(math.pow(bandit:getX() - player:getX(), 2) + math.pow(bandit:getY() - player:getY(), 2))
                    if bandit:getZ() == player:getZ() and dist < 5 and not player:getVehicle() then

                        -- determine if safe
                        local closestZombie = BanditUtils.GetClosestZombieLocation(bandit)
                        local closestBandit = BanditUtils.GetClosestEnemyBanditLocation(bandit)
                        if closestZombie.dist > 3 and closestBandit.dist > 3 then 
                            temporaryGuardpost = true
                        end
                    end
                end
            end
        end
        
        if not temporaryGuardpost then
            Bandit.SetProgram(bandit, "Companion", {})
            return {status=true, next="Prepare", tasks=tasks}
        end
    end
    
    local outOfAmmo = Bandit.IsOutOfAmmo(bandit)

    local action = ZombRand(50)

    local gameTime = getGameTime()
    local alfa = gameTime:getMinutes() * 4
    local theta = alfa * math.pi / 180
    local x1 = bandit:getX() + 3 * math.cos(theta)
    local y1 = bandit:getY() + 3 * math.sin(theta)

    local master = BanditPlayer.GetMasterPlayer(bandit)
    if master then
        -- be polite, if master is close, face him, otherwise look somewhere else
        local dist = math.sqrt(math.pow(bandit:getX() - master:getX(), 2) + math.pow(bandit:getY() - master:getY(), 2))
        if dist < 3 then
            x1, y1 = master:getX(), master:getY()
        end
    end

    if action == 0 then
        local task = {action="Time", anim="ShiftWeight", time=200}
        table.insert(tasks, task)
    elseif action == 1 then
        local task = {action="Time", anim="Cough", time=200}
        table.insert(tasks, task)
    elseif action == 2 then
        local task = {action="Time", anim="ChewNails", time=200}
        table.insert(tasks, task)
    elseif action == 3 then
        local task = {action="Time", anim="Smoke", time=200}
        table.insert(tasks, task)
        table.insert(tasks, task)
        table.insert(tasks, task)
    elseif action == 4 then
        local task = {action="Time", anim="PullAtCollar", time=200}
        table.insert(tasks, task)
    elseif action == 5 then
        local task = {action="Time", anim="Sneeze", time=200}
        table.insert(tasks, task)
        addSound(getPlayer(), bandit:getX(), bandit:getY(), bandit:getZ(), 7, 60)
    elseif action == 6 then
        local task = {action="Time", anim="WipeBrow", time=200}
        table.insert(tasks, task)
    elseif action == 7 then
        local task = {action="Time", anim="WipeHead", time=200}
        table.insert(tasks, task)

    elseif not outOfAmmo then
        local anim
        local weaponType = bandit:getVariableString("BanditPrimaryType")
        if weaponType == "rifle" then anim = "AimRifle" end
        if weaponType == "handgun" then anim = "AimPistol" end

        local task = {action="FaceLocation", anim=anim, x=x1, y=y1, time=100}
        table.insert(tasks, task)
    else
        local task = {action="Time", anim="ShiftWeight", time=200}
        table.insert(tasks, task)
    end

    return {status=true, next="Guard", tasks=tasks}
end



