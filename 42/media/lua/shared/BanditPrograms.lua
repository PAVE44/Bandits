require "BanditCompatibility"
-- shared subprograms available as subs for other programs

local function predicateAll(item)
    -- item:getType()
	return true
end

local function predicateSpoilableFood(item)
    local category = item:getDisplayCategory()
    if category == "Food" then
        local canSpoil = item:getOffAgeMax() < 1000
        if canSpoil then
            return true
        end
    end
    return false
end

local function predicateMelee(item)
    if item:IsWeapon() then
        local weaponType = WeaponType.getWeaponType(item)
        if weaponType ~= WeaponType.firearm and weaponType ~= WeaponType.handgun then
            return true
        end
    end
    return false
end

local function getItem(bandit, itemTypeTab, cnt)
    local task
    local obj
    local itemType
    for _, it in pairs(itemTypeTab) do
        local o = BanditPlayerBase.GetContainerWithItem(bandit, it, cnt)
        if o then 
            obj = o
            itemType = it
            break
        end
    end

    if not obj then return end

    local square = obj
    if not instanceof(obj, "IsoGridSquare") then square = obj:getParent():getSquare() end

    local asquare = AdjacentFreeTileFinder.Find(square, bandit)
    if not asquare then return end

    local dist = BanditUtils.DistTo(bandit:getX(), bandit:getY(), asquare:getX() + 0.5, asquare:getY() + 0.5)
    if dist > 0.90 then
        -- bandit:addLineChatElement(("go collect: " .. itemType), 1, 1, 1)
        task = BanditUtils.GetMoveTask(0, asquare:getX(), asquare:getY(), asquare:getZ(), "Walk", dist, false)
    else
        if instanceof(obj, "IsoGridSquare") then
            -- bandit:addLineChatElement(("pickup " .. itemType), 1, 1, 1)
            task = {action="PickUp", anim="LootLow", itemType=itemType, x=square:getX(), y=square:getY(), z=square:getZ(), cnt=cnt}
        else
            -- bandit:addLineChatElement(("take from container: " .. itemType), 1, 1, 1)
            task = {action="TakeFromContainer", anim="Loot", itemType=itemType, x=square:getX(), y=square:getY(), z=square:getZ(), cnt=cnt}
        end
    end
    return task
end

BanditPrograms = BanditPrograms or {}

BanditPrograms.Weapon = BanditPrograms.Weapon or {}

BanditPrograms.Weapon.Switch = function(bandit, itemName)

    local tasks = {}

    -- check what is equipped that needs to be deattached
    local old = bandit:getPrimaryHandItem()
    if old then
        local sound = old:getUnequipSound()
        local task = {action="Unequip", sound=sound, time=100, itemPrimary=old:getFullType()}
        table.insert(tasks, task)
    end

    -- grab new weapon
    local new = BanditCompatibility.InstanceItem(itemName)
    if new then
        local sound = new:getEquipSound()
        local task = {action="Equip", sound=sound, itemPrimary=itemName}
        table.insert(tasks, task)
    end
    return tasks
end

BanditPrograms.Weapon.Aim = function(bandit, enemyCharacter, slot)
    local tasks = {}

    local brain = BanditBrain.Get(bandit)
    local weapon = brain.weapons[slot]
    local weaponItem = BanditCompatibility.InstanceItem(weapon.name)

    local sound = weaponItem:getBringToBearSound()
    local dist = BanditUtils.DistTo(bandit:getX(), bandit:getY(), enemyCharacter:getX(), enemyCharacter:getY())
    local aimTimeMin = SandboxVars.Bandits.General_GunReflexMin or 18
    local aimTimeSurp = math.floor(dist * 5)

    if instanceof(enemyCharacter, "IsoZombie") then
        aimTimeSurp = math.floor(aimTimeSurp / 2)
    else
        -- player handicap
        aimTimeSurp = aimTimeSurp + 10
    end

    if aimTimeMin + aimTimeSurp > 0 then

        local anim
        local asn = enemyCharacter:getActionStateName()
        local down = enemyCharacter:isProne() or enemyCharacter:isBumpFall() or asn == "onground" or asn == "getup"
        if slot == "primary" then
            if dist < 2.5 and down then
                anim = "AimRifleLow"
            else
                anim = "IdleToAimRifle"
            end
        else
            if dist < 2.5 and down then
                anim = "AimPistolLow"
            else
                anim = "IdleToAimPistol"
            end
        end

        local time = aimTimeMin + aimTimeSurp
        if time > 60 then time = 60 end

        local task = {action="Aim", anim=anim, sound=sound, x=enemyCharacter:getX(), y=enemyCharacter:getY(), time=time}
        table.insert(tasks, task)
    end
    return tasks
