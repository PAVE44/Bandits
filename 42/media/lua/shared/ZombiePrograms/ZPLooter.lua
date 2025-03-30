ZombiePrograms = ZombiePrograms or {}

ZombiePrograms.Looter = {}
ZombiePrograms.Looter.Stages = {}

ZombiePrograms.Looter.Init = function(bandit)
end

ZombiePrograms.Looter.Prepare = function(bandit)
    local tasks = {}
    local world = getWorld()
    local cell = getCell()
    local cm = world:getClimateManager()
    local dls = cm:getDayLightStrength()

    local weapons = Bandit.GetWeapons(bandit)
    local primary = Bandit.GetBestWeapon(bandit)

    Bandit.ForceStationary(bandit, false)
    Bandit.SetWeapons(bandit, weapons)

    local secondary
    if SandboxVars.Bandits.General_CarryTorches and dls < 0.3 then
        secondary = "Base.HandTorch"
    end

    if weapons.primary.name and weapons.secondary.name then
        local task1 = {action="Unequip", time=100, itemPrimary=weapons.secondary.name}
        table.insert(tasks, task1)
    end

    local task2 = {action="Equip", itemPrimary=primary, itemSecondary=secondary}
    table.insert(tasks, task2)

    return {status=true, next="Main", tasks=tasks}
end

ZombiePrograms.Looter.Main = function(bandit)
    local tasks = {}
    local world = getWorld()
    local cell = getCell()
    local cm = world:getClimateManager()
    local dls = cm:getDayLightStrength()
    local bx, by, bz = bandit:getX(), bandit:getY(), bandit:getZ()
    local outOfAmmo = Bandit.IsOutOfAmmo(bandit)
    local walkType = "Walk"
    local endurance = 0.00
    local health = bandit:getHealth()

    if dls < 0.3 then
        if SandboxVars.Bandits.General_SneakAtNight then
            walkType = "SneakWalk"
            endurance = 0
        end
    end
 
    local target = {}
    local enemy

    local target, enemy = BanditUtils.GetTarget(bandit, true)
    
    -- engage with target
    if target.x and target.y and target.z then
        local targetSquare = cell:getGridSquare(target.x, target.y, target.z)
        if targetSquare then
            Bandit.SayLocation(bandit, targetSquare)
        end

        if bandit:isInARoom() then
            if outOfAmmo then
                walkType = "Run"
            else
                walkType = "WalkAim"
            end
        else
            if target.dist > 50 then
                walkType = "Run"
            elseif target.dist > 35 then
                walkType = "Walk"
            else
                walkType = "WalkAim"
            end
        end

        local tx, ty, tz = target.x, target.y, target.z
    
        if enemy then
            local weapon = enemy:getPrimaryHandItem()
            if weapon and weapon:IsWeapon() then
                local weaponType = WeaponType.getWeaponType(weapon)
                if weaponType == WeaponType.firearm or weaponType == WeaponType.handgun then
                    walkType = "Run"
                end
            end

            if target.fx and target.fy and (enemy:isRunning()  or enemy:isSprinting()) then
                tx, ty = target.fx, target.fy
            end
        end

        if health < 0.8 then
            walkType = "Limp"
            endurance = 0
        end 

        table.insert(tasks, BanditUtils.GetMoveTask(endurance, tx, ty, tz, walkType, target.dist))
        return {status=true, next="Main", tasks=tasks}
    end

    local task = {action="Time", anim="Shrug", time=200}
    table.insert(tasks, task)

    return {status=true, next="Main", tasks=tasks}
end

ZombiePrograms.Looter.Wait = function(bandit)
    return {status=true, next="Main", tasks={}}
end

