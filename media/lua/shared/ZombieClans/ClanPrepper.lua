BanditClan = BanditClan or {}

BanditClan.Prepper = BanditClan.Prepper or {}

-- The unique id of the clan, ids 1-16 are reserved for waves
BanditClan.Prepper.id = 7

-- Name of the clan
BanditClan.Prepper.name = "Prepper"

-- % chance of a clan member to be a female. Outfit must support it.
BanditClan.Prepper.femaleChance = 0

-- health ranges from 1 - 14. Higher values may produce unexpected results,
BanditClan.Prepper.health = 4

-- if the bandit will eat player's body after death
BanditClan.Prepper.eatBody = false

-- Ranged weapon accuracy multiplayer (1=default)
BanditClan.Prepper.accuracyBoost = 1

-- Favorite zones 
BanditClan.Prepper.favoriteZones = {"Vegitation", "Farm", "FarmLand", "Ranch"}

-- available outfits
BanditClan.Prepper.Outfits = BanditClan.Prepper.Outfits or {}
table.insert(BanditClan.Prepper.Outfits, "Survivalist03")

if getActivatedMods():contains("HNDLBR_Preppers") then
    table.insert(BanditClan.Prepper.Outfits, "HNDLBR_Prepper")
    table.insert(BanditClan.Prepper.Outfits, "HNDLBR_DoomsDayPrepper")
end

-- available melee weapons
BanditClan.Prepper.Melee = BanditClan.Prepper.Melee or {}
table.insert(BanditClan.Prepper.Melee, "Base.SpearHuntingKnife")
table.insert(BanditClan.Prepper.Melee, "Base.WoodenLance")
table.insert(BanditClan.Prepper.Melee, "Base.HuntingKnife")
table.insert(BanditClan.Prepper.Melee, "Base.Machete")
table.insert(BanditClan.Prepper.Melee, "Base.Axe")
table.insert(BanditClan.Prepper.Melee, "Base.HandAxe")

-- available primary weapons
BanditClan.Prepper.Primary = BanditClan.Prepper.Primary or BanditWeapons.Primary

-- available secondary weapons
BanditClan.Prepper.Secondary = BanditClan.Prepper.Secondary or BanditWeapons.Secondary

-- loot table
BanditClan.Prepper.Loot = BanditClan.Prepper.Loot or {}
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.WristWatch_Left_DigitalBlack", 100))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.HandTorch", 100))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.Battery", 88))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.Battery", 77))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.HandTorch", 66))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("camping.CampfireKit", 33))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.Matches", 99))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.CampingTentKit", 88))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.HuntingKnife", 80))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Radio.WalkieTalkieMakeShift", 23))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.AlcoholBandage", 33))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.AlcoholBandage", 33))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.Disinfectant", 55))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.Antibiotics", 2))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.Pills", 2))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.TinOpener", 11))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.Spoon", 40))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.Pencil", 35))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.Saucepan", 21))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.Scissors", 17))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.HandAxe", 17))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("farming.HandShovel", 7))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.Toothbrush", 77))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.Toothpaste", 77))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.Soap", 66))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.ToiletPaper", 99))

table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("farming.BroccoliSeed", 2))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("farming.CabbageSeed", 2))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("farming.CarrotSeed", 2))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("farming.PotatoSeed", 2))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("farming.RedRadishSeed", 2))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("farming.StrewberrieSeed", 2))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("farming.TomatoSeed", 2))

if getActivatedMods():contains("MCM") then
    table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("MCM.AvocadoBagSeed", 2))
    table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("MCM.PepperBagSeed", 2))
    table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("MCM.CornBagSeed", 2))
    table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("MCM.EggplantBagSeed", 2))
    table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("MCM.LeekBagSeed", 2))
    table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("MCM.LettuceBagSeed", 2))
    table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("MCM.OnionBagSeed", 2))
    table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("MCM.WatermelonBagSeed", 2)) 
    table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("MCM.ZucchiniBagSeed", 2))
end

if getActivatedMods():contains("WildFruitFarming") then
    table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("FarmingBerries.BlueberryCutting", 2))
    table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("FarmingBerries.BlackberryCutting", 2))
    table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("FarmingBerries.GrapeCutting", 2))
end

if getActivatedMods():contains("FarmingTime") then
    table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("filcher.BeetBagSeed", 2))
    table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("filcher.CoffeeBagSeed", 2))
    table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("filcher.CornBagSeed", 2))
    table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("filcher.CauliflowerBagSeed", 2))
    table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("filcher.SFLemonGrassBagSeed", 2))
    table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("filcher.LettuceBagSeed", 2))
    table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("filcher.TeaBagSeed", 2))
    table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("filcher.SFWheatBagSeed", 2))
    table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("filcher.Beetroot", 5))
    table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("filcher.Cauliflower", 4))
end

table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.WaterBottleFull", 99))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.WhiskeyFull", 22))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.DehydratedMeatStick", 7))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.Chocolate", 5))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.PeanutButter", 4))

table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.TinnedBeans", 1))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.CannedCarrots2", 1))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.CannedChili", 1))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.CannedCorn", 1))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.CannedCornedBeef", 1))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.CannedFruitCocktail", 1))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.CannedMushroomSoup", 1))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.CannedPeaches", 1))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.CannedPeas", 1))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.CannedPineapple", 1))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.CannedPotato2", 1))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.CannedSardines", 1))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.TinnedSoup", 1))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.CannedBolognese", 1))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.CannedTomato2", 1))

if getActivatedMods():contains("ExpandedHelicopterEvents") then
    table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.MealReadytoEatEHE", 70))
    table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.MealReadytoEatEHE", 70))
    table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.MealReadytoEatEHE", 20))
elseif getActivatedMods():contains("MREM") then
    table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("MREM.MRE", 70))
    table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("MREM.MRE", 70))
    table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("MREM.MRE", 20))
else
    table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.CannedCornedBeef", 80))
    table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.CannedCornedBeef", 70))
    table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.CannedCornedBeef", 10))
end

table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.TunaTin", 1))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.Salami", 1))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.Apple", 4))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.Pear", 2))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.Cherry", 2))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.Lettuce", 1))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.Grapes", 9))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.Onion", 5))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.Apple", 4))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.MushroomGeneric1", 19))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.MushroomGeneric2", 19))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.BerryBlack", 5))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.BerryBlue", 4))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.WildEggs", 19))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.WildGarlic", 19))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.Frog", 19))

table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.FarmingMag1", 4))
table.insert(BanditClan.Prepper.Loot, BanditLoot.MakeItem("Base.HerbalistMag", 4))

-- register this clan for spawn system
BanditCreator.ClanMap = BanditCreator.GroupMap or {}
BanditCreator.ClanMap[7] = BanditClan.Prepper
