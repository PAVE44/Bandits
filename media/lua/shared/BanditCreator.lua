BanditCreator = BanditCreator or {}

function BanditCreator.MakeWeaponsGeneric(config)

    if not config then
        config = {}
        config.hasRifleChance = 0
        config.hasPistolChance = 0
    end
    
    local weapons = {}
    weapons.melee = BanditUtils.Choice(BanditWeapons.MeleeStrong)

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
    bandit.arrivalSound = "SMALL"
    return bandit
end

-- if you want to add a new bandit group type, add a creation function and register it in a table below

function BanditCreator.MakeDesperateCitizen(config)
    local weapons = BanditCreator.MakeWeaponsGeneric(config)
    local loot = BanditCreator.MakeLootGeneric()
    local bandit = BanditCreator.MakeBanditGeneric()
    bandit.weapons = weapons
    bandit.loot = loot

    -- overwrite defaults with details specific to this group below
    bandit.outfit = BanditUtils.Choice({"Bathrobe", "Generic02", "Generic01", "Punk"})
    bandit.femaleChance = 25
    bandit.weapons.melee = BanditUtils.Choice(BanditWeapons.MeleeWeak)
    bandit.loot = {}

    return bandit
end

function BanditCreator.MakeCarpenterClan(config)
    local weapons = BanditCreator.MakeWeaponsGeneric(config)
    local loot = BanditCreator.MakeLootGeneric()
    local bandit = BanditCreator.MakeBanditGeneric()
    bandit.weapons = weapons
    bandit.loot = loot
    bandit.clan = 1

    -- overwrite defaults with details specific to this group below
    bandit.outfit = BanditUtils.Choice({"Woodcut"})
    bandit.femaleChance = 0
    bandit.weapons.melee = BanditUtils.Choice({"Base.WoodAxe", "Base.HammerStone", "Base.WoodenLance", "Base.PlankNail"})

    return bandit
end

function BanditCreator.MakeAngryFarmers(config)
    local weapons = BanditCreator.MakeWeaponsGeneric(config)
    local loot = BanditCreator.MakeLootGeneric()
    local bandit = BanditCreator.MakeBanditGeneric()
    bandit.weapons = weapons
    bandit.loot = loot
    bandit.clan = 2
     
    -- overwrite defaults with details specific to this group below
    bandit.outfit = BanditUtils.Choice({"Farmer"})
    bandit.femaleChance = 10
    bandit.weapons.melee = BanditUtils.Choice({"Base.GardenFork"})

    return bandit
end

function BanditCreator.MakeMadDoctors(config)
    local weapons = BanditCreator.MakeWeaponsGeneric(config)
    local loot = BanditCreator.MakeLootGeneric()
    local bandit = BanditCreator.MakeBanditGeneric()
    bandit.weapons = weapons
    bandit.loot = loot
    bandit.clan = 2
     
    -- overwrite defaults with details specific to this group below
    bandit.outfit = BanditUtils.Choice({"Doctor"})
    bandit.femaleChance = 40
    bandit.weapons.melee = BanditUtils.Choice({"Base.Scalpel"})

    return bandit
end


function BanditCreator.MakeYakuza(config)
    local weapons = BanditCreator.MakeWeaponsGeneric(config)
    local loot = BanditCreator.MakeLootGeneric()
    local bandit = BanditCreator.MakeBanditGeneric()
    bandit.weapons = weapons
    bandit.loot = loot
    bandit.clan = 3
    
    -- overwrite defaults with details specific to this group below
    bandit.outfit = BanditUtils.Choice({"Classy", "Groom"})
    bandit.femaleChance = 0
    bandit.weapons.melee = BanditUtils.Choice({"Base.Katana"})

    return bandit
end

