BanditCompatibility = BanditCompatibility or {}

-- compatibility wrappers

local getGameVersion = function()
    return getCore():getGameVersion():getMajor()
end

BanditCompatibility.GetGameVersion = getGameVersion

local legacyItemMap = {}
legacyItemMap["Base.WineOpen"]                  = "Base.WineEmpty"
legacyItemMap["Base.BaseballBat_Nails"]         = "Base.BaseballBatNails"
legacyItemMap["Base.BaseballBat_RailSpike"]     = "Base.BaseballBatNails"
legacyItemMap["Base.BaseballBat_Sawblade"]      = "Base.BaseballBatNails"
legacyItemMap["Base.BaseballBat_Spiked"]        = "Base.BaseballBatNails"
legacyItemMap["Base.BaseballBat_Metal"]         = "Base.BaseballBatNails"
legacyItemMap["Base.WaterBottle"]               = "Base.WaterBottleFull"
legacyItemMap["Base.Whiskey"]                   = "Base.WhiskeyFull"
legacyItemMap["Base.Plank_Nails"]               = "Base.PlankNail"
legacyItemMap["Base.BaconBits"]                 = "farming.BaconBits"
legacyItemMap["Base.SpearShort"]                = "Base.WoodenLance"
legacyItemMap["Base.GuitarElectric"]            = "Base.GuitarElectricRed"
legacyItemMap["Base.HandShovel"]                = "farming.HandShovel"
legacyItemMap["Base.BroccoliBagSeed2"]          = "farming.BroccoliBagSeed"
legacyItemMap["Base.CabbageBagSeed2"]           = "farming.CabbageBagSeed"
legacyItemMap["Base.CarrotBagSeed2"]            = "farming.CarrotBagSeed"
legacyItemMap["Base.PotatoBagSeed2"]            = "farming.PotatoBagSeed"
legacyItemMap["Base.RedRadishBagSeed2"]         = "farming.RedRadishBagSeed"
legacyItemMap["Base.StrewberrieBagSeed2"]       = "farming.StrewberrieBagSeed"
legacyItemMap["Base.TomatoBagSeed2"]            = "farming.TomatoBagSeed"
legacyItemMap["Base.CigaretteSingle"]           = "Base.Cigarettes"
legacyItemMap["Base.WateredCan"]                = "farming.WateredCan"
legacyItemMap["Base.TireIron"]                  = "Base.LugWrench"
legacyItemMap["Base.Ratchet"]                   = "Base.Wrench"
legacyItemMap["Base.LightBulbBox"]              = "Base.LightBulb"
legacyItemMap["Base.Toolbox_Mechanic"]          = "Base.Toolbox"
legacyItemMap["Base.Bag_Satchel_Medical"]       = "Base.Bag_Satchel"
legacyItemMap["Base.GuitarElectricBass"]        = "Base.GuitarElectricBassBlack"
legacyItemMap["Base.PiePumpkin"]                = "Base.PieApple"
legacyItemMap["Base.CakeCarrot"]                = "Base.PieApple"
legacyItemMap["Base.EggOmlette"]                = "Base.Pancakes"
legacyItemMap["Base.PiePumpkin"]                = "Base.PieApple"
legacyItemMap["Base.PiePumpkin"]                = "Base.PieApple"
legacyItemMap["Base.FightingKnife"]             = "Base.HuntingKnife"
legacyItemMap["Base.LargeKnife"]                = "Base.HuntingKnife"
legacyItemMap["Base.BoltCutters"]               = "Base.Crowbar"


BanditCompatibility.LegacyItemMap = legacyItemMap

BanditCompatibility.GetConfigPath = function()
    if getGameVersion() < 42 then
        return "media" .. getFileSeparator() .. "bandits" .. getFileSeparator() -- that'll be /media/bandits/
    else
        return "bandits" .. getFileSeparator() -- that'll be common/bandits/
    end
end

BanditCompatibility.GetModPrefix = function()
    if getGameVersion() < 42 then
        return ""
    else
        return "\\"
    end
end

BanditCompatibility.GetLegacyItem = function(itemFullType)
    if getGameVersion() < 42 then
        local map = BanditCompatibility.LegacyItemMap
        if map[itemFullType] then
            return map[itemFullType]
        end
    end
    return itemFullType
end

