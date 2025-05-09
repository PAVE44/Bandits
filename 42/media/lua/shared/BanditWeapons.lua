-- register modded weapons options by adding them to tables below

BanditWeapons = BanditWeapons or {}

BanditWeapons.MakeHandgun = function(name, magName, magSize, shotSound, shotDelay) 
    local handgun = {}
    handgun.type = "mag"
    handgun.clipIn = true
    handgun.racked = false
    handgun.name = name
    handgun.magName = magName
    handgun.magSize = magSize
    handgun.bulletsLeft = magSize

    return handgun
end

BanditWeapons.Make = function(itemType, boxCount)

    -- for now, harcoded
    local box2ammo = {}
    box2ammo["Base.ShotgunShellsBox"] = 25
    box2ammo["Base.556Bullets"] = 50
    box2ammo["Base.223Bullets"] = 50
    box2ammo["Base.308Bullets"] = 20
    box2ammo["Base.Bullets9mm"] = 50
    box2ammo["Base.Bullets45"] = 50
    box2ammo["Base.Bullets38"] = 50
    box2ammo["Base.Bullets44"] = 20

    local weapon = BanditCompatibility.InstanceItem(itemType)
    if not weapon then return end

    local ammoType = weapon:getAmmoType()
    if not ammoType then return end 

    local boxSize = 20
    if box2ammo[ammoType] then
        boxSize = box2ammo[ammoType]
    end

    local ammoBoxType = weapon:getAmmoBox()
    if not ammoBoxType then return end

    local ret = {}
    ret.name = BanditCompatibility.GetLegacyItem(itemType)
    ret.racked = false

    -- getAmmoBox returns type, not fullType
    -- so we need to fix this
    -- assume that ammo box type is from the same module as the ammo
    local mod = ammoType:match("([^%.]+)")
    ammoBoxType = mod .. "." .. ammoBoxType

    if BanditCompatibility.UsesExternalMagazine(weapon) then
        local magazineType = weapon:getMagazineType()
        if magazineType then
            local magazine = BanditCompatibility.InstanceItem(magazineType)
            if magazine then
                local magSize = magazine:getMaxAmmo()
                local magCount = math.floor(boxCount * boxSize / magSize) - 1
                ret.type = "mag"
                ret.bulletsLeft = magSize
                ret.magSize = magSize
                ret.magCount = magCount
                ret.magName = magazineType
                ret.clipIn = true
            end
        end
    else
        local ammoSize = weapon:getMaxAmmo()
        ret.type = "nomag"
        ret.bulletsLeft = ammoSize
        ret.ammoSize = ammoSize
        ret.ammoCount = boxCount * boxSize - ammoSize
        ret.ammoName = ammoType
    end

    return ret
end

BanditWeapons.GetPrimary = function()
    return BanditWeapons.Primary
end

BanditWeapons.GetSecondary = function()
    return BanditWeapons.Secondary
end

BanditWeapons.Primary = BanditWeapons.Primary or {}
table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.AssaultRifle2", "Base.M14Clip", 20, "M14Shoot", 38))
table.insert(BanditWeapons.Primary, BanditWeapons.MakeHandgun("Base.AssaultRifle", "Base.556Clip", 30, "M14Shoot", 12))

BanditWeapons.Secondary = BanditWeapons.Secondary or {}
table.insert(BanditWeapons.Secondary, BanditWeapons.MakeHandgun("Base.Pistol", "Base.9mmClip", 15, "M9Shoot", 35))
table.insert(BanditWeapons.Secondary, BanditWeapons.MakeHandgun("Base.Pistol2", "Base.45Clip", 7, "M1911Shoot", 47))
table.insert(BanditWeapons.Secondary, BanditWeapons.MakeHandgun("Base.Pistol3", "Base.44Clip", 8, "DesertEagleShoot", 45))

if getActivatedMods():contains("Brita") and getActivatedMods():contains("Arsenal(26)GunFighter[MAIN MOD 2.0]") then
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
