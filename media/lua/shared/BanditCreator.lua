BanditCreator = BanditCreator or {}

function BanditCreator.MakeWeaponsGeneric(config)

    if not config then
        config = {}
        config.hasRifleChance = 0
        config.hasPistolChance = 0
    end
    
    local weapons = {}
    weapons.melee = "Base.Axe"

    weapons.primary = {}
    weapons.primary.name = false
    weapons.primary.magSize = 0
    weapons.primary.bulletsLeft = 0
    weapons.primary.magCount = 0
    local rifleRandom = ZombRandFloat(0, 101)
    if rifleRandom < config.hasRifleChance then
        weapons.primary = BanditUtils.Choice(BanditWeapons.Primary)
        weapons.primary.magCount = config.rifleMagCount
    end

    weapons.secondary = {}
    weapons.secondary.name = false
    weapons.secondary.magSize = 0
    weapons.secondary.bulletsLeft = 0
    weapons.secondary.magCount = 0
    local pistolRandom = ZombRandFloat(0, 101)
    if pistolRandom < config.hasPistolChance then
        weapons.secondary = BanditUtils.Choice(BanditWeapons.Secondary)
        weapons.secondary.magCount = config.pistolMagCount
    end
    return weapons
end

function BanditCreator.MakeLootGeneric()
    local loot = {}
    for k, v in pairs(BanditLoot.Items) do
        local r = ZombRand(101)
        if r <= v.chance then
            table.insert(loot, v.name)
        end
    end
    return loot
end

function BanditCreator.MakeBanditGeneric()
    local bandit = {}
    bandit.outfit = "Generic01"
    bandit.health = 2
    bandit.clan = 0
    bandit.femaleChance = 50
    bandit.weapons = {}
    bandit.loot = {}
    return bandit
end

-- if you want to add a new bandit group type, add a creation function and register it in a table below

function BanditCreator.MakeDesperateCitizen(config)
    local weapons = BanditCreator.MakeWeaponsGeneric(config)
    local loot = BanditCreator.MakeLootGeneric()
    local bandit = BanditCreator.MakeBanditGeneric()
    bandit.health = 1
    bandit.weapons = weapons
    bandit.loot = loot
    bandit.clan = 1

    -- overwrite defaults with details specific to this group below
    --bandit.outfit = BanditUtils.Choice({"Bathrobe", "Generic02", "Generic01", "Punk"})
    bandit.outfit = BanditUtils.Choice(BanditOutfits.DesperateCitizen)
    bandit.femaleChance = 25
    bandit.weapons.melee = BanditUtils.Choice(BanditWeapons.Melee.DesperateCitizen)
    bandit.loot = {}

    return bandit
end

function BanditCreator.MakePsychopath(config)
    local weapons = BanditCreator.MakeWeaponsGeneric(config)
    local loot = BanditCreator.MakeLootGeneric()
    local bandit = BanditCreator.MakeBanditGeneric()
    bandit.health = 2
    bandit.weapons = weapons
    bandit.loot = loot
    bandit.clan = 2

    -- overwrite defaults with details specific to this group below
    bandit.outfit = BanditUtils.Choice(BanditOutfits.Psychopath)
    bandit.femaleChance = 0
    bandit.weapons.melee = BanditUtils.Choice(BanditWeapons.Melee.Psychopath)

    return bandit
end

function BanditCreator.MakeCannibal(config)
    local weapons = BanditCreator.MakeWeaponsGeneric(config)
    local loot = BanditCreator.MakeLootGeneric()
    local bandit = BanditCreator.MakeBanditGeneric()
    bandit.health = 2
    bandit.weapons = weapons
    bandit.loot = loot
    bandit.clan = 3
     
    -- overwrite defaults with details specific to this group below
    bandit.outfit = BanditUtils.Choice(BanditOutfits.Cannibal)
    bandit.femaleChance = 10
    bandit.weapons.melee = BanditUtils.Choice(BanditWeapons.Melee.Cannibal)

    return bandit