end

BanditPrograms.Weapon.Shoot = function(bandit, enemyCharacter, slot)
    local tasks = {}

    local brain = BanditBrain.Get(bandit)
    local weapon = brain.weapons[slot]
    local weaponItem = BanditCompatibility.InstanceItem(weapon.name)

    local dist = BanditUtils.DistTo(bandit:getX(), bandit:getY(), enemyCharacter:getX(), enemyCharacter:getY())
    local firingtime = weaponItem:getRecoilDelay() + math.floor(dist ^ 1.1)

    local bullets = 1
    local modes = weaponItem:getFireModePossibilities()
    if modes then
        for i=0, modes:size()-1 do
            local mode = modes:get(i)
            if dist < 12 and mode == "Auto" then
                bullets = 2 + ZombRand(6)
                break
            end
        end
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

    local x, y, z = enemyCharacter:getX(), enemyCharacter:getY(), enemyCharacter:getZ()
    local eid = BanditUtils.GetCharacterID(enemyCharacter)
    local task = {action="Shoot", anim=anim, time=firingtime, slot=slot, x=x, y=y, z=z, eid=eid}
    table.insert(tasks, task)
    for i=2, bullets do
        local task = {action="Shoot", anim=anim, time=3, slot=slot, x=x, y=y, z=z, eid=eid}
        table.insert(tasks, task)
    end

    return tasks
end
BanditPrograms.Weapon.Rack = function(bandit, slot)
    local tasks = {}

    local brain = BanditBrain.Get(bandit)
    local weapon = brain.weapons[slot]

    local primaryItem = BanditCompatibility.InstanceItem(weapon.name)
    local reloadType = primaryItem:getWeaponReloadType()
    local magazineType = primaryItem:getMagazineType()

    local rackSound = primaryItem:getRackSound()
    local rackAnim
    if reloadType == "boltaction" then
        rackAnim = "RackRifle"
    elseif reloadType == "boltactionnomag" then
        rackAnim = "RackRifleAim" -- this is different than in Reload
    elseif reloadType == "shotgun" then
        rackAnim = "RackShotgunAim" -- this is different than in Reload
    elseif reloadType == "doublebarrelshotgun" then
        rackAnim = "RackDBShotgun"
    elseif reloadType == "doublebarrelshotgunsawn" then
        rackAnim = "RackDBShotgun"
    elseif reloadType == "handgun" then
        rackAnim = "RackPistol"
    elseif reloadType == "revolver" then
        rackAnim = "RackRevolver"
    end

    if not weapon.racked then
        local task = {action="Rack", slot=slot, anim=rackAnim, sound=rackSound, time=90}
        table.insert(tasks, task)
        return tasks
    end
end

