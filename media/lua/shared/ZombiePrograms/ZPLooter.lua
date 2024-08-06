ZombiePrograms = ZombiePrograms or {}

ZombiePrograms.Looter = {}
ZombiePrograms.Looter.Stages = {}

ZombiePrograms.Looter.Init = function(bandit)
end

ZombiePrograms.Looter.Prepare = function(bandit)

    Bandit.SetWeapons(bandit, Bandit.GetWeapons(bandit))

    return {status=true, next="Operate", tasks={}}
end

ZombiePrograms.Looter.Operate = function(bandit)
    local tasks = {}
    local weapons = Bandit.GetWeapons(bandit)

    -- update walk type
    local world = getWorld()
    local cell = getCell()
    local cm = world:getClimateManager()
    local dls = cm:getDayLightStrength()
    local weapons = Bandit.GetWeapons(bandit)
    local outOfAmmo = Bandit.IsOutOfAmmo(bandit)
    local hands = bandit:getVariableString("BanditPrimaryType")
 
    local walkType = "WalkAim"
    local endurance = 0 -- -0.02
    local secondary
    if dls < 0.3 then
        if SandboxVars.Bandits.General_CarryTorches then
            if hands == "barehand" or hands == "onehanded" or hands == "handgun" then
                secondary = "Base.HandTorch"
            end
        end

        if SandboxVars.Bandits.General_SneakAtNight then
            walkType = "SneakWalk"
            endurance = 0
        end
    end

    local health = bandit:getHealth()
    if health < 0.4 then
        walkType = "Limp"
        endurance = 0
    end 
 
    local handweapon = bandit:getVariableString("BanditWeapon") 
    
    local target = {}

    local closestPlayer = {}
    closestPlayer.x, closestPlayer.y, closestPlayer.z, closestPlayer.dist, closestPlayer.id = BanditUtils.GetClosestPlayerLocation(bandit, true)

    if closestPlayer.x and closestPlayer.y and closestPlayer.z then
        Bandit.Say(bandit, "SPOTTED")
        Bandit.SetProgram(bandit, "Bandit", {})
        return {status=true, next="Follow", tasks={}}
    end

    local closestZombie = {}
    closestZombie.x, closestZombie.y, closestZombie.z, closestZombie.dist, closestZombie.id = BanditUtils.GetClosestZombieLocation(bandit)
    target = closestZombie

    if target.x and target.y and target.z then

        -- out of ammo, get close
        local minDist = 6
        if outOfAmmo then
            minDist = 1.51
        end

        if target.dist > minDist then

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
                if target.dist > 30 then
                    task = {action="Move", time=25, endurance=endurance, x=target.x+dx+dxf, y=target.y+dy+dyf, z=target.z, walkType=walkType}
                else
                    task = {action="GoTo", time=50, endurance=endurance, x=target.x+dx+dxf, y=target.y+dy+dyf, z=target.z, walkType=walkType}
                end
            else
                task = {action="Move", time=50, endurance=endurance, x=target.x - 1 + ZombRand(3) + ZombRandFloat(-0.5, 0.5), y=target.y - 1 + ZombRand(3) + ZombRandFloat(-0.5, 0.5), z=target.z, walkType=walkType}
                -- task = {action="Move", time=50, x=x+dx+dxf, y=y+dy+dyf, z=z, walkType=walkType}
            end
            table.insert(tasks, task)

        end
    end

    return {status=true, next="Operate", tasks=tasks}
end



