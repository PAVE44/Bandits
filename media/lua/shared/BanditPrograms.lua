-- shared subprograms available as subs for other programs

local function predicateAll(item)
    -- item:getType()
	return true
end

BanditPrograms = BanditPrograms or {}

BanditPrograms.Weapon = BanditPrograms.Weapon or {}

BanditPrograms.Weapon.Switch = function(bandit, itemName)

    local tasks = {}
    bandit:clearAttachedItems()

    -- check what is equippped that needs to be deattached
    local old = bandit:getPrimaryHandItem()
    if old then
        local task = {action="Unequip", time=200, itemPrimary=old:getFullType()}
        table.insert(tasks, task)
    end

    -- grab new weapon
    local new = InventoryItemFactory.CreateItem(itemName)
    if new then
        local task = {action="Equip", itemPrimary=itemName}
        table.insert(tasks, task)
    end
    return tasks
end

BanditPrograms.Weapon.Aim = function(bandit, enemyCharacter, slot)
    local tasks = {}

    local dist = math.sqrt(math.pow(bandit:getX() - enemyCharacter:getX(), 2) + math.pow(bandit:getY() - enemyCharacter:getY(), 2))
    local aimTimeMin = SandboxVars.Bandits.General_GunReflexMin or 18
    local aimTimeSurp = math.floor(dist ^ 1.1)

    if instanceof(enemyCharacter, "IsoZombie") then
        aimTimeSurp = math.floor(aimTimeSurp / 2)
    end
    if Bandit.IsDNA(bandit, "slow") then
        aimTimeSurp = aimTimeSurp + 11
    end

    if aimTimeMin + aimTimeSurp > 0 then

        local anim
        local sound
        local asn = enemyCharacter:getActionStateName()
        local down = enemyCharacter:isProne() or enemyCharacter:isBumpFall() or asn == "onground" or asn == "getup"
        if slot == "primary" then
            sound = "M14BringToBear"
            if dist < 2.5 and down then
                anim = "AimRifleLow"
            else
                anim = "IdleToAimRifle"
            end
        else
            sound = "M9BringToBear"
            if dist < 2.5 and down then
                anim = "AimPistolLow"
            else
                anim = "IdleToAimPistol"
            end
        end

        local task = {action="Aim", anim=anim, sound=sound, x=enemyCharacter:getX(), y=enemyCharacter:getY(), time=aimTimeMin + aimTimeSurp}
        table.insert(tasks, task)
    end
    return tasks
end

BanditPrograms.Weapon.Shoot = function(bandit, enemyCharacter, slot)
    local tasks = {}

    local brain = BanditBrain.Get(bandit)
    local weapon = brain.weapons[slot]

    local dist = math.sqrt(math.pow(bandit:getX() - enemyCharacter:getX(), 2) + math.pow(bandit:getY() - enemyCharacter:getY(), 2))
    local firingtime = weapon.shotDelay + math.floor(dist ^ 1.1)
    if Bandit.IsDNA(bandit, "slow") then
        firingtime = firingtime + 3
    end

    local anim
    local asn = enemyCharacter:getActionStateName()
    local down = enemyCharacter:isProne() or enemyCharacter:isBumpFall() or asn == "onground" or asn == "getup"
    if slot == "primary" then
        if dist < 2.5 and down then
            anim = "AimRifleLow"
        else
            anim = "AimRifle"
        end
    else
        if dist < 2.5 and down then
            anim = "AimPistolLow"
        else
            anim = "AimPistol"
        end
    end

    local task = {action="Shoot", anim=anim, time=firingtime, slot=slot, x=enemyCharacter:getX(), y=enemyCharacter:getY(), z=enemyCharacter:getZ()}
    table.insert(tasks, task)

    return tasks
end

BanditPrograms.Weapon.Reload = function(bandit, slot)
    local tasks = {}

    local brain = BanditBrain.Get(bandit)
    local weapon = brain.weapons[slot]

    local soundEject
    local soundInsert
    if slot == "primary" then
        soundEject = "M14EjectAmmo"
        soundInsert = "M14InsertAmmo"
    else
        soundEject = "M9EjectAmmo"
        soundInsert = "M9InsertAmmo"
    end

    local task = {action="Drop", itemType=weapon.magName, anim="UnloadRifle", sound=soundEject, time=90}
    table.insert(tasks, task)

    local task = {action="Reload", anim="ReloadRifle", slot=slot, sound=soundInsert, time=90}
    table.insert(tasks, task)

    return tasks
end

BanditPrograms.Idle = function(bandit)
    local tasks = {}
    local action = ZombRand(50)

    local outOfAmmo = Bandit.IsOutOfAmmo(bandit)
    local gameTime = getGameTime()
    local alfa = gameTime:getMinutes() * 4
    local theta = alfa * math.pi / 180
    local x1 = bandit:getX() + 3 * math.cos(theta)
    local y1 = bandit:getY() + 3 * math.sin(theta)

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
        local sound
        local weaponType = bandit:getVariableString("BanditPrimaryType")
        if weaponType == "rifle" then
            sound = "M14BringToBear"
            anim1 = "IdleToAimRifle"
            anim2 = "AimRifle"
        end
        if weaponType == "handgun" then 
            sound = "M9BringToBear"
            anim1 = "IdleToAimPistol"
            anim2 = "AimPistol"
        end

        local task1 = {action="Aim", sound=sound, anim=anim1, x=x1, y=y1, time=30}
        table.insert(tasks, task1)

        local task2 = {action="Aim", anim=anim2, x=x1, y=y1, time=100}
        table.insert(tasks, task2)

        local task3 = {action="Aim", anim=anim2, x=x1, y=y1, time=100}
        table.insert(tasks, task3)
    else
        local task = {action="Time", anim="ShiftWeight", time=200}
        table.insert(tasks, task)
    end
    return tasks