BanditPrograms.Weapon.Reload = function(bandit, slot)
    local tasks = {}

    local brain = BanditBrain.Get(bandit)
    local weapon = brain.weapons[slot]

    local primaryItem = BanditCompatibility.InstanceItem(weapon.name)
    local reloadType = primaryItem:getWeaponReloadType()
    local magazineType = primaryItem:getMagazineType()
    local unloadSound = primaryItem:getEjectAmmoSound()
    local loadSound = primaryItem:getInsertAmmoSound()
    local rackSound = primaryItem:getRackSound()

    local clipMode
    local unloadAnim
    local loadAnim
    local rackAnim

    if reloadType == "boltaction" then
        clipMode = true
        unloadAnim = "UnloadRifle"
        loadAnim = "LoadRifle"
        rackAnim = "RackRifle"
    elseif reloadType == "boltactionnomag" then
        clipMode = false
        unloadAnim = "UnloadShotgun"
        loadAnim = "LoadShotgun"
        rackAnim = "RackRifle"
    elseif reloadType == "shotgun" then
        clipMode = false
        unloadAnim = "UnloadShotgun"
        loadAnim = "LoadShotgun"
        rackAnim = "RackShotgun"
    elseif reloadType == "doublebarrelshotgun" then
        clipMode = false
        unloadAnim = "UnloadDBShotgun"
        loadAnim = "LoadDBShotgun"
        rackAnim = "RackDBShotgun"
    elseif reloadType == "doublebarrelshotgunsawn" then
        clipMode = false
        unloadAnim = "UnloadDBShotgun"
        loadAnim = "LoadDBShotgun"
        rackAnim = "RackDBShotgun"
    elseif reloadType == "handgun" then
        clipMode = true
        unloadAnim = "UnLoadPistol"
        loadAnim = "LoadPistol"
        rackAnim = "RackPistol"
    elseif reloadType == "revolver" then
        clipMode = false
        unloadAnim = "UnloadRevolver"
        loadAnim = "LoadRevolver"
        rackAnim = "RackRevolver"
    end

    if (weapon.type == "mag" and weapon.bulletsLeft <= 0 and weapon.magCount > 0) or
       (weapon.type == "nomag" and weapon.bulletsLeft < weapon.ammoSize and weapon.ammoCount > 0) then
        
        if clipMode then 
            if weapon.clipIn then
                local task = {action="Unload", slot=slot, drop=magazineType, anim=unloadAnim, sound=unloadSound, time=90}
                table.insert(tasks, task)
                return tasks
            else
                local task = {action="Load", slot=slot, anim=loadAnim, sound=loadSound, time=90}
                table.insert(tasks, task)
                return tasks
            end
        else
            local task = {action="Load", slot=slot, anim=loadAnim, sound=loadSound, time=90}
            table.insert(tasks, task)
            return tasks
        end
    elseif not weapon.racked then
        local task = {action="Rack", slot=slot, anim=rackAnim, sound=rackSound, time=90}
        table.insert(tasks, task)
        return tasks
    end

    return tasks
end

