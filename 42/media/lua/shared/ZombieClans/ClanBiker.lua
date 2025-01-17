require "BanditWeapons"
BanditClan = BanditClan or {}

BanditClan.Biker = BanditClan.Biker or {}

-- The unique id of the clan, ids 1-16 are reserved for waves
BanditClan.Biker.id = 9

-- Name of the clan
BanditClan.Biker.name = "Biker"

-- % chance of a clan member to be a female. Outfit must support it.
BanditClan.Biker.femaleChance = 20

-- health ranges from 1 - 14. Higher values may produce unexpected results,
BanditClan.Biker.health = 3

-- if the bandit will eat player's body after death
BanditClan.Biker.eatBody = false

-- Ranged weapon accuracy multiplayer (1=default)
BanditClan.Biker.accuracyBoost = 0.8 -- these drunks can't aim

-- Favorite zones 
BanditClan.Biker.favoriteZones = {"TrailerPark"}
BanditClan.Biker.avoidZones = {"Vegitation", "Forest", "DeepForest"}

-- available outfits
BanditClan.Biker.Outfits = BanditClan.Biker.Outfits or {}
table.insert(BanditClan.Biker.Outfits, "Biker")
table.insert(BanditClan.Biker.Outfits, "Goth")

-- available melee weapons
BanditClan.Biker.Melee = BanditClan.Biker.Melee or {}
table.insert(BanditClan.Biker.Melee, "Base.BaseballBat")
table.insert(BanditClan.Biker.Melee, "Base.BaseballBat_Nails")
table.insert(BanditClan.Biker.Melee, "Base.BaseballBat_RailSpike")
table.insert(BanditClan.Biker.Melee, "Base.BaseballBat_Sawblade")
table.insert(BanditClan.Biker.Melee, "Base.BaseballBat_Spiked")

-- available primary weapons
BanditClan.Biker.Primary = BanditClan.Biker.Primary or BanditWeapons.Primary

-- available secondary weapons
BanditClan.Biker.Secondary = BanditClan.Biker.Secondary or BanditWeapons.Secondary

-- loot table
BanditClan.Biker.Loot = BanditClan.Biker.Loot or {}

table.insert(BanditClan.Biker.Loot, BanditLoot.MakeItem("Base.WristWatch_Left_DigitalBlack", 100))
table.insert(BanditClan.Biker.Loot, BanditLoot.MakeItem("Base.HandTorch", 50))
table.insert(BanditClan.Biker.Loot, BanditLoot.MakeItem("Base.Lighter", 99))
table.insert(BanditClan.Biker.Loot, BanditLoot.MakeItem("Base.AlcoholBandage", 33))
table.insert(BanditClan.Biker.Loot, BanditLoot.MakeItem("Base.AlcoholBandage", 33))
table.insert(BanditClan.Biker.Loot, BanditLoot.MakeItem("Base.Disinfectant", 55))
table.insert(BanditClan.Biker.Loot, BanditLoot.MakeItem("Base.Pills", 12))
table.insert(BanditClan.Biker.Loot, BanditLoot.MakeItem("Base.Spoon", 40))
table.insert(BanditClan.Biker.Loot, BanditLoot.MakeItem("Base.WaterBottle", 99))
table.insert(BanditClan.Biker.Loot, BanditLoot.MakeItem("Base.Whiskey", 77))
table.insert(BanditClan.Biker.Loot, BanditLoot.MakeItem("Base.Whiskey", 24))
table.insert(BanditClan.Biker.Loot, BanditLoot.MakeItem("Base.BeerCan", 24))
table.insert(BanditClan.Biker.Loot, BanditLoot.MakeItem("Base.BeerCan", 24))
table.insert(BanditClan.Biker.Loot, BanditLoot.MakeItem("Base.BeerCan", 24))
table.insert(BanditClan.Biker.Loot, BanditLoot.MakeItem("Base.BeerCan", 24))
table.insert(BanditClan.Biker.Loot, BanditLoot.MakeItem("Base.DehydratedMeatStick", 12))
table.insert(BanditClan.Biker.Loot, BanditLoot.MakeItem("Base.BeefJerky", 18))
table.insert(BanditClan.Biker.Loot, BanditLoot.MakeItem("Base.Peanuts", 18))
table.insert(BanditClan.Biker.Loot, BanditLoot.MakeItem("Base.Crackers", 5))
table.insert(BanditClan.Biker.Loot, BanditLoot.MakeItem("Base.Crisps", 5))
table.insert(BanditClan.Biker.Loot, BanditLoot.MakeItem("Base.Crisps2", 5))
table.insert(BanditClan.Biker.Loot, BanditLoot.MakeItem("Base.Crisps3", 5))
table.insert(BanditClan.Biker.Loot, BanditLoot.MakeItem("Base.Crisps4", 5))
table.insert(BanditClan.Biker.Loot, BanditLoot.MakeItem("Base.TinnedBeans", 1))
table.insert(BanditClan.Biker.Loot, BanditLoot.MakeItem("Base.CannedChili", 1))
table.insert(BanditClan.Biker.Loot, BanditLoot.MakeItem("Base.CannedCorn", 1))
table.insert(BanditClan.Biker.Loot, BanditLoot.MakeItem("Base.CannedCornedBeef", 1))
table.insert(BanditClan.Biker.Loot, BanditLoot.MakeItem("Base.CannedBolognese", 3))
table.insert(BanditClan.Biker.Loot, BanditLoot.MakeItem("Base.HottieZ", 44))
table.insert(BanditClan.Biker.Loot, BanditLoot.MakeItem("Base.EngineParts", 22))
table.insert(BanditClan.Biker.Loot, BanditLoot.MakeItem("Base.Base.PetrolCan", 12))
table.insert(BanditClan.Biker.Loot, BanditLoot.MakeItem("Base.PetrolBleachBottle", 33))

-- register this clan for spawn system
BanditCreator.ClanMap = BanditCreator.GroupMap or {}
BanditCreator.ClanMap[9] = BanditClan.Biker
