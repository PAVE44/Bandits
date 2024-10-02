-- register modded weapons options by adding them to tables below

BanditWeapons = BanditWeapons or {}

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

BanditWeapons.Melee = BanditWeapons.Melee or {}

-- wave 1
BanditWeapons.Melee.DesperateCitizen = BanditWeapons.Melee.DesperateCitizen or {}
table.insert(BanditWeapons.Melee.DesperateCitizen, "Base.BreadKnife")
table.insert(BanditWeapons.Melee.DesperateCitizen, "Base.Pan")
table.insert(BanditWeapons.Melee.DesperateCitizen, "Base.RollingPin")
table.insert(BanditWeapons.Melee.DesperateCitizen, "Base.SmashedBottle")
table.insert(BanditWeapons.Melee.DesperateCitizen, "Base.HandScythe")
table.insert(BanditWeapons.Melee.DesperateCitizen, "Base.WoodenLance")
table.insert(BanditWeapons.Melee.DesperateCitizen, "Base.Banjo")
table.insert(BanditWeapons.Melee.DesperateCitizen, "Base.ChairLeg")
table.insert(BanditWeapons.Melee.DesperateCitizen, "Base.GardenFork")
table.insert(BanditWeapons.Melee.DesperateCitizen, "Base.GridlePan")
table.insert(BanditWeapons.Melee.DesperateCitizen, "Base.Hammer")
table.insert(BanditWeapons.Melee.DesperateCitizen, "Base.HockeyStick")
table.insert(BanditWeapons.Melee.DesperateCitizen, "Base.MetalPipe")
table.insert(BanditWeapons.Melee.DesperateCitizen, "Base.PipeWrench")
table.insert(BanditWeapons.Melee.DesperateCitizen, "Base.Plunger")
table.insert(BanditWeapons.Melee.DesperateCitizen, "Base.GuitarElectricRed")
table.insert(BanditWeapons.Melee.DesperateCitizen, "Base.Saucepan")
table.insert(BanditWeapons.Melee.DesperateCitizen, "Base.TableLeg")
table.insert(BanditWeapons.Melee.DesperateCitizen, "Base.Wrench")

if getActivatedMods():contains("Authentic Z - Current") then
    table.insert(BanditWeapons.Melee.DesperateCitizen, "AuthenticZClothing.Stop_Sign")
    table.insert(BanditWeapons.Melee.DesperateCitizen, "AuthenticZClothing.TrashCanLid_MNG")
    table.insert(BanditWeapons.Melee.DesperateCitizen, "AuthenticZClothing.RotaryPhone_AZ")
    table.insert(BanditWeapons.Melee.DesperateCitizen, "AuthenticZClothing.AuthenticWalkingCaneGrandFather")
end    

-- wave 2
BanditWeapons.Melee.Psychopath = BanditWeapons.Melee.Psychopath or {}
table.insert(BanditWeapons.Melee.Psychopath, "Base.WoodAxe")
table.insert(BanditWeapons.Melee.Psychopath, "Base.HammerStone")
table.insert(BanditWeapons.Melee.Psychopath, "Base.PlankNail")
table.insert(BanditWeapons.Melee.Psychopath, "Base.PickAxe")
table.insert(BanditWeapons.Melee.Psychopath, "Base.MetalBar")
table.insert(BanditWeapons.Melee.Psychopath, "Base.LeadPipe")

if getActivatedMods():contains("Authentic Z - Current") then
    table.insert(BanditWeapons.Melee.Psychopath, "AuthenticZClothing.Chainsaw")
end

-- wave 3
BanditWeapons.Melee.Cannibal = BanditWeapons.Melee.Cannibal or {}
table.insert(BanditWeapons.Melee.Cannibal, "Base.MeatCleaver")
table.insert(BanditWeapons.Melee.Cannibal, "Base.KitchenKnife")
table.insert(BanditWeapons.Melee.Cannibal, "Base.BreadKnife")