BanditCompatibility.SetRandomCondition = function(item, m)
    item:setCondition(ZombRand(item:getConditionMax() * m) + 1)

    if getGameVersion() >= 42 and item:hasHeadCondition() then
        item:setHeadCondition(ZombRand(item:getHeadConditionMax() * 0.8) + 1)
    end
    return item
end

BanditCompatibility.GetClickedSquare = function()
    if getGameVersion() >= 42 then
        local fetch = ISWorldObjectContextMenu.fetchVars
        return fetch.clickedSquare
    else
        return clickedSquare
    end
end

BanditCompatibility.GetGuardpostKey = function()
    if getGameVersion() >= 42 then
        local options = PZAPI.ModOptions:getOptions("Bandits")
        return options:getOption("POSTS"):getValue()
    else
        return getCore():getKey("POSTS")
    end
end

BanditCompatibility.InstanceItem = function(itemFullType)
    local item
    if getGameVersion() >= 42 then
        item = instanceItem(itemFullType)
    else
        local itemFullTypeLegacy = BanditCompatibility.GetLegacyItem(itemFullType)
        item = InventoryItemFactory.CreateItem(itemFullTypeLegacy)
    end

    if item then
        return item
    else
        print ("[WARN] Item " .. itemFullType .. " not found!")
    end
end

BanditCompatibility.Splash = function(bandit, item, zombie)
    if getGameVersion() >= 42 then
        local splatNo = item:getSplatNumber()
        for i=0, splatNo do
            bandit:splatBlood(3, 0.3)
        end
        bandit:splatBloodFloorBig()
        bandit:playBloodSplatterSound()
    else
        SwipeStatePlayer.splash(bandit, item, zombie)
    end
end

BanditCompatibility.PlayerVoiceSound = function(player, sound)
    if getGameVersion() >= 42 then
        player:playerVoiceSound(sound)
    else
        -- not implemented
    end
end

BanditCompatibility.StartMuzzleFlash = function(shooter)
    if getGameVersion() >= 42 then
        local square = shooter:getSquare()
        shooter:startMuzzleFlash() -- it does not work in b42 apparently, so here is how to do this now:
        shooter:setMuzzleFlashDuration(getTimestampMs())
        local lightSource = IsoLightSource.new(square:getX(), square:getY(), square:getZ(), 0.8, 0.8, 0.7, 18, 2)
        getCell():addLamppost(lightSource)
    else
        shooter:startMuzzleFlash()
    end
end

BanditCompatibility.IsReanimatedForGrappleOnly = function(zombie)
    if getGameVersion() >= 42 then
        return zombie:isReanimatedForGrappleOnly()
    else
        return false
    end
end

BanditCompatibility.AddZombiesInOutfit = function(x, y, z, outfit, femaleChance, crawler, isFallOnFront, isFakeDead, knockedDown, isInvulnerable, isSitting, health)
    local zombieList
    if getGameVersion() >= 42 then
        zombieList = addZombiesInOutfit(x, y, z, 1, outfit, femaleChance, crawler, isFallOnFront, isFakeDead, knockedDown, isInvulnerable, isSitting, health)
    else
        zombieList = addZombiesInOutfit(x, y, z, 1, outfit, femaleChance, crawler, isFallOnFront, isFakeDead, knockedDown, health)
    end
    return zombieList
end

BanditCompatibility.AddId = function(zombie, fullname)
    if getGameVersion() >= 42 then
        local itemName = "Base.IDcard"
        if zombie:isFemale() then itemName = "Base.IDcard_Female" end
        local item = instanceItem(itemName)
        item:setName("ID Card:" .. fullname)
        zombie:addItemToSpawnAtDeath(item)
    else
        local item = InventoryItemFactory.CreateItem("Base.KeyRing")
        item:setName(fullname .. " Key Ring")
        zombie:addItemToSpawnAtDeath(item)
    end
end

BanditCompatibility.SurpressZombieSounds = function(bandit)
    if getGameVersion() >= 42 then
        bandit:getEmitter():stopSoundByName(bandit:getVoiceSoundName())
        bandit:getEmitter():stopSoundByName(bandit:getBiteSoundName())
    else
        bandit:getEmitter():stopSoundByName("MaleZombieCombined")
        bandit:getEmitter():stopSoundByName("FemaleZombieCombined")
    end
end

