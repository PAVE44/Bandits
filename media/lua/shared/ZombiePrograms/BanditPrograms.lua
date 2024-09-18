-- shared subprograms available as subs for other programs

local function predicateAll(item)
    -- item:getType()
	return true
end

BanditPrograms = BanditPrograms or {}

BanditPrograms.LootContainer = function(bandit, object, container)
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