-- wave 4
BanditWeapons.Melee.Criminal = BanditWeapons.Melee.Criminal or {}
table.insert(BanditWeapons.Melee.Criminal, "Base.Crowbar")
table.insert(BanditWeapons.Melee.Criminal, "Base.MetalBar")
table.insert(BanditWeapons.Melee.Criminal, "Base.BaseballBat")
table.insert(BanditWeapons.Melee.Criminal, "Base.KitchenKnife")

-- wave 5
BanditWeapons.Melee.Inmate = BanditWeapons.Melee.Inmate or {}
table.insert(BanditWeapons.Melee.Inmate, "Base.BreadKnife")
table.insert(BanditWeapons.Melee.Inmate, "Base.KitchenKnife")
table.insert(BanditWeapons.Melee.Inmate, "Base.MetalBar")
table.insert(BanditWeapons.Melee.Inmate, "Base.Shovel2") 
table.insert(BanditWeapons.Melee.Inmate, "Base.SmashedBottle")

-- wave 6
BanditWeapons.Melee.Police = BanditWeapons.Melee.Police or {}
table.insert(BanditWeapons.Melee.Police, "Base.Nightstick")

-- wave 7
BanditWeapons.Melee.Prepper = BanditWeapons.Melee.Prepper or {}
table.insert(BanditWeapons.Melee.Prepper, "Base.SpearHuntingKnife")
table.insert(BanditWeapons.Melee.Prepper, "Base.WoodenLance")
table.insert(BanditWeapons.Melee.Prepper, "Base.HuntingKnife")
table.insert(BanditWeapons.Melee.Prepper, "Base.Machete")
table.insert(BanditWeapons.Melee.Prepper, "Base.Axe")

-- wave 8
BanditWeapons.Melee.Veteran = BanditWeapons.Melee.Veteran or {}
table.insert(BanditWeapons.Melee.Veteran, "Base.Machete")
table.insert(BanditWeapons.Melee.Veteran, "Base.HuntingKnife")

-- wave 9
BanditWeapons.Melee.Biker = BanditWeapons.Melee.Biker or {}
table.insert(BanditWeapons.Melee.Biker, "Base.BaseballBat")
table.insert(BanditWeapons.Melee.Biker, "Base.BaseballBatNails")

-- wave 10
BanditWeapons.Melee.Hunter = BanditWeapons.Melee.Hunter or {}
table.insert(BanditWeapons.Melee.Hunter, "Base.KitchenKnife")
table.insert(BanditWeapons.Melee.Hunter, "Base.Machete")

-- wave 11
BanditWeapons.Melee.Reclaimer = BanditWeapons.Melee.Reclaimer or {}
table.insert(BanditWeapons.Melee.Reclaimer, "Base.Katana")
table.insert(BanditWeapons.Melee.Reclaimer, "Base.HandScythe")

if getActivatedMods():contains("Authentic Z - Current") then
    table.insert(BanditWeapons.Melee.Reclaimer, "AuthenticZClothing.MandoSpear")
    table.insert(BanditWeapons.Melee.Reclaimer, "AuthenticZClothing.Chainsaw")
end

-- wave 12
BanditWeapons.Melee.Scientist = BanditWeapons.Melee.Scientist or {}
table.insert(BanditWeapons.Melee.Scientist, "Base.Scalpel")

-- wave 13
BanditWeapons.Melee.DoomRider = BanditWeapons.Melee.DoomRider or {}
table.insert(BanditWeapons.Melee.DoomRider, "Base.BaseballBatNails")
table.insert(BanditWeapons.Melee.DoomRider, "Base.Katana")
table.insert(BanditWeapons.Melee.DoomRider, "Base.Machete")
table.insert(BanditWeapons.Melee.DoomRider, "Base.HandAxe")
table.insert(BanditWeapons.Melee.DoomRider, "Base.Crowbar")

-- wave 14
BanditWeapons.Melee.PrivateMilitia = BanditWeapons.Melee.PrivateMilitia or {}
table.insert(BanditWeapons.Melee.PrivateMilitia, "Base.Machete")
table.insert(BanditWeapons.Melee.PrivateMilitia, "Base.HuntingKnife")