BanditPrograms.Weapon.Resupply = function(bandit, slot)
    local tasks = {}

    local cell = getCell()
    local zx, zy, zz = bandit:getX(), bandit:getY(), bandit:getZ()
    local isBareHands = Bandit.IsBareHands(bandit)
    local bestDist = 100
    local body
    local lx, ly, lz
    for y=-5, 5 do
        for x=-5, 5 do
            local square = cell:getGridSquare(zx + x, zy + y, zz)
            if square then

                -- loot bodies
                if square:isFree(false) then
                    local objects = square:getStaticMovingObjects()
                    for i=0, objects:size()-1 do
                        local object = objects:get(i)
                        if instanceof (object, "IsoDeadBody") then
                            local container = object:getContainer()
                            if container and not container:isEmpty() then
                                local dist = math.abs(x) + math.abs(y)
                                if isBareHands then
                                    local items = ArrayList.new()
                                    container:getAllEvalRecurse(predicateMelee, items)
                                    if items:size() > 0 and dist < bestDist then
                                        bestDist = dist
                                        body = object
                                        lx, ly, lz = square:getX(), square:getY(), square:getZ()
                                    end
                                end
                            end
                        end
                    end
                end

                -- loot shelfs
            end
        end
    end

    if body then
        if bestDist > 0.6 then
            local task = BanditUtils.GetMoveTask(0.01, lx + 0.5, ly + 0.5, lz, "Run", bestDist, false)
            table.insert(tasks, task)
            return tasks
        else
            local task = {action="LootWeapons", anim="LootLow", time=250, x=lx, y=ly, z=lz}
            table.insert(tasks, task)
            return tasks
        end
    end
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
        addSound(getSpecificPlayer(0), bandit:getX(), bandit:getY(), bandit:getZ(), 7, 60)
    elseif action == 6 then
        local task = {action="Time", anim="WipeBrow", time=200}
        table.insert(tasks, task)
    elseif action == 7 then
        local task = {action="Time", anim="WipeHead", time=200}
        table.insert(tasks, task)
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

                local wTab = BanditWeapons.GetPrimary()
                local wType = WeaponType.firearm
                if slot == "secondary" then
                    wTab = BanditWeapons.GetSecondary()
                    wType = WeaponType.handgun
                end

                -- no primary weapon or empty, check if we can grab weapon
                if not weapons[slot] or (weapons[slot].magCount == 0 and weapons[slot].bulletsLeft <= 0) then
                    
                    -- it must be correct type, and it must in in bandit weapon registry
                    if weaponType == wType then
                        for k, v in pairs(wTab) do
                            if weaponName == v.name then

                                local toRemove = {}
                                local toAdd = {}

                                -- found gun
                                local weaponMagName = v.magName
                                local weaponMagSize = v.magSize

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
                                        bx = object:getX() + 0.5
                                        by = object:getY() + 0.5
                                        bz = object:getZ()
                                        lootDist = 1.3
                                        lootAnim = "LootLow"
                                    else
                                        local asquare = AdjacentFreeTileFinder.Find(square, bandit)
                                        if asquare then
                                            bx = asquare:getX() + 0.5
                                            by = asquare:getY() + 0.5
                                            bz = asquare:getZ()
                                            lootDist = 2.1
                                            lootAnim = "Loot"
                                        end
                                    end

                                    local dist = BanditUtils.DistTo(bandit:getX(), bandit:getY(), bx, by)

                                    -- we are here, take it
                                    if dist < lootDist then

                                        toAdd[slot] = {}
                                        toAdd[slot].name = weaponName
                                        toAdd[slot].magSize = weaponMagSize
                                        toAdd[slot].magName = weaponMagName
                                        toAdd[slot].magCount = math.floor(weaponBullets / weaponMagSize)
                                        toAdd[slot].bulletsLeft = weaponBullets % weaponMagSize

                                        local task = {action="LootWeapons", anim=lootAnim, time=#toRemove * 50, x=object:getX(), y=object:getY(), z=object:getZ(), toAdd=toAdd, toRemove=toRemove}
                                        table.insert(tasks, task)
                                    -- go to location
                                    else
                                        table.insert(tasks, BanditUtils.GetMoveTask(endurance, bx, by, bz, "Run", dist, false))
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

    local dist = BanditUtils.DistTo(bandit:getX(), bandit:getY(), enemyCharacter:getX(), enemyCharacter:getY())

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
        table.insert(tasks, BanditUtils.GetMoveTask(endurance, bx, by, bz, "Run", dist, false))
    end
                 
    return tasks
end

BanditPrograms.Generator = BanditPrograms.Generator or {}

BanditPrograms.Generator.Refuel = function(bandit, generator)
    local tasks = {}

    local itemType = "Base.PetrolCan"

    -- return with carnister
    local inventory = bandit:getInventory()
    if inventory:getItemCountFromTypeRecurse(itemType) > 0 then
        local dist = BanditUtils.DistTo(bandit:getX(), bandit:getY(), generator:getX() + 0.5, generator:getY() + 0.5)
        if dist > 0.90 then
            table.insert(tasks, BanditUtils.GetMoveTask(0, generator:getX(), generator:getY(), generator:getZ(), "Walk", dist, false))
            return tasks
        else
            if generator:isActivated() then
                local task = {action="GeneratorToggle", anim="LootLow", x=generator:getX(), y=generator:getY(), z=generator:getZ(), status=false}
                table.insert(tasks, task)
                return tasks
            else
                local task1 = {action="Equip", itemPrimary=itemType}
                table.insert(tasks, task1)

                local task2 = {action="GeneratorRefill", anim="Refuel", x=generator:getX(), y=generator:getY(), z=generator:getZ(), status=false}
                table.insert(tasks, task2)

                local task3 = {action="Equip", itemPrimary=Bandit.GetBestWeapon(bandit)}
                table.insert(tasks, task3)

                -- turn on the generator back, but not if the square is already powered
                -- this is likely to be a backup generator and we do not want redundancy
                if not generator:getSquare():haveElectricity() then
                    local task = {action="GeneratorToggle", anim="LootLow", x=generator:getX(), y=generator:getY(), z=generator:getZ(), status=true}
                    table.insert(tasks, task)
                end

                return tasks
            end
        end
    end
    
    -- go get carnister
    local task = getItem(bandit, {itemType}, 1)
    if task then
        table.insert(tasks, task)
    end
    return tasks
end

BanditPrograms.Generator.Repair = function(bandit, generator)
    local tasks = {}

    local itemType = "Base.ElectronicsScrap"

    local condition = generator:getCondition()
    local cnt = math.ceil((100 - condition) / 5)

    -- return with electronics
    local inventory = bandit:getInventory()
    local has = inventory:getItemCountFromTypeRecurse(itemType)
    if inventory:getItemCountFromTypeRecurse(itemType) >= cnt then
        local dist = BanditUtils.DistTo(bandit:getX(), bandit:getY(), generator:getX() + 0.5, generator:getY() + 0.5)
        if dist > 0.90 then
            table.insert(tasks, BanditUtils.GetMoveTask(0, generator:getX(), generator:getY(), generator:getZ(), "Walk", dist, false))
            return tasks
        else
            if generator:isActivated() then
                local task = {action="GeneratorToggle", anim="LootLow", x=generator:getX(), y=generator:getY(), z=generator:getZ(), status=false}
                table.insert(tasks, task)
                return tasks
            else
                local task = {action="Equip", itemPrimary=itemType}
                table.insert(tasks, task)

                local task = {action="GeneratorFix", anim="LootLow", x=generator:getX(), y=generator:getY(), z=generator:getZ()}
                table.insert(tasks, task)

                local task = {action="Equip", itemPrimary=Bandit.GetBestWeapon(bandit)}
                table.insert(tasks, task)

                -- turn on the generator back, but not if the square is already powered
                -- this is likely to be a backup generator and we do not want redundancy
                if not generator:getSquare():haveElectricity() and condition > 99 then
                    local task = {action="GeneratorToggle", anim="LootLow", x=generator:getX(), y=generator:getY(), z=generator:getZ(), status=true}
                    table.insert(tasks, task)
                end

                return tasks
            end
        end
    end
    
    -- go get electronics
    local task = getItem(bandit, {itemType}, cnt)
    if task then
        table.insert(tasks, task)
    end

    return tasks
end

BanditPrograms.Farm = BanditPrograms.Farm or {}

-- allowed water containers for farming
BanditPrograms.Farm.fillables = {}

if BanditCompatibility.GetGameVersion() < 42 then
    table.insert(BanditPrograms.Farm.fillables, "farming.WateredCanFull")
    table.insert(BanditPrograms.Farm.fillables, "farming.WateredCan")
else
    table.insert(BanditPrograms.Farm.fillables, "Base.WateredCan")
end

BanditPrograms.Farm.PredicateFillable = function(item)
    for _, itemType in pairs(BanditPrograms.Farm.fillables) do
        local d = item:getFullType()
        if item:getFullType() == itemType then
	        return true
        end
    end
    return false
end

BanditPrograms.Farm.Water = function(bandit, plant)
    local tasks = {}

    local farm = BanditPlayerBase.GetFarm(bandit)
    if not farm then return tasks end

    -- water plants
    local inventory = bandit:getInventory()
    local items = ArrayList.new()
    inventory:getAllEvalRecurse(BanditPrograms.Farm.PredicateFillable, items)
    if items:size() > 0 then
        local item = items:get(0)

        local itemType = item:getFullType()
        local water = item:getUsedDelta()
        if water > 0 then
            local dist = BanditUtils.DistTo(bandit:getX(), bandit:getY(), farm.x + 0.5, farm.y + 0.5)
            if dist > 0.80 then
                table.insert(tasks, BanditUtils.GetMoveTask(0, farm.x, farm.y, farm.z, "Walk", dist, false))
                return tasks
            else
                local task1 = {action="Equip", itemPrimary=itemType}
                table.insert(tasks, task1)

                local task2 = {action="WaterFarm", anim="PourWateringCan", itemType=itemType, x=farm.x, y=farm.y, z=farm.z}
                table.insert(tasks, task2)

                local task3 = {action="Equip", itemPrimary=Bandit.GetBestWeapon(bandit)}
                table.insert(tasks, task3)

                return tasks
            end
        else
            local source = BanditPlayerBase.GetWaterSource(bandit)
            if source then
                local square = source:getSquare()
                local asquare = AdjacentFreeTileFinder.Find(square, bandit)
                if asquare then
                    local dist = BanditUtils.DistTo(bandit:getX(), bandit:getY(), asquare:getX() + 0.5, asquare:getY() + 0.5)
                    if dist > 0.90 then
                        table.insert(tasks, BanditUtils.GetMoveTask(0, asquare:getX(), asquare:getY(), asquare:getZ(), "Walk", dist, false))
                        return tasks
                    else
                        local task1 = {action="Equip", itemPrimary=itemType}
                        table.insert(tasks, task1)
        
                        local task2 = {action="FillWater", anim="FillBucket", time=400, itemType=itemType, x=square:getX(), y=square:getY(), z=square:getZ()}
                        table.insert(tasks, task2)
        
                        local task3 = {action="Equip", itemPrimary=Bandit.GetBestWeapon(bandit)}
                        table.insert(tasks, task3)

                        return tasks
                    end
                end
            end
        end
    end

    -- go get watering can
    local task = getItem(bandit, BanditPrograms.Farm.fillables, 1)
    if task then
        table.insert(tasks, task)
    end

    return tasks
end

BanditPrograms.Farm.Heal = function(bandit)
    
end

BanditPrograms.Housekeeping = BanditPrograms.Housekeeping or {}

-- allowed water containers for farming
BanditPrograms.Housekeeping.trash = {}
table.insert(BanditPrograms.Housekeeping.trash, "Base.BeerCanEmpty")
table.insert(BanditPrograms.Housekeeping.trash, "Base.PopEmpty")
table.insert(BanditPrograms.Housekeeping.trash, "Base.Pop2Empty")
table.insert(BanditPrograms.Housekeeping.trash, "Base.Pop3Empty")
table.insert(BanditPrograms.Housekeeping.trash, "Base.WineEmpty")
table.insert(BanditPrograms.Housekeeping.trash, "Base.WineEmpty2")
table.insert(BanditPrograms.Housekeeping.trash, "Base.BeerEmpty")
table.insert(BanditPrograms.Housekeeping.trash, "Base.WaterBottleEmpty")
table.insert(BanditPrograms.Housekeeping.trash, "Base.BleechEmpty")
table.insert(BanditPrograms.Housekeeping.trash, "Base.RemouladeEmpty")
table.insert(BanditPrograms.Housekeeping.trash, "Base.WhiskeyEmpty")
table.insert(BanditPrograms.Housekeeping.trash, "Base.PopBottleEmpty")
table.insert(BanditPrograms.Housekeeping.trash, "Base.RippedSheetsDirty")
table.insert(BanditPrograms.Housekeeping.trash, "Base.TinCanEmpty")
table.insert(BanditPrograms.Housekeeping.trash, "Base.UnusableWood")
table.insert(BanditPrograms.Housekeeping.trash, "Base.UnusableMetal")

BanditPrograms.Housekeeping.PredicateTrash = function(item)
    for _, itemType in pairs(BanditPrograms.Housekeeping.trash) do
        if item:getFullType() == itemType then
	        return true
        end
    end
    return false
end

BanditPrograms.Housekeeping.CleanBlood = function(bandit)
    local tasks = {}

    local square = BanditPlayerBase.GetBlood(bandit)
    if not square then return tasks end

    local inventory = bandit:getInventory()

    itemMopType = "Base.Broom"
    itemBleachType = "Base.Bleach"

    local itemMop = inventory:getItemFromType(itemMopType)
    local itemBleach = inventory:getItemFromType(itemBleachType)

    if itemMop and itemBleach then
        local dist = BanditUtils.DistTo(bandit:getX(), bandit:getY(), square:getX() + 0.5, square:getY() + 0.5)
        if dist > 0.80 then
            -- bandit:addLineChatElement(("go clean blood"), 1, 1, 1)
            table.insert(tasks, BanditUtils.GetMoveTask(0, square:getX(), square:getY(), square:getZ(), "Walk", dist, false))
            return tasks
        else
            -- bandit:addLineChatElement(("clean blood"), 1, 1, 1)
            local task1 = {action="Equip", itemPrimary=itemMopType}
            table.insert(tasks, task1)

            local task2 = {action="CleanBlood", anim="Rake", itemType=itemMopType, x=square:getX(), y=square:getY(), z=square:getZ(), time=300}
            table.insert(tasks, task2)

            local task3 = {action="Equip", itemPrimary=Bandit.GetBestWeapon(bandit)}
            table.insert(tasks, task3)

            return tasks
        end
    end

    -- get tools
    local itemType
    if not itemBleach then itemType = itemBleachType end
    if not itemMop then itemType = itemMopType end

    if itemType then
        local task = getItem(bandit, {itemType}, 1)
        if task then
            table.insert(tasks, task)
        end
    end

    return tasks
end

BanditPrograms.Housekeeping.RemoveTrash = function(bandit)
    local tasks = {}

    local trashcan = BanditPlayerBase.GetTrashcan(bandit)
    if not trashcan then return tasks end

    -- put trash in the trashcan
    local inventory = bandit:getInventory()
    local items = ArrayList.new()
    inventory:getAllEvalRecurse(BanditPrograms.Housekeeping.PredicateTrash, items)
    if items:size() >= 7 then
        local item = items:get(0)
        local itemType = item:getFullType()
        local square = trashcan:getSquare()
        local asquare = AdjacentFreeTileFinder.Find(square, bandit)
        if asquare then
            local dist = BanditUtils.DistTo(bandit:getX(), bandit:getY(), asquare:getX() + 0.5, asquare:getY() + 0.5)
            if dist > 0.90 then
                -- bandit:addLineChatElement(("go to throw away trash"), 1, 1, 1)
                table.insert(tasks, BanditUtils.GetMoveTask(0, asquare:getX(), asquare:getY(), asquare:getZ(), "Walk", dist, false))
                return tasks
            else
                for i=0, items:size()-1 do
                    -- bandit:addLineChatElement(("throw away trash"), 1, 1, 1)
                    local item = items:get(i)
                    local itemType = item:getFullType()
                    local task = {action="PutInContainer", anim="Loot", itemType=itemType, x=square:getX(), y=square:getY(), z=square:getZ()}
                    table.insert(tasks, task)
                end
                return tasks
            end
        end
    end

    -- collect trash
    local task = getItem(bandit, BanditPrograms.Housekeeping.trash, 1)
    if task then
        table.insert(tasks, task)
    end

    return tasks
end

BanditPrograms.Housekeeping.FillGraves = function(bandit)
    local tasks = {}

    local grave = BanditPlayerBase.GetGrave(bandit, true)
    if not grave then return tasks end

    -- fill grave
    local itemType = "Base.Shovel"
    local inventory = bandit:getInventory()
    if inventory:getItemCountFromTypeRecurse(itemType) > 0 then
        local dist = BanditUtils.DistTo(bandit:getX(), bandit:getY(), grave:getX() + 0.5, grave:getY() + 0.5)
        if dist > 0.90 then
            table.insert(tasks, BanditUtils.GetMoveTask(0, grave:getX(), grave:getY(), grave:getZ(), "Walk", dist, false))
            return tasks
        else
            local task1 = {action="Equip", itemPrimary=itemType}
            table.insert(tasks, task1)

            local task = {action="FillGrave", anim="DigShovel", sound="Shoveling", itemType=itemType, time=400, x=grave:getX(), y=grave:getY(), z=grave:getZ()}
            table.insert(tasks, task)

            local task3 = {action="Equip", itemPrimary=Bandit.GetBestWeapon(bandit)}
            table.insert(tasks, task3)

            return tasks
        end
    end

    -- go take shovel
    local itemType = "Base.Shovel"
    local task = getItem(bandit, {itemType}, 1)
    if task then
        table.insert(tasks, task)
    end

    return tasks
end

BanditPrograms.Housekeeping.RemoveCorpses = function(bandit)
    local tasks = {}

    local grave = BanditPlayerBase.GetGrave(bandit, false)
    if not grave then return tasks end

    -- return with deadbody
    local itemType = "Base.CorpseMale"
    local inventory = bandit:getInventory()
    if inventory:getItemCountFromTypeRecurse(itemType) > 0 then
        local dist = BanditUtils.DistTo(bandit:getX(), bandit:getY(), grave:getX() + 0.5, grave:getY() + 0.5)
        if dist > 0.90 then
            table.insert(tasks, BanditUtils.GetMoveTask(0, grave:getX(), grave:getY(), grave:getZ(), "Walk", dist, false))
            return tasks
        else
            local task = {action="BuryCorpse", anim="LootLow", sound="BodyHitGround", x=grave:getX(), y=grave:getY(), z=grave:getZ()}
            table.insert(tasks, task)
            return tasks
        end
    end
    
    -- go take deadbody
    local deadbody = BanditPlayerBase.GetDeadbody(bandit)
    if not deadbody then return tasks end

    local square = obj
    local dist = BanditUtils.DistTo(bandit:getX(), bandit:getY(), deadbody:getX() + 0.5, deadbody:getY() + 0.5)
    if dist > 0.90 then
        table.insert(tasks, BanditUtils.GetMoveTask(0, deadbody:getX(), deadbody:getY(), deadbody:getZ(), "Walk", dist, false))
        return tasks
    else
        local task = {action="PickUpBody", anim="LootLow", itemType=itemType, x=deadbody:getX(), y=deadbody:getY(), z=deadbody:getZ()}
        table.insert(tasks, task)
        return tasks
    end

    return tasks
end

BanditPrograms.Misc = BanditPrograms.Misc or {}

BanditPrograms.Misc.ReturnFood = function(bandit)
    local tasks = {}

    local container = BanditPlayerBase.GetContainerOfType(bandit, "freezer")

    if not container then
        container = BanditPlayerBase.GetContainerOfType(bandit, "fridge")
    end
    if not container then return tasks end
    local inventory = bandit:getInventory()

    local itemType
    local items = ArrayList.new()
    inventory:getAllEvalRecurse(predicateSpoilableFood, items)
    if items:size() == 0 then return tasks end

    local square = container:getParent():getSquare()
    local asquare = AdjacentFreeTileFinder.Find(square, bandit)
    if asquare then
        local dist = BanditUtils.DistTo(bandit:getX(), bandit:getY(), asquare:getX() + 0.5, asquare:getY() + 0.5)
        if dist > 0.90 then
            -- bandit:addLineChatElement(("go put food to fridge"), 1, 1, 1)
            table.insert(tasks, BanditUtils.GetMoveTask(0, asquare:getX(), asquare:getY(), asquare:getZ(), "Walk", dist, false))
            return tasks
        else
            for i=0, items:size()-1 do
                -- bandit:addLineChatElement(("put food to fridge"), 1, 1, 1)
                local item = items:get(i)
                local itemType = item:getFullType()
                local task = {action="PutInContainer", anim="Loot", itemType=itemType, x=square:getX(), y=square:getY(), z=square:getZ()}
                table.insert(tasks, task)
            end
            return tasks
        end
    end

    return tasks
end

BanditPrograms.Self = BanditPrograms.Self or {}

BanditPrograms.Self.Wash = function(bandit)
    local tasks = {}

    local visual = bandit:getHumanVisual()
    local bodyBlood = 0
    local bodyDirt = 0
    for i=1, BloodBodyPartType.MAX:index() do
        local part = BloodBodyPartType.FromIndex(i-1)
        bodyBlood = bodyBlood + visual:getBlood(part)
        bodyDirt = bodyDirt + visual:getDirt(part)
    end
    --[[
    if bodyBlood > 0 then
        print ("blood: " .. bodyBlood)
    end
    if bodyDirt > 0 then
        print ("dirt: " .. bodyDirt)
    end]]

    if bodyBlood + bodyDirt < 10 then return tasks end

    local itemType = "Base.Soap2"
    local inventory = bandit:getInventory()
    if inventory:getItemCountFromTypeRecurse(itemType) > 0 then
        local source = BanditPlayerBase.GetWaterSource(bandit)
        if source then
            local square = source:getSquare()
            local asquare = AdjacentFreeTileFinder.Find(square, bandit)
            if asquare then
                local dist = BanditUtils.DistTo(bandit:getX(), bandit:getY(), asquare:getX() + 0.5, asquare:getY() + 0.5)
                if dist > 0.90 then
                    table.insert(tasks, BanditUtils.GetMoveTask(0, asquare:getX(), asquare:getY(), asquare:getZ(), "Walk", dist, false))
                    return tasks
                else
                    local task = {action="Wash", anim="washFace", x=square:getX(), y=square:getY(), z=square:getZ(), time=400}
                    table.insert(tasks, task)

                    return tasks
                end
            end
        end
    else

        -- go get soap
        local task = getItem(bandit, {itemType}, 1)
        if task then
            table.insert(tasks, task)
        end
    end

    return tasks
end