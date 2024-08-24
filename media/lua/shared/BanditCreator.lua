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

function BanditCreator.Make(wave)
    local clan = BanditCreator.GroupMap[wave.clanId]

    local bandit = {}
    
    -- properties to be rewritten from clan file to bandit instance
    bandit.clan = clan.id
    bandit.health = clan.health
    bandit.femaleChance = clan.femaleChance
    bandit.eatBody = clan.eatBody

    -- gun weapon choice comes from clan file, weapon probability from wave data
    bandit.weapons = BanditCreator.MakeWeapons(wave, clan)

    -- melee weapon choice comes from clan file
    bandit.weapons.melee = BanditUtils.Choice(clan.Melee)

    -- outfit choice comes from clan file
    bandit.outfit = BanditUtils.Choice(clan.Outfits)

    -- loot choice comes from clan file
    bandit.loot = {}
    for k, v in pairs(clan.Loot) do
        local r = ZombRand(101)
        if r <= v.chance then
            table.insert(bandit.loot, v.name)
        end
    end
    
    -- clan-independent, individual random loot below
    -- smoker
    if not getActivatedMods():contains("Smoker") then
        if ZombRand(4) == 1 then
            for i=1, 19 do
                table.insert(bandit.loot, "Base.Cigarettes")
            end
            table.insert(bandit.loot, "Base.Lighter")
        end
    end

    return bandit
end

-- assignment to wave system, clan files append this table
BanditCreator.GroupMap = BanditCreator.GroupMap or {}