end

function BanditCreator.MakeCrimial(config)
    local weapons = BanditCreator.MakeWeaponsGeneric(config)
    local loot = BanditCreator.MakeLootGeneric()
    local bandit = BanditCreator.MakeBanditGeneric()
    bandit.health = 1
    bandit.weapons = weapons
    bandit.loot = loot
    bandit.clan = 4
     
    -- overwrite defaults with details specific to this group below
    bandit.outfit = BanditUtils.Choice(BanditOutfits.Crimial)
    bandit.femaleChance = 40
    bandit.weapons.melee = BanditUtils.Choice(BanditWeapons.Melee.Criminal)

    return bandit
end


function BanditCreator.MakeInmate(config)
    local weapons = BanditCreator.MakeWeaponsGeneric(config)
    local loot = BanditCreator.MakeLootGeneric()
    local bandit = BanditCreator.MakeBanditGeneric()
    bandit.health = 2
    bandit.weapons = weapons
    bandit.loot = loot
    bandit.clan = 5
    
    -- overwrite defaults with details specific to this group below
    bandit.outfit = BanditUtils.Choice(BanditOutfits.Inmate)
    bandit.femaleChance = 0
    bandit.weapons.melee = BanditUtils.Choice(BanditWeapons.Melee.Inmate)

    return bandit
end

function BanditCreator.MakePolice(config)
    local weapons = BanditCreator.MakeWeaponsGeneric(config)
    local loot = BanditCreator.MakeLootGeneric()
    local bandit = BanditCreator.MakeBanditGeneric()
    bandit.health = 3
    bandit.weapons = weapons
    bandit.loot = loot
    bandit.clan = 6
     
    -- overwrite defaults with details specific to this group below
    bandit.outfit = BanditUtils.Choice(BanditOutfits.Police)
    bandit.femaleChance = 0
    bandit.weapons.melee = BanditUtils.Choice(BanditWeapons.Melee.Police)

    return bandit
end

function BanditCreator.MakePrepper(config)
    local weapons = BanditCreator.MakeWeaponsGeneric(config)
    local loot = BanditCreator.MakeLootGeneric()
    local bandit = BanditCreator.MakeBanditGeneric()
    bandit.health = 2
    bandit.weapons = weapons
    bandit.loot = loot
    bandit.clan = 7
    
    -- overwrite defaults with details specific to this group below
    bandit.outfit = BanditUtils.Choice(BanditOutfits.Prepper)
    bandit.femaleChance = 0
    bandit.weapons.melee = BanditUtils.Choice(BanditWeapons.Melee.Prepper)

    return bandit
end

function BanditCreator.MakeVeteran(config)
    local weapons = BanditCreator.MakeWeaponsGeneric(config)
    local loot = BanditCreator.MakeLootGeneric()
    local bandit = BanditCreator.MakeBanditGeneric()
    bandit.health = 4
    bandit.weapons = weapons
    bandit.loot = loot
    bandit.clan = 8
   
    -- overwrite defaults with details specific to this group below
    bandit.outfit = BanditUtils.Choice(BanditOutfits.Veteran)
    bandit.femaleChance = 20
    bandit.weapons.melee = BanditUtils.Choice(BanditWeapons.Melee.Veteran)

    return bandit
end

function BanditCreator.MakeBiker(config)
    local weapons = BanditCreator.MakeWeaponsGeneric(config)
    local loot = BanditCreator.MakeLootGeneric()
    local bandit = BanditCreator.MakeBanditGeneric()
    bandit.health = 2
    bandit.weapons = weapons
    bandit.loot = loot
    bandit.clan = 9
  
    -- overwrite defaults with details specific to this group below
    bandit.outfit = BanditUtils.Choice(BanditOutfits.Biker)
    bandit.femaleChance = 10
    bandit.weapons.melee = BanditUtils.Choice(BanditWeapons.Melee.Biker)

    return bandit
end

