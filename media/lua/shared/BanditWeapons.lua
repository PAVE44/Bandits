BanditWeapons = BanditWeapons or {}

BanditWeapons.MakeMelee = function(name) 
    local melee = {}
    melee.name = name
    return melee.name
end

BanditWeapons.MakeHandgun = function(name, magName, magSize, shotSound, shotDelay) 
    local handgun = {}
    handgun.name = name
    handgun.magName = magName
    handgun.magSize = magSize
    handgun.bulletsLeft = magSize
    handgun.shotSound = shotSound
    handgun.shotDelay = shotDelay

    return handgun
end

-- vanilla weapons here

BanditWeapons.MeleeWeak = BanditWeapons.MeleeWeak or {}
table.insert(BanditWeapons.MeleeWeak, BanditWeapons.MakeMelee("Base.MeatCleaver"))
table.insert(BanditWeapons.MeleeWeak, BanditWeapons.MakeMelee("Base.BreadKnife"))
table.insert(BanditWeapons.MeleeWeak, BanditWeapons.MakeMelee("Base.Scalpel"))
table.insert(BanditWeapons.MeleeWeak, BanditWeapons.MakeMelee("Base.Pan"))
table.insert(BanditWeapons.MeleeWeak, BanditWeapons.MakeMelee("Base.RollingPin"))
table.insert(BanditWeapons.MeleeWeak, BanditWeapons.MakeMelee("Base.SmashedBottle"))
table.insert(BanditWeapons.MeleeWeak, BanditWeapons.MakeMelee("Base.HandScythe"))
table.insert(BanditWeapons.MeleeWeak, BanditWeapons.MakeMelee("Base.WoodenLance"))

BanditWeapons.MeleeStrong = BanditWeapons.MeleeStrong  or {}
table.insert(BanditWeapons.MeleeStrong, BanditWeapons.MakeMelee("Base.BaseballBat"))
table.insert(BanditWeapons.MeleeStrong, BanditWeapons.MakeMelee("Base.BaseballBatNails"))
table.insert(BanditWeapons.MeleeStrong, BanditWeapons.MakeMelee("Base.Crowbar"))
table.insert(BanditWeapons.MeleeStrong, BanditWeapons.MakeMelee("Base.LeadPipe"))
table.insert(BanditWeapons.MeleeStrong, BanditWeapons.MakeMelee("Base.Machete"))
table.insert(BanditWeapons.MeleeStrong, BanditWeapons.MakeMelee("Base.HandAxe"))

BanditWeapons.Primary = BanditWeapons.Primary or {}
table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.AssaultRifle2", "Base.M14Clip", 20, "M14Shoot", 38))
table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.AssaultRifle", "Base.556Clip", 20, "M14Shoot", 6))

BanditWeapons.Secondary = BanditWeapons.Secondary or {}
table.insert(BanditWeapons.Secondary, BanditWeapons.MakeHandgun("Base.Pistol", "Base.9mmClip", 15, "M9Shoot", 35))
table.insert(BanditWeapons.Secondary, BanditWeapons.MakeHandgun("Base.Pistol2", "Base.45Clip", 7, "M9Shoot", 47))
table.insert(BanditWeapons.Secondary, BanditWeapons.MakeHandgun("Base.Pistol3", "Base.44Clip", 8, "M9Shoot", 45))

-- register modded weapons options by adding them to tables below

if getActivatedMods():contains("Brita") then
    table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.AK103", "Base.AKClip", 30, "[1]Shot_762x39", 4))
    table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.AK12", "Base.545StdClip", 30, "[1]Shot_545", 3))
    table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.AK308", "Base.308ExtClip", 20, "[1]Shot_308", 10))
    table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.AK47", "Base.AKClip", 30, "[1]Shot_762x39", 10))
    table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.AK74", "Base.545StdClip", 30, "[1]Shot_545", 10))
    table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.AKM", "Base.762Drum", 75, "[1]Shot_762x39", 4))
    table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.Bush_XM15", "Base.556Clip", 30, "[1]Shot_556", 34))
    table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.ColtM16", "Base.556Clip", 30, "[1]Shot_556", 6))
    table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.M723", "Base.556Clip", 30, "[1]Shot_556", 6))
    table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.M4A1", "Base.556Clip", 30, "[1]Shot_556", 7))
    table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.FAMAS", "Base.556Clip", 30, "[1]Shot_556", 7))
    table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.G21LMG", "Base.308Belt", 30, "[1]Shot_308", 2))
    table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.G28", "Base.308ExtClip", 20, "[1]Shot_308", 10))
    table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.UZI_Micro", "Base.9mmExtClip", 20, "[1]Shot_9", 10))
end

if getActivatedMods():contains("firearmmod") then
    table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.AK47", "Base.AK_Mag", 30, "M14Shoot", 10))
    table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.AR15", "Base.556Clip", 30, "M14Shoot", 30))
    table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.M733", "Base.556Clip", 30, "M14Shoot", 10))
    table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.M733", "Base.FN_FAL_Mag", 20, "M14Shoot", 30))
    table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.Mac10", "Base.Mac10Mag", 30, "M9Shoot", 2))
    table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.MP5", "Base.MP5Mag", 30, "M9Shoot", 4))
    table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.UZI", "Base.UZIMag", 20, "M9Shoot", 3))
    table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.M60", "Base.M60Mag", 100, "FirearmM60Fire", 3))
    table.insert(BanditWeapons.Secondary, BanditWeapons.MakeHandgun("Base.ColtAce", "Base.22Clip", 15, "M9Shoot", 35))
    table.insert(BanditWeapons.Secondary, BanditWeapons.MakeHandgun("Base.Glock17", "Base.Glock17Mag", 17, "M9Shoot", 35))
end
