BanditCreator = BanditCreator or {}

function BanditCreator.MakeWeapons(wave, clan)
    local weapons = {}

    -- fallback
    weapons.melee = "Base.Axe"

    -- set up primary weapon
    weapons.primary = {}
    weapons.primary.name = false
    weapons.primary.magSize = 0
    weapons.primary.bulletsLeft = 0
    weapons.primary.magCount = 0
    local rifleRandom = ZombRandFloat(0, 101)
    if rifleRandom < wave.hasRifleChance then
        weapons.primary = BanditUtils.Choice(clan.Primary)
        weapons.primary.magCount = wave.rifleMagCount
    end

    -- set up secondary weapon
    weapons.secondary = {}
    weapons.secondary.name = false
    weapons.secondary.magSize = 0
    weapons.secondary.bulletsLeft = 0
    weapons.secondary.magCount = 0
    local pistolRandom = ZombRandFloat(0, 101)
    if pistolRandom < wave.hasPistolChance then
        weapons.secondary = BanditUtils.Choice(clan.Secondary)
        weapons.secondary.magCount = wave.pistolMagCount
    end

    return weapons
end

function BanditCreator.MakeLoot(clanLoot)
    local loot = {}

    -- add loot from loot table
    for k, v in pairs(clanLoot) do
        local r = ZombRand(101)
        if r <= v.chance then
            table.insert(loot, v.name)
        end
    end

    -- add clan-independent, individual random personal character loot below
    
    -- smoker
    if not getActivatedMods():contains("Smoker") then
        if ZombRand(4) == 1 then
            for i=1, ZombRand(19) do
                table.insert(loot, "Base.Cigarettes")
            end
            table.insert(loot, "Base.Lighter")
        end
    end

    -- hotties collector
    if ZombRand(100) == 1 then
        for i=1, ZombRand(31) do
            table.insert(loot, "Base.HottieZ")
        end
    end

    -- perv
    if ZombRand(100) == 1 then
        for i=1, ZombRand(44) do
            local i = ZombRand(7)
            if i == 1 then
                table.insert(loot, "Base.Underpants_White")
            elseif i == 2 then
                table.insert(loot, "Base.Underpants_Black")
            elseif i == 3 then
                table.insert(loot, "Base.FrillyUnderpants_Black")
            elseif i == 4 then
                table.insert(loot, "Base.FrillyUnderpants_Pink")
            elseif i == 5 then
                table.insert(loot, "Base.FrillyUnderpants_Red")
            elseif i == 6 then
                table.insert(loot, "Base.Underpants_RedSpots")
            else
                table.insert(loot, "Base.Underpants_AnimalPrint")
            end
        end
    end

    -- ku chwale ojczyzny!
    if ZombRand(100) == 1 then
        for i=1, ZombRand(18) do
            table.insert(loot, "Base.Perogies")
        end
    end
    

    return loot
end

function BanditCreator.MakeFromWave(wave)
    local clan = BanditCreator.GroupMap[wave.clanId]

    local bandit = {}
    
    -- properties to be rewritten from clan file to bandit instance
    bandit.clan = clan.id
    bandit.health = clan.health
    bandit.femaleChance = clan.femaleChance
    bandit.eatBody = clan.eatBody
    bandit.accuracyBoost = clan.accuracyBoost

    -- gun weapon choice comes from clan file, weapon probability from wave data
    bandit.weapons = BanditCreator.MakeWeapons(wave, clan)

    -- melee weapon choice comes from clan file
    bandit.weapons.melee = BanditUtils.Choice(clan.Melee)

    -- outfit choice comes from clan file
    bandit.outfit = BanditUtils.Choice(clan.Outfits)

    -- hairstyle 
    if clan.hairStyles then
        bandit.hairStyle = BanditUtils.Choice(clan.hairStyles)
    end
    
    -- loot choice comes from clan file
    bandit.loot = BanditCreator.MakeLoot(clan.Loot)

    return bandit
end

