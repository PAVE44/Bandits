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
    local aimTimeSurp = math.floor(dist ^ 1.2)
    if Bandit.IsDNA(bandit, "slow") then
        aimTimeSurp = aimTimeSurp + 15
    end

    if aimTimeMin + aimTimeSurp > 0 then

        local anim
        if slot == "primary" then
            anim = "AimRifle"
        else
            anim = "AimPistol"
        end

        local task = {action="Aim", anim=anim, x=enemyCharacter:getX(), y=enemyCharacter:getY(), time=aimTimeMin + aimTimeSurp}
        table.insert(tasks, task)
    end
    return tasks
end

BanditPrograms.Weapon.Shoot = function(bandit, enemyCharacter, slot)
    local tasks = {}

    local brain = BanditBrain.Get(bandit)
    local weapon = brain.weapons[slot]

    local dist = math.sqrt(math.pow(bandit:getX() - enemyCharacter:getX(), 2) + math.pow(bandit:getY() - enemyCharacter:getY(), 2))
    local firingtime = weapon.shotDelay + math.floor(dist ^ 1.2)
    if Bandit.IsDNA(bandit, "slow") then
        firingtime = firingtime + 5
    end

    local anim
    if slot == "primary" then
        anim = "AimRifle"
    else
        anim = "AimPistol"
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

BanditPrograms.Container = BanditPrograms.Container or {}

BanditPrograms.Container.Loot = function(bandit, object, container)
    local tasks = {}
    local weapons = Bandit.GetWeapons(bandit)

    local items = ArrayList.new()
    container:getAllEvalRecurse(predicateAll, items)

    -- analyze container contents
    for i=0, items:size()-1 do
        local weaponItem = items:get(i)
        local weaponName = weaponItem:getFullType() 
        if weaponItem:IsWeapon() then
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

                                        toAdd[slot] = {}
                                        toAdd[slot].name = weaponName
                                        toAdd[slot].magSize = weaponMagSize
                                        toAdd[slot].magName = weaponMagName
                                        toAdd[slot].shotSound = weaponShotSound
                                        toAdd[slot].shotDelay = weaponShotDelay
                                        toAdd[slot].magCount = math.floor(weaponBullets / weaponMagSize)
                                        toAdd[slot].bulletsLeft = weaponBullets % weaponMagSize

                                        local task = {action="LootBody", anim=lootAnim, time=#toRemove * 50, x=object:getX(), y=object:getY(), z=object:getZ(), toAdd=toAdd, toRemove=toRemove}
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