BanditCompatibility.HaveRoofFull = function(square)
    if getGameVersion() >= 42 then
        return square:haveRoofFull()
    else
        return true
    end
end

BanditCompatibility.GetMovementSpeed = function(object)
    if getGameVersion() >= 42 then
        local tempo = IsoGameCharacter.getTempo()
        tempo:setX(object:getX() - object:getLastX())
        tempo:setY(object:getY() - object:getLastY())
        return tempo:getLength()

        -- return object:getMovementSpeed()
    else
        local tempo = IsoGameCharacter.getTempo()
        tempo:setX(object:getX() - object:getLx())
        tempo:setY(object:getY() - object:getLy())
        return tempo:getLength()
    end
end

BanditCompatibility.UsesExternalMagazine = function(weapon)
    if getGameVersion() >= 42 then
        return weapon:usesExternalMagazine()
    else
        local magazineType = weapon:getMagazineType()
        if magazineType then return true end
    end
    return false
end

BanditCompatibility.GetBodyLocations = function(weapon)
    local bodyLocations = {}
    if getGameVersion() >= 42 then
        bodyLocations = {
            Head = {"Hat", "FullHat", "Ears", "EarTop", "Nose"},
            Face = {"Mask", "MaskEyes", "Eyes", "RightEye", "LeftEye"},
            Neck = {"Neck", "Necklace", "Scarf", "Gorget"},
            Suit = {"FullSuit", "FullSuitHead", "Boilersuit", "Torso1Legs1", "Dress", "LongDress", "BathRobe"},
            TopShirt = {"TankTop", "Tshirt", "ShortSleeveShirt", "Shirt"},
            TopJacket = {"Jacket", "JacketHat", "Jacket_Down", "JacketHat_Bulky", "Jacket_Bulky", "JacketSuit", "FullTop"},
            TopExtra = {"TorsoExtra", "TorsoExtraVest", "TorsoExtraVestBullet", "VestTexture", "Sweater", "SweaterHat"},
            Underwear = {"UnderwearBottom", "UnderwearTop", "UnderwearExtra1", "UnderwearExtra2"},
            TopArmor = {"ShoulderpadRight", "ShoulderpadLeft", "ForeArm_Right", "ForeArm_Left"},
            Hands = {"Hands", "RightWrist", "Right_MiddleFinger", "Right_RingFinger", "LeftWrist", "Left_MiddleFinger", "Left_RingFinger"},
            Bags = {"FannyPackFront", "FannyPackBack", "Webbing"},
            Holsters = {"AmmoStrap", "AnkleHolster", "BeltExtra", "ShoulderHolster"},
            Bottom = {"Pants", "PantsExtra", "Legs1", "ShortPants", "ShortsShort", "LongSkirt", "Skirt"},
            BottomArmor = {"Thigh_Right", "Thigh_Left", "Knee_Right", "Knee_Left", "Calf_Right", "Calf_Left"},
            Shoes = {"Shoes", "Socks"}
        }
    else
        bodyLocations = {
            Head = {"Hat", "FullHat", "Ears", "EarTop", "Nose"},
            Face = {"Mask", "MaskEyes", "Eyes", "RightEye", "LeftEye"},
            Neck = {"Neck", "Necklace", "Scarf"},
            Suit = {"FullSuit", "FullSuitHead", "Boilersuit", "Torso1Legs1", "Dress", "BathRobe"},
            TopShirt = {"TankTop", "Tshirt", "ShortSleeveShirt", "Shirt"},
            TopJacket = {"Jacket", "JacketHat", "Jacket_Down", "JacketHat_Bulky", "Jacket_Bulky", "JacketSuit", "FullTop"},
            TopExtra = {"TorsoExtra", "TorsoExtraVest", "Sweater", "SweaterHat"},
            Underwear = {"UnderwearBottom", "UnderwearTop", "UnderwearExtra1", "UnderwearExtra2"},
            Hands = {"Hands", "RightWrist", "Right_MiddleFinger", "Right_RingFinger", "LeftWrist", "Left_MiddleFinger", "Left_RingFinger"},
            Bags = {"FannyPackFront", "FannyPackBack"},
            Holsters = {"AmmoStrap", "BeltExtra"},
            Bottom = {"Pants", "Legs1", "Skirt"},
            Shoes = {"Shoes", "Socks"}
        }
    end
    return bodyLocations
end