function BanditCreator.MakeInmates(config)
    local weapons = BanditCreator.MakeWeaponsGeneric(config)
    local loot = BanditCreator.MakeLootGeneric()
    local bandit = BanditCreator.MakeBanditGeneric()
    bandit.weapons = weapons
    bandit.loot = loot
    bandit.clan = 4
     
    -- overwrite defaults with details specific to this group below
    bandit.outfit = BanditUtils.Choice({"Inmate", "InmateEscaped"})
    bandit.femaleChance = 0
    bandit.weapons.melee = BanditUtils.Choice(BanditWeapons.MeleeStrong)

    return bandit
end

function BanditCreator.MakeSecurityGuards(config)
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

function BanditCreator.MakePolice(config)
    local weapons = BanditCreator.MakeWeaponsGeneric(config)
    local loot = BanditCreator.MakeLootGeneric()
    local bandit = BanditCreator.MakeBanditGeneric()
    bandit.weapons = weapons
    bandit.loot = loot
    bandit.clan = 5
   
    -- overwrite defaults with details specific to this group below
    bandit.outfit = BanditUtils.Choice({"Police"})
    bandit.femaleChance = 20
    bandit.weapons.melee = BanditUtils.Choice({"Base.Nightstick"})

    return bandit
end

function BanditCreator.MakeStatePolice(config)
    local weapons = BanditCreator.MakeWeaponsGeneric(config)
    local loot = BanditCreator.MakeLootGeneric()
    local bandit = BanditCreator.MakeBanditGeneric()
    bandit.weapons = weapons
    bandit.loot = loot
    bandit.clan = 5
  
    -- overwrite defaults with details specific to this group below
    bandit.outfit = BanditUtils.Choice({"PoliceState"})
    bandit.femaleChance = 10
    bandit.weapons.melee = BanditUtils.Choice({"Base.Nightstick"})

    return bandit
end

function BanditCreator.MakeRiotPolice(config)
    local weapons = BanditCreator.MakeWeaponsGeneric(config)
    local loot = BanditCreator.MakeLootGeneric()
    local bandit = BanditCreator.MakeBanditGeneric()
    bandit.health = 3
    bandit.weapons = weapons
    bandit.loot = loot
    bandit.arrivalSound = "MEDIUM"
    bandit.clan = 5
   
    -- overwrite defaults with details specific to this group below
    bandit.outfit = BanditUtils.Choice({"PoliceRiot"})
    bandit.femaleChance = 0
    bandit.weapons.melee = BanditUtils.Choice({"Base.Nightstick"})

    return bandit
end

function BanditCreator.MakeRangers(config)
    local weapons = BanditCreator.MakeWeaponsGeneric(config)
    local loot = BanditCreator.MakeLootGeneric()
    local bandit = BanditCreator.MakeBanditGeneric()
    bandit.weapons = weapons
    bandit.loot = loot
    bandit.clan = 5
  
    -- overwrite defaults with details specific to this group below
    bandit.outfit = BanditUtils.Choice({"Ranger"})
    bandit.femaleChance = 20
    bandit.weapons.melee = BanditUtils.Choice({"Base.Nightstick"})

    return bandit
end

function BanditCreator.MakeBandits(config)
    local weapons = BanditCreator.MakeWeaponsGeneric(config)
    local loot = BanditCreator.MakeLootGeneric()
    local bandit = BanditCreator.MakeBanditGeneric()
    bandit.weapons = weapons
    bandit.loot = loot
    bandit.arrivalSound = "MEDIUM"
    bandit.clan = 6
  
    -- overwrite defaults with details specific to this group below
    bandit.outfit = BanditUtils.Choice({"Bandit"})
    bandit.femaleChance = 20
    bandit.weapons.melee = BanditUtils.Choice(BanditWeapons.MeleeStrong)

    return bandit
end

function BanditCreator.MakePrivateMilitia(config)
    local weapons = BanditCreator.MakeWeaponsGeneric(config)
    local loot = BanditCreator.MakeLootGeneric()
    local bandit = BanditCreator.MakeBanditGeneric()
    bandit.weapons = weapons
    bandit.loot = loot
    bandit.arrivalSound = "BIG"
    bandit.clan = 7
  
    -- overwrite defaults with details specific to this group below
    bandit.outfit = BanditUtils.Choice({"PrivateMilitia"})
    bandit.femaleChance = 10
    bandit.weapons.melee = BanditUtils.Choice(BanditWeapons.MeleeStrong)

    return bandit
