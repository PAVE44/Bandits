ZombiePrograms = ZombiePrograms or {}

ZombiePrograms.CompanionGuard = {}
ZombiePrograms.CompanionGuard.Stages = {}

ZombiePrograms.CompanionGuard.Init = function(bandit)
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
    local master = BanditPlayer.GetMasterPlayer(bandit)

    -- GUARD POST MUST BE PRESENT OTHERWISE SWITH PROGRAM
    -- at guardpost, switch program
    local atGuardpost = BanditPost.At(bandit, "guard")
    if not atGuardpost then

        Bandit.SetProgram(bandit, "Companion", {})
        return {status=true, next="Prepare", tasks=tasks}

        --[[
        -- we abandon the temporary guardpost only if the player is endangered
        local temporaryGuardpost = false
        if not Bandit.IsHostile(bandit) then

            -- loop through players to see who's endangered
            local playerList = BanditPlayer.GetPlayers()
            for i=0, playerList:size()-1 do
                local player = playerList:get(i)
                if player then
                    local dist = math.sqrt(math.pow(bandit:getX() - player:getX(), 2) + math.pow(bandit:getY() - player:getY(), 2))
                    if bandit:getZ() == player:getZ() and dist < 3 and not player:getVehicle() then

                        -- determine if safe
                        local closestZombie = BanditUtils.GetClosestZombieLocation(bandit)
                        local closestBandit = BanditUtils.GetClosestEnemyBanditLocation(bandit)
                        if closestZombie.dist > 10 and closestBandit.dist > 10 then 
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
        ]]

    end
    
    local idle = true
    local x1, y1
    local outOfAmmo = Bandit.IsOutOfAmmo(bandit)

    local closestZombie = BanditUtils.GetClosestZombieLocation(bandit)
    local closestBandit = BanditUtils.GetClosestEnemyBanditLocation(bandit)
    local closestEnemy = closestZombie

    if closestBandit.dist < closestZombie.dist then 
        closestEnemy = closestBandit 
    end

    if closestEnemy.dist < 12 then
        local task = {action="FaceLocation", anim=anim, x=closestEnemy.x, y=closestEnemy.y, time=100}
        table.insert(tasks, task)
    else
        local subTasks = BanditPrograms.Idle(bandit)
        if #subTasks > 0 then
            for _, subTask in pairs(subTasks) do
                table.insert(tasks, subTask)
            end
        end
    end

    return {status=true, next="Guard", tasks=tasks}
end