function BanditCreator.MakeHunter(config)
    local weapons = BanditCreator.MakeWeaponsGeneric(config)
    local loot = BanditCreator.MakeLootGeneric()
    local bandit = BanditCreator.MakeBanditGeneric()
    bandit.health = 2
    bandit.weapons = weapons
    bandit.loot = loot
    bandit.clan = 10
   
    -- overwrite defaults with details specific to this group below
    bandit.outfit = BanditUtils.Choice(BanditOutfits.Hunter)
    bandit.femaleChance = 0
    bandit.weapons.melee = BanditUtils.Choice(BanditWeapons.Melee.Hunter)

    return bandit
end

function BanditCreator.MakeReclaimer(config)
    local weapons = BanditCreator.MakeWeaponsGeneric(config)
    local loot = BanditCreator.MakeLootGeneric()
    local bandit = BanditCreator.MakeBanditGeneric()
    bandit.health = 9
    bandit.weapons = weapons
    bandit.loot = loot
    bandit.clan = 11
  
    -- overwrite defaults with details specific to this group below
    bandit.outfit = BanditUtils.Choice(BanditOutfits.Reclaimer)
    bandit.femaleChance = 20
    bandit.weapons.melee = BanditUtils.Choice(BanditWeapons.Melee.Reclaimer)

    return bandit
end

function BanditCreator.MakeScientist(config)
    local weapons = BanditCreator.MakeWeaponsGeneric(config)
    local loot = BanditCreator.MakeLootGeneric()
    local bandit = BanditCreator.MakeBanditGeneric()
    bandit.health = 2
    bandit.weapons = weapons
    bandit.loot = loot
    bandit.clan = 12
  
    -- overwrite defaults with details specific to this group below
    bandit.outfit = BanditUtils.Choice(BanditOutfits.Scientist)
    bandit.femaleChance = 20
    bandit.weapons.melee = BanditUtils.Choice(BanditWeapons.Melee.Scientist)

    return bandit
end

function BanditCreator.MakeDoomRider(config)
    local weapons = BanditCreator.MakeWeaponsGeneric(config)
    local loot = BanditCreator.MakeLootGeneric()
    local bandit = BanditCreator.MakeBanditGeneric()
    bandit.health = 2
    bandit.weapons = weapons
    bandit.loot = loot
    bandit.clan = 13
  
    -- overwrite defaults with details specific to this group below
    bandit.outfit = BanditUtils.Choice(BanditOutfits.DoomRider)
    bandit.femaleChance = 10
    bandit.weapons.melee = BanditUtils.Choice(BanditWeapons.Melee.DoomRider)

    return bandit
end

function BanditCreator.MakePrivateMilitia(config)
    local weapons = BanditCreator.MakeWeaponsGeneric(config)
    local loot = BanditCreator.MakeLootGeneric()
    local bandit = BanditCreator.MakeBanditGeneric()
    bandit.health = 3
    bandit.weapons = weapons
    bandit.loot = loot
    bandit.clan = 0
  
    -- overwrite defaults with details specific to this group below
    bandit.outfit = BanditUtils.Choice(BanditOutfits.PrivateMilitia)
    bandit.femaleChance = 0
    bandit.weapons.melee = BanditUtils.Choice(BanditWeapons.Melee.PrivateMilitia)

    return bandit
end

function BanditCreator.MakeDeathLegion(config)
    local weapons = BanditCreator.MakeWeaponsGeneric(config)
    local loot = BanditCreator.MakeLootGeneric()
    local bandit = BanditCreator.MakeBanditGeneric()
    bandit.health = 4
    bandit.weapons = weapons
    bandit.loot = loot
    bandit.clan = 15
  
    -- overwrite defaults with details specific to this group below
    bandit.outfit = BanditUtils.Choice(BanditOutfits.DeathLegion)
    bandit.femaleChance = 5
    bandit.weapons.melee = BanditUtils.Choice(BanditWeapons.Melee.DeathLegion)

    return bandit
end