-- wave 15
BanditWeapons.Melee.DeathLegion = BanditWeapons.Melee.DeathLegion or {}
table.insert(BanditWeapons.Melee.DeathLegion, "Base.Machete")
table.insert(BanditWeapons.Melee.DeathLegion, "Base.HuntingKnife")

-- wave 16
BanditWeapons.Melee.NewOrder = BanditWeapons.Melee.NewOrder or {}
table.insert(BanditWeapons.Melee.NewOrder, "Base.HuntingKnife")

--

BanditWeapons.Primary = BanditWeapons.Primary or {}
table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.AssaultRifle2", "Base.M14Clip", 20, "M14Shoot", 38))
table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.AssaultRifle", "Base.556Clip", 30, "M14Shoot", 12))

BanditWeapons.Secondary = BanditWeapons.Secondary or {}
table.insert(BanditWeapons.Secondary, BanditWeapons.MakeHandgun("Base.Pistol", "Base.9mmClip", 15, "M9Shoot", 35))
table.insert(BanditWeapons.Secondary, BanditWeapons.MakeHandgun("Base.Pistol2", "Base.45Clip", 7, "M1911Shoot", 47))
table.insert(BanditWeapons.Secondary, BanditWeapons.MakeHandgun("Base.Pistol3", "Base.44Clip", 8, "DesertEagleShoot", 45))

if getActivatedMods():contains("Brita") then
    table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.AK103", "Base.AKClip", 30, "[1]Shot_762x39", 5))
    table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.AK12", "Base.545StdClip", 30, "[1]Shot_545", 4))
    table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.AK308", "Base.308ExtClip", 20, "[1]Shot_308", 10))
    table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.AK47", "Base.AKClip", 30, "[1]Shot_762x39", 10))
    table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.AK74", "Base.545StdClip", 30, "[1]Shot_545", 10))
    table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.AKM", "Base.762Drum", 75, "[1]Shot_762x39", 10))
    table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.Bush_XM15", "Base.556Clip", 30, "[1]Shot_556", 34))
    table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.ColtM16", "Base.556Clip", 30, "[1]Shot_556", 8))
    table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.M723", "Base.556Clip", 30, "[1]Shot_556", 6))
    table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.M4A1", "Base.556Clip", 30, "[1]Shot_556", 7))
    table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.FAMAS", "Base.556Clip", 30, "[1]Shot_556", 7))
    table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.G21LMG", "Base.308Belt", 30, "[1]Shot_308", 3))
    table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.G28", "Base.308ExtClip", 20, "[1]Shot_308", 10))
    table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.UZI_Micro", "Base.9mmExtClip", 20, "[1]Shot_9", 10))
end

if getActivatedMods():contains("firearmmod") or getActivatedMods():contains("firearmmodRevamp") then
    table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.AK47", "Base.AK_Mag", 30, "M14Shoot", 10))
    table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.AR15", "Base.556Clip", 30, "M14Shoot", 30))
    table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.M733", "Base.556Clip", 30, "M14Shoot", 10))
    table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.FN_FAL", "Base.FN_FAL_Mag", 20, "M14Shoot", 30))
    table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.Mac10", "Base.Mac10Mag", 30, "M9Shoot", 8))
    table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.MP5", "Base.MP5Mag", 30, "M9Shoot", 12))
    table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.UZI", "Base.UZIMag", 20, "M9Shoot", 11))
    table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.M60", "Base.M60Mag", 100, "FirearmM60Fire", 13))
    table.insert(BanditWeapons.Secondary, BanditWeapons.MakeHandgun("Base.ColtAce", "Base.22Clip", 15, "M9Shoot", 35))
    table.insert(BanditWeapons.Secondary, BanditWeapons.MakeHandgun("Base.Glock17", "Base.Glock17Mag", 17, "M9Shoot", 35))
end

