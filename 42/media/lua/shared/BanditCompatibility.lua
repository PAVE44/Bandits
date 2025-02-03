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



BanditCompatibility.LegacyItemMap = legacyItemMap

BanditCompatibility.GetLegacyItem = function(itemFullType)
    if getGameVersion() < 42 then
        local map = BanditCompatibility.LegacyItemMap
        if map[itemFullType] then
            return map[itemFullType]
        end
    end
    return itemFullType
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
    if getGameVersion() >= 42 then
        return instanceItem(itemFullType)
    else
        local itemFullTypeLegacy = BanditCompatibility.GetLegacyItem(itemFullType)
        return InventoryItemFactory.CreateItem(itemFullTypeLegacy)
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
