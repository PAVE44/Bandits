ZombiePrograms = ZombiePrograms or {}

local function GetMoveTask(endurance, x, y, z, walkType, dist)
    local gamemode = getWorld():getGameMode()
    local task
    if gamemode == "Multiplayer" then
        if dist > 30 then
            task = {action="Move", time=25, endurance=endurance, x=x, y=y, z=z, walkType=walkType}
        else
            task = {action="GoTo", time=50, endurance=endurance, x=x, y=y, z=z, walkType=walkType}
        end
    else
        task = {action="Move", time=25, endurance=endurance, x=x, y=y, z=z, walkType=walkType}
    end
    return task
end

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

    Bandit.ForceStationary(bandit, false)
    Bandit.SetWeapons(bandit, Bandit.GetWeapons(bandit))
    
    local primary = Bandit.GetBestWeapon(bandit)

    local secondary
    if SandboxVars.Bandits.General_CarryTorches and dls < 0.3 then
        secondary = "Base.HandTorch"
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

    if not master then
        local task = {action="Time", anim="Shrug", time=200}
        table.insert(tasks, task)
        return {status=true, next="Follow", tasks=tasks}
    end

    local dist = math.sqrt(math.pow(bandit:getX() - master:getX(), 2) + math.pow(bandit:getY() - master:getY(), 2))

    walkType = "Walk"
    local endurance = 0.00
    if master:isRunning() or master:isSprinting() then
        walkType = "Run"
        endurance = -0.07
    elseif master:isSneaking() and dist<12 then
        walkType = "SneakWalk"
        endurance = -0.01
    end

    if master:isAiming() and not outOfAmmo and dist<8 then
        walkType = "WalkAim"
        endurance = 0
    end

    local health = bandit:getHealth()
    if health < 0.4 then
        walkType = "Limp"
        endurance = 0
    end 

    -- at guardpost, switch program
    local atGuardpost = BanditGuardpost.At(bandit)
    if atGuardpost then
        print ("AT GUARDPOST")
        Bandit.SetProgram(bandit, "CompanionGuard", {})
        return {status=true, next="Prepare", tasks=tasks}
    end
    
    -- look for guardpost
    local guardpost = BanditGuardpost.GetClosestFree(bandit, 40)
    if guardpost then
        table.insert(tasks, GetMoveTask(endurance, guardpost.x, guardpost.y, guardpost.z, walkType, dist))
        return {status=true, next="Follow", tasks=tasks}
    end

    -- go to player
    if true then
        local minDist = 4
        if dist > minDist then
            local id = BanditUtils.GetCharacterID(bandit)
            local dx = master:getX() + (id % 4) - 2
            local dy = master:getY() + (id % 5) - 2.5
            local dz = master:getZ()
            local dxf = ((id % 10) - 5) / 10
            local dyf = ((id % 11) - 5) / 10
            table.insert(tasks, GetMoveTask(endurance, dx+dxf, dy+dyf, dz, walkType, dist))
        end
    end

    return {status=true, next="Follow", tasks=tasks}
end



        --[[
        local vehicle = master:getVehicle()
        if vehicle then
            print (vehicle:isStopped())
            if dist < 1.6 then
                local bvehicle = bandit:getVehicle()
                if not bvehicle then
                    print ("ENTER VEH")
                    local vx = bandit:getForwardDirection():getX()
                    local vy = bandit:getForwardDirection():getY()
                    local forwardVector = Vector3f.new(vx, vy, 0)
                    bandit:enterVehicle(vehicle, 1, forwardVector)
                end
                if vehicle:isStopped() then
                    -- 
                else
                    bandit:changeState(ZombieOnGroundState.instance())
                end
            end
        else
            local bvehicle = bandit:getVehicle()
            if bvehicle then
                print ("EXIT VEH")
                --ZombieOnGroundState.instance():exit(bandit)
                --bandit:changeState(ZombieIdleState.instance())
                bvehicle:exit(bandit)
                -- bandit:setBumpType("Cough")
            end
        end
        ]]