if getActivatedMods():contains("VFExpansion1") then
    table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.AK47", "Base.762Clip", 30, "AK47shoot", 17))
    table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.CAR15", "Base.556Clip", 30, "M14Shoot", 17))
    table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.FAL", "Base.FALClip", 20, "M14Shoot", 17))
    table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.MAC10Unfolded", "Base.45Clip32", 32, "M1911Shoot", 10))
    table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.M60MMG", "Base.M60Belt", 100, "M1911Shoot", 13))
    table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.CampCarbine", "Base.45Clip", 7, "M1911Shoot", 22))
    table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.MP5Unfolded", "Base.9mmClip30", 7, "M9Shoot", 12))
    table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.Mini14", "Base.223Clip20", 20, "AK47shoot", 17))
    
    table.insert(BanditWeapons.Secondary, BanditWeapons.MakeHandgun("Base.CZ75", "Base.9mmClip16", 16, "M9Shoot", 35))
    table.insert(BanditWeapons.Secondary, BanditWeapons.MakeHandgun("Base.Glock", "Base.9mmClip16", 16, "M9Shoot", 35))
    table.insert(BanditWeapons.Secondary, BanditWeapons.MakeHandgun("Base.Glock18", "Base.9mmClip17", 16, "M9Shoot", 6))
    table.insert(BanditWeapons.Secondary, BanditWeapons.MakeHandgun("Base.MK2", "Base.22ClipPistol", 10, "Mk2shoot", 35))
    table.insert(BanditWeapons.Secondary, BanditWeapons.MakeHandgun("Base.MK23SOCOM", "Base.45Clip12", 12, "Mk2SDshoot", 35))
    table.insert(BanditWeapons.Secondary, BanditWeapons.MakeHandgun("Base.UziUnfolded", "Base.9mmClip32", 32, "M9Shoot", 6))
end

if getActivatedMods():contains("Guns93") then
    table.insert(BanditWeapons.Secondary, BanditWeapons.MakeHandgun("Base.Gov1911", "Base.45Clip", 7, "M1911Shoot", 47))
    table.insert(BanditWeapons.Secondary, BanditWeapons.MakeHandgun("Base.Javelina", "Base.DeltaEliteMag", 8, "DesertEagleShoot", 47))
    table.insert(BanditWeapons.Secondary, BanditWeapons.MakeHandgun("Base.DeltaElite", "Base.DeltaEliteMag", 8, "DesertEagleShoot", 47))
    table.insert(BanditWeapons.Secondary, BanditWeapons.MakeHandgun("Base.CalicoPistol", "Base.CalicoMag", 50, "M9Shoot", 35))
    table.insert(BanditWeapons.Secondary, BanditWeapons.MakeHandgun("Base.Glock17", "Base.G17Mag", 17, "M9Shoot", 35))
    table.insert(BanditWeapons.Secondary, BanditWeapons.MakeHandgun("Base.Glock20", "Base.G20Mag", 15, "M1911Shoot", 35))
    table.insert(BanditWeapons.Secondary, BanditWeapons.MakeHandgun("Base.Glock21", "Base.G21Mag", 13, "M1911Shoot", 35))
    table.insert(BanditWeapons.Secondary, BanditWeapons.MakeHandgun("Base.Glock22", "Base.G22Mag", 15, "M9Shoot", 35))
    table.insert(BanditWeapons.Secondary, BanditWeapons.MakeHandgun("Base.USP40", "Base.USP40Mag", 13, "M9Shoot", 34))
    table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.AKM", "Base.AKMag", 30, "DesertEagleShoot", 9))
    table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.AKMS", "Base.AKMag", 30, "DesertEagleShoot", 10))
    table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.CAR15", "Base.556Clip", 30, "M14Shoot", 12))
    table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.AR180", "Base.AR180Mag", 30, "M14Shoot", 12))
    table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.Brown308BAR", "Base.308BARMag", 4, "M14Shoot", 33))
    table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.Brown3006BAR", "Base.3006BARMag", 4, "M14Shoot", 35))
    table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.CalicoRifle", "Base.CalicoMag", 50, "M9Shoot", 22))
    table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.M635", "Base.ColtSMGMag", 32, "M9Shoot", 17))
    table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.M723", "Base.556Clip", 32, "M14Shoot", 33))
    table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.FAL", "Base.FALMag", 20, "M14Shoot", 38))
    table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.MP5", "Base.MP5Mag", 30, "M9Shoot", 12))
    table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.HK91", "Base.HK91Mag", 20, "M14Shoot", 35))
end