function BanditCreator.MakeNewOrder(config)
    local weapons = BanditCreator.MakeWeaponsGeneric(config)
    local loot = BanditCreator.MakeLootGeneric()
    local bandit = BanditCreator.MakeBanditGeneric()
    bandit.health = 3
    bandit.weapons = weapons
    bandit.loot = loot
    bandit.clan = 16
  
    -- overwrite defaults with details specific to this group below
    bandit.outfit = BanditUtils.Choice(BanditOutfits.NewOrder)
    bandit.femaleChance = 0
    bandit.weapons.melee = BanditUtils.Choice(BanditWeapons.Melee.NewOrder)

    return bandit
end

-- end of wave bandits

-- defender bandits below

function BanditCreator.MakeMadDoctor(config)
    local weapons = BanditCreator.MakeWeaponsGeneric(config)
    local loot = BanditCreator.MakeLootGeneric()
    local bandit = BanditCreator.MakeBanditGeneric()
    bandit.weapons = weapons
    bandit.loot = loot
    bandit.clan = 2
     
    -- overwrite defaults with details specific to this group below
    bandit.outfit = BanditUtils.Choice({"Doctor", "Nurse"})
    bandit.femaleChance = 40
    bandit.weapons.melee = BanditUtils.Choice({"Base.Scalpel"})

    return bandit
end

function BanditCreator.MakeSecurityGuard(config)
    local weapons = BanditCreator.MakeWeaponsGeneric(config)
    local loot = BanditCreator.MakeLootGeneric()
    local bandit = BanditCreator.MakeBanditGeneric()
    bandit.weapons = weapons
    bandit.loot = loot
    bandit.clan = 5
    
    -- overwrite defaults with details specific to this group below
    bandit.outfit = BanditUtils.Choice({"MallSecurity"})
    bandit.femaleChance = 0
    bandit.weapons.melee = BanditUtils.Choice({"Base.Nightstick"})

    return bandit
end

function BanditCreator.MakeSurvivalist(config)
    local weapons = BanditCreator.MakeWeaponsGeneric(config)
    local loot = BanditCreator.MakeLootGeneric()
    local bandit = BanditCreator.MakeBanditGeneric()
    bandit.weapons = weapons
    bandit.loot = loot
    bandit.clan = 0
  
    -- overwrite defaults with details specific to this group below
    bandit.outfit = BanditUtils.Choice({"Survivalist"})
    bandit.femaleChance = 40
    bandit.weapons.melee = BanditUtils.Choice({"Base.BaseballBat"})

    return bandit
end

function BanditCreator.MakeForeman(config)
    local weapons = BanditCreator.MakeWeaponsGeneric(config)
    local loot = BanditCreator.MakeLootGeneric()
    local bandit = BanditCreator.MakeBanditGeneric()
    bandit.weapons = weapons
    bandit.loot = loot
    bandit.clan = 0
  
    -- overwrite defaults with details specific to this group below
    bandit.outfit = BanditUtils.Choice({"Foreman"})
    bandit.femaleChance = 0
    bandit.weapons.melee = BanditUtils.Choice({"Base.ClubHammer"})

    return bandit
end

function BanditCreator.MakeSpiffo(config)
    local weapons = BanditCreator.MakeWeaponsGeneric(config)
    local loot = BanditCreator.MakeLootGeneric()
    local bandit = BanditCreator.MakeBanditGeneric()
    bandit.weapons = weapons
    bandit.health = 3
    bandit.loot = loot
    bandit.clan = 0
  
    -- overwrite defaults with details specific to this group below
    bandit.outfit = BanditUtils.Choice({"Spiffo"})
    bandit.femaleChance = 0
    bandit.weapons.melee = BanditUtils.Choice({"Base.Plunger"})

    return bandit
end

