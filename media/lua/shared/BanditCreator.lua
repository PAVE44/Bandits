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

function BanditCreator.MakeLoot(loot)
    local loot = {}

    -- add loot from loot table
    for k, v in pairs(loot) do
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
            table.insert(loot,"Base.HottieZ")
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

    -- loot choice comes from clan file
    bandit.loot = BanditCreator.MakeLoot(clan.Loot)

    return bandit
end

-- assignment to wave system, clan files append this table
BanditCreator.GroupMap = BanditCreator.GroupMap or {}



