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
    -- local weapons = Bandit.GetWeapons(bandit)
 
    -- If at guardpost, switch to the CompanionGuard program.
    local atGuardpost = BanditGuardpost.At(bandit)
    if atGuardpost then
        print ("AT GUARDPOST")
        Bandit.SetProgram(bandit, "CompanionGuard", {})
        return {status=true, next="Prepare", tasks=tasks}
    end
    
    -- Companion logic depends on one of the players who is the master od the companion
    -- if there is no master, there is nothing to do.
    local master = BanditPlayer.GetMasterPlayer(bandit)
    if not master then
        local task = {action="Time", anim="Shrug", time=200}
        table.insert(tasks, task)
        return {status=true, next="Follow", tasks=tasks}
    end
    
    -- update walktype
    local walkType = "Walk"
    local endurance = 0.00
    local vehicle = master:getVehicle()
    local dist = math.sqrt(math.pow(bandit:getX() - master:getX(), 2) + math.pow(bandit:getY() - master:getY(), 2))

    if master:isRunning() or master:isSprinting() or vehicle then
        walkType = "Run"
        endurance = -0.07
    elseif master:isSneaking() and dist<12 then
        walkType = "SneakWalk"
        endurance = -0.01
    end

    local outOfAmmo = Bandit.IsOutOfAmmo(bandit)
    if master:isAiming() and not outOfAmmo and dist < 8 then
        walkType = "WalkAim"
        endurance = 0
    end

    local health = bandit:getHealth()
    if health < 0.4 then
        walkType = "Limp"
        endurance = 0
    end 
   
    -- If the player is in the vehicle, the companion should join him.
    -- If the player exits the vehicle, so should the companion.
    if vehicle then
        if dist < 2.2 then
            local bvehicle = bandit:getVehicle()
            if bvehicle then
                bandit:changeState(ZombieOnGroundState.instance())
                return {status=true, next="Follow", tasks=tasks}
            else
                print ("ENTER VEH")
                local vx = bandit:getForwardDirection():getX()
                local vy = bandit:getForwardDirection():getY()
                local forwardVector = Vector3f.new(vx, vy, 0)

                for seat=1, 10 do
                    if vehicle:isSeatInstalled(seat) and not vehicle:isSeatOccupied(seat) then
                        bandit:enterVehicle(vehicle, seat, forwardVector)
                        bandit:playSound("VehicleDoorOpen")
                        break
                    end
                end
            end
        end
    else
        local bvehicle = bandit:getVehicle()
        if bvehicle then
            print ("EXIT VEH")
            -- After exiting the vehicle, the companion is in the ongroundstate.
            -- Additionally he is under the car. This is fixed in BanditUpdate loop. 
            bandit:setVariable("BanditImmediateAnim", true)
            bvehicle:exit(bandit)
            bandit:playSound("VehicleDoorClose")
        end
    end

    -- Companions intention is to generally stay with the player
    -- however, if the enemy is close, the companion should engage
    -- but only if player is not too far, kind of a proactive defense.
    if dist < 12 then
        local closestZombie = BanditUtils.GetClosestZombieLocation(bandit)
        local closestBandit = BanditUtils.GetClosestEnemyBanditLocation(bandit)
        local closestEnemy = closestZombie

        if closestBandit.dist < closestZombie.dist then 
            closestEnemy = closestBandit 
        end

        if closestEnemy.dist < 8 then
            -- We are trying to save the player, so the friendly should act with high motivation
            -- that translates to running pace (even despite limping) and minimal endurance loss.
            walkType = "Run"
            endurance = -0.01
            table.insert(tasks, BanditUtils.GetMoveTask(endurance, closestEnemy.x, closestEnemy.y, closestEnemy.z, walkType, closestEnemy.dist))
            return {status=true, next="Follow", tasks=tasks}
        end
    end
    
    -- If there is a guardpost in the vicinity, take it.
    local guardpost = BanditGuardpost.GetClosestFree(bandit, 40)
    if guardpost then
        table.insert(tasks, BanditUtils.GetMoveTask(endurance, guardpost.x, guardpost.y, guardpost.z, walkType, dist))
        return {status=true, next="Follow", tasks=tasks}
    end

    -- No enemies, no guardposts, so follow the player.
    local minDist = 1
    if dist > minDist then
        local id = BanditUtils.GetCharacterID(bandit)

        local theta = master:getDirectionAngle() * math.pi / 180
        local lx = 3 * math.cos(theta)
        local ly = 3 * math.sin(theta)

        local dx = master:getX() - lx
        local dy = master:getY() - ly
        local dz = master:getZ()
        local dxf = ((id % 10) - 5) / 10
        local dyf = ((id % 11) - 5) / 10
        table.insert(tasks, BanditUtils.GetMoveTask(endurance, dx+dxf, dy+dyf, dz, walkType, dist))
    end

    return {status=true, next="Follow", tasks=tasks}
end