end 

BanditPrograms.Container = BanditPrograms.Container or {}

BanditPrograms.Container.WeaponLoot = function(bandit, object, container)
    local tasks = {}
    local weapons = Bandit.GetWeapons(bandit)

    local items = ArrayList.new()
    container:getAllEvalRecurse(predicateAll, items)

    -- analyze container contents
    for i=0, items:size()-1 do
        local item = items:get(i)
        if item:IsWeapon() then
            local weaponItem = item
            local weaponName = weaponItem:getFullType() 
            local weaponType = WeaponType.getWeaponType(weaponItem)

            local slots = {"primary", "secondary"}
            for _, slot in pairs(slots) do

                local wTab = BanditWeapons.Primary
                local wType = WeaponType.firearm
                if slot == "secondary" then
                    wTab = BanditWeapons.Secondary
                    wType = WeaponType.handgun
                end

                -- no primary weapon or empty, check if we can grab weapon
                if not weapons[slot] or (weapons[slot].magCount == 0 and weapons[slot].bulletsLeft == 0) then
                    
                    -- it must be correct type, and it must in in bandit weapon registry
                    if weaponType == wType then
                        for k, v in pairs(wTab) do
                            if weaponName == v.name then

                                local toRemove = {}
                                local toAdd = {}

                                -- found gun
                                local weaponMagName = v.magName
                                local weaponMagSize = v.magSize
                                local weaponShotSound = v.shotSound
                                local weaponShotDelay = v.shotDelay

                                -- now find mags in the same container
                                local weaponBullets = 0
                                for j=0, items:size()-1 do
                                    local magItem = items:get(j)
                                    local magName = magItem:getFullType()
                                    local magBulletsLeft = magItem:getCurrentAmmoCount()
                                    if magName == weaponMagName and magBulletsLeft > 0 then
                                        table.insert(toRemove, magName)
                                        weaponBullets = weaponBullets + magBulletsLeft
                                    end
                                end

                                -- got gun and bullets, lets go take it
                                if weaponBullets > 0 then

                                    table.insert(toRemove, weaponName)

                                    local bx, by, bz
                                    local lootDist
                                    local lootAnim
                                    local square = object:getSquare()
                                    if square:isFree(false) then
                                        bx = object:getX()
                                        by = object:getY()
                                        bz = object:getZ()
                                        lootDist = 1.3
                                        lootAnim = "LootLow"
                                    else
                                        local asquare = AdjacentFreeTileFinder.Find(square, bandit)
                                        if asquare then
                                            bx = asquare:getX()
                                            by = asquare:getY()
                                            bz = asquare:getZ()
                                            lootDist = 2.1
                                            lootAnim = "Loot"
                                        end
                                    end

                                    local dist = math.sqrt(math.pow(bandit:getX() - bx, 2) + math.pow(bandit:getY() - by, 2))

                                    -- we are here, take it
                                    if dist < lootDist then

                                        toAdd[slot] = {}
                                        toAdd[slot].name = weaponName
                                        toAdd[slot].magSize = weaponMagSize
                                        toAdd[slot].magName = weaponMagName
                                        toAdd[slot].shotSound = weaponShotSound
                                        toAdd[slot].shotDelay = weaponShotDelay
                                        toAdd[slot].magCount = math.floor(weaponBullets / weaponMagSize)
                                        toAdd[slot].bulletsLeft = weaponBullets % weaponMagSize

                                        local task = {action="LootWeapons", anim=lootAnim, time=#toRemove * 50, x=object:getX(), y=object:getY(), z=object:getZ(), toAdd=toAdd, toRemove=toRemove}
                                        table.insert(tasks, task)
                                    -- go to location
                                    else
                                        table.insert(tasks, BanditUtils.GetMoveTask(endurance, bx, by, bz, "Run", dist))
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return tasks
end

BanditPrograms.Container.Loot = function(bandit, object, container)
    local tasks = {}

    local bx, by, bz
    local lootDist
    local lootAnim
    local square = object:getSquare()
    if square:isFree(false) then
        bx = object:getX()
        by = object:getY()
        bz = object:getZ()
        lootDist = 1.1
        lootAnim = "LootLow"
    else
        local asquare = AdjacentFreeTileFinder.Find(square, bandit)
        if asquare then
            bx = asquare:getX()
            by = asquare:getY()
            bz = asquare:getZ()
            lootDist = 2.1
            lootAnim = "Loot"
        end
    end

    local dist = math.sqrt(math.pow(bandit:getX() - bx, 2) + math.pow(bandit:getY() - by, 2))

    -- we are here, take it
    if dist < lootDist then

        local items = ArrayList.new()
        container:getAllEvalRecurse(predicateAll, items)
    
        -- analyze container contents
        for i=0, items:size()-1 do
            local item = items:get(i)
        end

        local task = {action="LootItems", anim=lootAnim, time=items:size() * 50, x=object:getX(), y=object:getY(), z=object:getZ()}
        table.insert(tasks, task)
    -- go to location
    else
        table.insert(tasks, BanditUtils.GetMoveTask(endurance, bx, by, bz, "Run", dist))
    end
                 
    return tasks
end