end

function BanditCreator.MakeVeterans(config)
    local weapons = BanditCreator.MakeWeaponsGeneric(config)
    local loot = BanditCreator.MakeLootGeneric()
    local bandit = BanditCreator.MakeBanditGeneric()
    bandit.health = 4
    bandit.weapons = weapons
    bandit.loot = loot
    bandit.clan = 0
  
    -- overwrite defaults with details specific to this group below
    bandit.outfit = BanditUtils.Choice({"Veteran"})
    bandit.femaleChance = 0
    bandit.weapons.melee = BanditUtils.Choice({"Base.HuntingKnife"})

    return bandit
end

function BanditCreator.MakeArmy(config)
    local weapons = BanditCreator.MakeWeaponsGeneric(config)
    local loot = BanditCreator.MakeLootGeneric()
    local bandit = BanditCreator.MakeBanditGeneric()
    bandit.health = 3
    bandit.weapons = weapons
    bandit.loot = loot
    bandit.arrivalSound = "CHOPPER"
    bandit.clan = 5
  
    -- overwrite defaults with details specific to this group below
    bandit.outfit = BanditUtils.Choice({"ArmyCamoGreen", "ArmyCamoDesert"})
    bandit.femaleChance = 5
    bandit.weapons.melee = BanditUtils.Choice({"Base.HuntingKnife"})

    return bandit
end

function BanditCreator.MakeHazardSuit(config)
    local weapons = BanditCreator.MakeWeaponsGeneric(config)
    local loot = BanditCreator.MakeLootGeneric()
    local bandit = BanditCreator.MakeBanditGeneric()
    bandit.weapons = weapons
    bandit.loot = loot
    bandit.clan = 5
  
    -- overwrite defaults with details specific to this group below
    bandit.outfit = BanditUtils.Choice({"HazardSuit"})
    bandit.femaleChance = 0
    bandit.weapons.melee = BanditUtils.Choice({"Base.LeadPipe"})

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
    bandit.weapons.melee = BanditUtils.Choice(BanditWeapons.MeleeStrong)

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





BanditCreator.GroupMap = BanditCreator.GroupMap or {}

BanditCreator.GroupMap[1] = BanditCreator.MakeDesperateCitizen
BanditCreator.GroupMap[2] = BanditCreator.MakeCarpenterClan
BanditCreator.GroupMap[3] = BanditCreator.MakeAngryFarmers
BanditCreator.GroupMap[4] = BanditCreator.MakeMadDoctors
BanditCreator.GroupMap[5] = BanditCreator.MakeYakuza
BanditCreator.GroupMap[6] = BanditCreator.MakeInmates
BanditCreator.GroupMap[7] = BanditCreator.MakeSecurityGuards
BanditCreator.GroupMap[8] = BanditCreator.MakePolice
BanditCreator.GroupMap[9] = BanditCreator.MakeStatePolice
BanditCreator.GroupMap[10] = BanditCreator.MakeRiotPolice
BanditCreator.GroupMap[11] = BanditCreator.MakeRangers
BanditCreator.GroupMap[12] = BanditCreator.MakeBandits
BanditCreator.GroupMap[13] = BanditCreator.MakePrivateMilitia
BanditCreator.GroupMap[14] = BanditCreator.MakeVeterans
BanditCreator.GroupMap[15] = BanditCreator.MakeArmy
BanditCreator.GroupMap[16] = BanditCreator.MakeHazardSuit
BanditCreator.GroupMap[17] = BanditCreator.MakeSurvivalist

--
-- BanditCreator.GroupMap[18] = BanditCreator.MakeForeman
-- BanditCreator.GroupMap[19] = BanditCreator.MakeSpiffo
-- BanditCreator.GroupMap[20] = BanditCreator.MakePriest
--BanditCreator.GroupMap[21] = BanditCreator.MakeHockey