function BanditCreator.MakePriest(config)
    local weapons = BanditCreator.MakeWeaponsGeneric(config)
    local loot = BanditCreator.MakeLootGeneric()
    local bandit = BanditCreator.MakeBanditGeneric()
    bandit.weapons = weapons
    bandit.loot = loot
    bandit.clan = 0
  
    -- overwrite defaults with details specific to this group below
    bandit.outfit = BanditUtils.Choice({"Priest"})
    bandit.femaleChance = 0
    bandit.weapons.melee = BanditUtils.Choice({"Base.Stake"})

    return bandit
end

function BanditCreator.MakeHockey(config)
    local weapons = BanditCreator.MakeWeaponsGeneric(config)
    local loot = BanditCreator.MakeLootGeneric()
    local bandit = BanditCreator.MakeBanditGeneric()
    bandit.health = 12
    bandit.weapons = weapons
    bandit.loot = loot
    bandit.clan = 8
  
    -- overwrite defaults with details specific to this group below
    bandit.outfit = BanditUtils.Choice({"HockeyPsycho"})
    bandit.femaleChance = 0
    bandit.weapons.melee = BanditUtils.Choice({"Base.Machete"})

    return bandit
end

function BanditCreator.MakeBaseballKY(config)
    local weapons = BanditCreator.MakeWeaponsGeneric(config)
    local loot = BanditCreator.MakeLootGeneric()
    local bandit = BanditCreator.MakeBanditGeneric()
    bandit.health = 12
    bandit.weapons = weapons
    bandit.loot = loot
    bandit.clan = 98
  
    -- overwrite defaults with details specific to this group below
    bandit.outfit = BanditUtils.Choice({"BaseballPlayer_KY"})
    bandit.femaleChance = 0
    bandit.weapons.melee = BanditUtils.Choice({"Base.BaseballBat"})

    return bandit
end

function BanditCreator.MakeBaseballZ(config)
    local weapons = BanditCreator.MakeWeaponsGeneric(config)
    local loot = BanditCreator.MakeLootGeneric()
    local bandit = BanditCreator.MakeBanditGeneric()
    bandit.health = 12
    bandit.weapons = weapons
    bandit.loot = loot
    bandit.clan = 99
  
    -- overwrite defaults with details specific to this group below
    bandit.outfit = BanditUtils.Choice({"BaseballPlayer_Z"})
    bandit.femaleChance = 0
    bandit.weapons.melee = BanditUtils.Choice({"Base.BaseballBat"})

    return bandit
end




BanditCreator.GroupMap = BanditCreator.GroupMap or {}

BanditCreator.GroupMap[1] = BanditCreator.MakeDesperateCitizen
BanditCreator.GroupMap[2] = BanditCreator.MakePsychopath
BanditCreator.GroupMap[3] = BanditCreator.MakeCannibal
BanditCreator.GroupMap[4] = BanditCreator.MakeCrimial
BanditCreator.GroupMap[5] = BanditCreator.MakeInmate
BanditCreator.GroupMap[6] = BanditCreator.MakePolice
BanditCreator.GroupMap[7] = BanditCreator.MakePrepper
BanditCreator.GroupMap[8] = BanditCreator.MakeVeteran
BanditCreator.GroupMap[9] = BanditCreator.MakeBiker
BanditCreator.GroupMap[10] = BanditCreator.MakeHunter
BanditCreator.GroupMap[11] = BanditCreator.MakeReclaimer
BanditCreator.GroupMap[12] = BanditCreator.MakeScientist
BanditCreator.GroupMap[13] = BanditCreator.MakeDoomRider
BanditCreator.GroupMap[14] = BanditCreator.MakePrivateMilitia
BanditCreator.GroupMap[15] = BanditCreator.MakeDeathLegion
BanditCreator.GroupMap[16] = BanditCreator.MakeNewOrder


--
-- BanditCreator.GroupMap[18] = BanditCreator.MakeForeman
-- BanditCreator.GroupMap[19] = BanditCreator.MakeSpiffo
-- BanditCreator.GroupMap[20] = BanditCreator.MakePriest
--BanditCreator.GroupMap[21] = BanditCreator.MakeHockey