function BanditCreator.MakeFromSpawnType(spawnData)
    local clan
    local config = {}

    -- clan detection based on building type
    if spawnData.buildingType == "medical" then
        clan = BanditClan.Scientist
        config.hasRifleChance = 0
        config.hasPistolChance = 50
        config.rifleMagCount = 0
        config.pistolMagCount = 3
    elseif spawnData.buildingType == "police" then
        clan = BanditClan.Police
        config.hasRifleChance = 20
        config.hasPistolChance = 50
        config.rifleMagCount = 2
        config.pistolMagCount = 4
    elseif spawnData.buildingType == "gunstore" then
        clan = BanditClan.DoomRider
        config.hasRifleChance = 100
        config.hasPistolChance = 100
        config.rifleMagCount = 6
        config.pistolMagCount = 4
    elseif spawnData.buildingType == "bank" then
        clan = BanditClan.Criminal
        config.hasRifleChance = 0
        config.hasPistolChance = 80
        config.rifleMagCount = 0
        config.pistolMagCount = 3
    elseif spawnData.buildingType == "church" then
        clan = BanditClan.Reclaimer
        config.hasRifleChance = 0
        config.hasPistolChance = 0
        config.rifleMagCount = 0
        config.pistolMagCount = 0
    else
        clan = BanditClan.DesperateCitizen
        config.hasRifleChance = 0
        config.hasPistolChance = 25
        config.rifleMagCount = 0
        config.pistolMagCount = 2
    end

    local bandit = {}

    -- properties to be rewritten from clan file to bandit instance
    bandit.clan = clan.id
    bandit.health = clan.health
    bandit.femaleChance = clan.femaleChance
    bandit.eatBody = clan.eatBody
    bandit.accuracyBoost = clan.accuracyBoost

    -- gun weapon choice comes from clan file, weapon probability from wave data
    bandit.weapons = BanditCreator.MakeWeapons(config, clan)

    -- melee weapon choice comes from clan file
    bandit.weapons.melee = BanditUtils.Choice(clan.Melee)

    -- outfit choice comes from clan file
    bandit.outfit = BanditUtils.Choice(clan.Outfits)

    -- hairstyle 
    if clan.hairStyles then
        bandit.hairStyle = BanditUtils.Choice(clan.hairStyles)
    end

    -- loot choice comes from clan file
    bandit.loot = BanditCreator.MakeLoot(clan.Loot)

    return bandit
end

function BanditCreator.MakeFromRoom(room)
    local bandit = {}
    
    -- this always generates bandits of clan 1 - citizens
    local clan = BanditCreator.GroupMap[1]

    -- properties to be rewritten from clan file to bandit instance
    bandit.clan = clan.id
    bandit.health = clan.health
    bandit.femaleChance = clan.femaleChance
    bandit.eatBody = clan.eatBody
    bandit.accuracyBoost = clan.accuracyBoost

    -- weapon config
    config = {}
    config.hasRifleChance = 0
    config.hasPistolChance = 4
    config.rifleMagCount = 0
    config.pistolMagCount = 1
    config.clanId = 1

    -- gun weapon choice comes from clan file, weapon probability from wave data
    bandit.weapons = BanditCreator.MakeWeapons(config, clan)

    -- melee weapon choice comes from clan file
    bandit.weapons.melee = BanditUtils.Choice(clan.Melee)

    -- outfit choice comes from clan file
    bandit.outfit = BanditUtils.Choice(clan.Outfits)

    -- hairstyle 
    if clan.hairStyles then
        bandit.hairStyle = BanditUtils.Choice(clan.hairStyles)
    end

    -- loot choice comes from clan file
    bandit.loot = BanditCreator.MakeLoot(clan.Loot)

    local building = room:getBuilding()
    if building:containsRoom("policestorage") then
        bandit.outfit = "Police"
        config.hasPistolChance = 100
        config.pistolMagCount = 3
        bandit.weapons = BanditCreator.MakeWeapons(config, clan)
        bandit.weapons.melee = "Base.Nightstick"

    elseif building:containsRoom("firestorage") then
        bandit.outfit = "Fireman"
        bandit.weapons.melee = "Base.Axe"
    elseif building:containsRoom("church") then
        if ZombRand(20) == 1 then
            bandit.outfit = "Priest"
            bandit.femaleChance = 0
        else
            bandit.outfit = "Classy"
        end
        bandit.weapons.melee = "Base.BareHands"
    elseif building:containsRoom("medclinic") or building:containsRoom("medical")  then
        bandit.outfit = BanditUtils.Choice({"Nurse", "Doctor", "HospitalPatient"})
        bandit.weapons.melee = "Base.Scalpel"
    elseif building:containsRoom("mechanic") then
        bandit.outfit = "Mechanic"
        bandit.femaleChance = 0
        bandit.weapons.melee = "Base.Wrench"
    else
        
        local roomDef = room:getRoomDef()
        if roomDef then
            local roomName = room:getName()
            if roomName == "bathroomx" then
                bandit.outfit = BanditUtils.Choice({"Bathrobe", "Naked", "Jewelry"})
                bandit.weapons.melee = "Base.BareHands"

            elseif roomName == "bedroom" or roomName == "motelroom" or roomName == "motelroomoccupied" then
                if ZombRand(9) == 1 then
                    bandit.outfit = BanditUtils.Choice({"StripperBlack", "StripperNaked", "StripperPink"})
                    bandit.femaleChance = 100
                else
                    bandit.outfit = "Bedroom"
                end
                bandit.weapons.melee = "Base.BareHands"

            elseif roomName == "kitchen" then
                bandit.outfit = "Waiter_PileOCrepe"
                bandit.weapons.melee = BanditUtils.Choice({"Base.BareHands", "Base.KitchenKnife", "Base.BreadKnife", "Base.ButterKnife", "Base.Pan", "Base.GridlePan", "Base.MeatCleaver"})
                
            elseif roomName == "office" then -- also a room in house
                if ZombRand(2) == 1 then
                    bandit.outfit = "OfficeWorker"
                    bandit.femaleChance = 0
                else
                    bandit.outfit = "OfficeWorkerSkirt"
                    bandit.femaleChance = 100
                end
                bandit.weapons.melee = "Base.BareHands"

            elseif roomName == "daycare" then --kindergarden
                bandit.outfit = "OfficeWorkerSkirt"
                bandit.femaleChance = 100
                bandit.weapons.melee = "Base.BareHands"

            elseif roomName == "gasstore" or roomName == "gasstorage" then 
                bandit.outfit = BanditUtils.Choice({"Gas2Go", "Generic01", "Generic02"})
                bandit.weapons.melee = "Base.BareHands"

            elseif roomName == "liquorstore" then 
                bandit.outfit = BanditUtils.Choice({"Redneck", "Generic01", "Generic02", "Punk"})
                bandit.weapons.melee = "Base.SmashedBottle"

            elseif roomName == "restaurant" or roomName == "cafe" then 
                bandit.outfit = BanditUtils.Choice({"Classy", "Young", "Waiter_Classy"})
                bandit.weapons.melee = "Base.BareHands"

            elseif roomName == "pizzawhirled" then
                bandit.outfit = BanditUtils.Choice({"Generic03", "Young", "Waiter_PizzaWhirled"})
                bandit.weapons.melee = "Base.BareHands"

            elseif roomName == "spiffo_dining" then
                if ZombRand(10) == 0 then
                    bandit.outfit = "Spiffo"
                else
                    bandit.outfit = BanditUtils.Choice({"Generic03", "Generic04", "Waiter_Spiffo"})
                end
                bandit.weapons.melee = "Base.BareHands"

            elseif roomName == "jayschicken_dining" then
                bandit.outfit = BanditUtils.Choice({"Young", "Generic04", "Waiter_Market"})
                bandit.weapons.melee = "Base.BareHands"

            elseif roomName == "dinerkitchen" or roomName == "restaurantkitchen" or roomName == "pizzakitchen" or roomName == "cafeteriakitchen" or roomName == "cafekitchen"  or roomName == "jayschicken_kitchen" or roomName == "kitchen_crepe" then
                bandit.outfit = BanditUtils.Choice({"Cook_Generic", "Chef"})
                bandit.weapons.melee = BanditUtils.Choice({"Base.BareHands", "Base.KitchenKnife", "Base.BreadKnife", "Base.ButterKnife", "Base.Pan", "Base.GridlePan", "Base.MeatCleaver"})

            elseif roomName == "spiffoskitchen" then
                bandit.outfit = BanditUtils.Choice({"Cook_Spiffos", "Chef"})
                bandit.weapons.melee = BanditUtils.Choice({"Base.BareHands", "Base.KitchenKnife", "Base.BreadKnife", "Base.ButterKnife", "Base.Pan", "Base.GridlePan", "Base.MeatCleaver"})

            elseif roomName == "pharmacy" then
                bandit.outfit = BanditUtils.Choice({"Generic02", "Generic03", "Generic04", "Pharmacist"})
                bandit.weapons.melee = "Base.BareHands"

            elseif roomName == "pharmacystorage" then
                bandit.outfit = BanditUtils.Choice({"Pharmacist"})
                bandit.weapons.melee = "Base.BareHands"

            elseif roomName == "clothingstore" or roomName == "clothesstore" then
                if ZombRand(4) == 1 then
                    bandit.outfit = "OfficeWorkerSkirt"
                    bandit.femaleChance = 100
                else
                    bandit.outfit = BanditUtils.Choice({"DressShort", "DressNormal", "DressLong"})
                    bandit.femaleChance = 100
                end
                bandit.weapons.melee = "Base.BareHands"

            elseif roomName == "grocery" or roomName == "gigamart" then
                local rn = ZombRand(9)
                if rn == 1 then
                    bandit.outfit = "OfficeWorkerSkirt"
                    bandit.femaleChance = 100
                elseif rn == 2 then
                    bandit.outfit = "MallSecurity"
                    bandit.femaleChance = 0
                    config.hasPistolChance = 50
                    config.pistolMagCount = 2
                    bandit.weapons = BanditCreator.MakeWeapons(config, clan)
                    bandit.weapons.melee = "Base.Nightstick"
                end
                bandit.weapons.melee = "Base.BareHands"

            elseif roomName == "zippeestore" then
                if ZombRand(20) == 1 then
                    bandit.outfit = "OfficeWorkerSkirt"
                    bandit.femaleChance = 100
                end
                bandit.weapons.melee = "Base.BareHands"

            elseif roomName == "movierental" then
                if ZombRand(4) == 1 then
                    bandit.outfit = "Thug"
                    bandit.femaleChance = 0
                end
                bandit.weapons.melee = "Base.BareHands"

            elseif roomName == "dressingrooms" then
                bandit.outfit = BanditUtils.Choice({"DressShort", "Naked"})
                bandit.femaleChance = 100
                bandit.weapons.melee = "Base.BareHands"

            elseif roomName == "bookstore" or roomName == "library" then
                bandit.outfit = BanditUtils.Choice({"Generic02", "Generic03", "Teacher"})
                bandit.weapons.melee = "Base.BareHands"

            elseif roomName == "aesthetic" then 
                bandit.outfit = BanditUtils.Choice({"Classy", "Young", "DressShort"})
                bandit.femaleChance = 100
                bandit.weapons.melee = "Base.BareHands"

            elseif roomName == "bar" then
                bandit.outfit = BanditUtils.Choice({"Thug", "Punk", "Biker", "Redneck"})
                bandit.weapons.melee = "Base.SmashedBottle"

            elseif roomName == "barkitchen" then
                bandit.outfit = BanditUtils.Choice({"Waiter_Classy", "Waiter_Stripper"})
                bandit.weapons.melee = "Base.SmashedBottle"
                -- obj: Bar
                -- obj: Antique (bartap)

            elseif roomName == "warehouse" then
                bandit.outfit = BanditUtils.Choice({"Foreman", "Metalworker"})
                bandit.femaleChance = 0
                bandit.weapons.melee = BanditUtils.Choice({"Base.BareHands", "Base.MetalPipe", "Base.MetalBar", "Base.Crowbar"})

            elseif roomName == "classroom" or roomName == "cafeteria" then
                if ZombRand(10) == 1 then
                    bandit.outfit = "Teacher"
                else
                    bandit.outfit = "Student"
                end
                bandit.weapons.melee =  BanditUtils.Choice({"Base.BareHands", "Base.Pencil"})

            elseif roomName == "gym" then
                bandit.outfit = "StreetSports"
                bandit.femaleChance = 50
                bandit.weapons.melee = BanditUtils.Choice({"Base.BarBell", "Base.Dumbbell"})

                
            elseif roomName == "bank" then
                if ZombRand(4) == 1 then
                    bandit.outfit = "Security"
                    bandit.femaleChance = 0
                    config.hasPistolChance = 100
                    config.pistolMagCount = 3
                    bandit.weapons = BanditCreator.MakeWeapons(config, clan)
                    bandit.weapons.melee = "Base.Nightstick"
                else
                    bandit.outfit = "Classy"
                    bandit.weapons.melee = "Base.BareHands"
                end
                

            elseif roomName == "security" then
                bandit.outfit = "Security"
                bandit.femaleChance = 0
                config.hasPistolChance = 100
                config.pistolMagCount = 3
                bandit.weapons = BanditCreator.MakeWeapons(config, clan)
                bandit.weapons.melee = "Base.Nightstick"

            elseif roomName == "gunstore" then
                bandit.outfit = "Veteran"
                bandit.femaleChance = 0
                config.hasPistolChance = 100
                config.pistolMagCount = 3
                bandit.weapons = BanditCreator.MakeWeapons(config, clan)

            elseif roomName == "gunstorestorage" then
                bandit.outfit = "Veteran"
                bandit.femaleChance = 0
                config.hasPistolChance = 100
                config.pistolMagCount = 3
                bandit.weapons = BanditCreator.MakeWeapons(config, clan)

            elseif roomName == "cell" then
                bandit.outfit = "Inmate"
                bandit.femaleChance = 0
                bandit.weapons.melee = "Base.BareHands"
            else
                return false
            end
        end
    end

    return bandit
end

-- assignment to wave system, clan files append this table
BanditCreator.GroupMap = BanditCreator.GroupMap or {}



