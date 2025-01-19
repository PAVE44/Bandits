BanditClan = BanditClan or {}

BanditClan.DoomRider = BanditClan.DoomRider or {}

-- The unique id of the clan, ids 1-16 are reserved for waves
BanditClan.DoomRider.id = 13

-- Name of the clan
BanditClan.DoomRider.name = "Doomrider"

-- % chance of a clan member to be a female. Outfit must support it.
BanditClan.DoomRider.femaleChance = 10

-- health ranges from 1 - 14. Higher values may produce unexpected results,
BanditClan.DoomRider.health = 5

-- if the bandit will eat player's body after death
BanditClan.DoomRider.eatBody = false

-- Ranged weapon accuracy multiplayer (1=default)
BanditClan.DoomRider.accuracyBoost = 1

-- Favorite zones 
BanditClan.DoomRider.favoriteZones = {}
BanditClan.DoomRider.avoidZones = {"Forest", "DeepForest"}

-- available outfits
BanditClan.DoomRider.Outfits = BanditClan.DoomRider.Outfits or {}
table.insert(BanditClan.DoomRider.Outfits, "Bandit")
table.insert(BanditClan.DoomRider.Outfits, "Bandit_Early")
table.insert(BanditClan.DoomRider.Outfits, "Bandit_Mid")
table.insert(BanditClan.DoomRider.Outfits, "Bandit_Late")

-- available melee weapons
BanditClan.DoomRider.Melee = BanditClan.DoomRider.Melee or {}
table.insert(BanditClan.DoomRider.Melee, "Base.BaseballBat_Nails")
table.insert(BanditClan.DoomRider.Melee, "Base.BaseballBat_RailSpike")
table.insert(BanditClan.DoomRider.Melee, "Base.BaseballBat_Sawblade")
table.insert(BanditClan.DoomRider.Melee, "Base.BaseballBat_Spiked")
table.insert(BanditClan.DoomRider.Melee, "Base.LongMace")
table.insert(BanditClan.DoomRider.Melee, "Base.Katana")
table.insert(BanditClan.DoomRider.Melee, "Base.Machete")
table.insert(BanditClan.DoomRider.Melee, "Base.HandAxe")
table.insert(BanditClan.DoomRider.Melee, "Base.Crowbar")

-- loot table
BanditClan.DoomRider.Loot = BanditClan.DoomRider.Loot or {}

table.insert(BanditClan.DoomRider.Loot, BanditLoot.MakeItem("Base.HandTorch", 100))
table.insert(BanditClan.DoomRider.Loot, BanditLoot.MakeItem("Base.Battery", 88))
table.insert(BanditClan.DoomRider.Loot, BanditLoot.MakeItem("Base.Battery", 88))
table.insert(BanditClan.DoomRider.Loot, BanditLoot.MakeItem("Base.AlcoholBandage", 33))
table.insert(BanditClan.DoomRider.Loot, BanditLoot.MakeItem("Base.AlcoholBandage", 33))
table.insert(BanditClan.DoomRider.Loot, BanditLoot.MakeItem("Base.Disinfectant", 99))
table.insert(BanditClan.DoomRider.Loot, BanditLoot.MakeItem("Base.Pills", 77))
table.insert(BanditClan.DoomRider.Loot, BanditLoot.MakeItem("Base.Pencil", 35))
table.insert(BanditClan.DoomRider.Loot, BanditLoot.MakeItem("Base.SutureNeedle", 35))
table.insert(BanditClan.DoomRider.Loot, BanditLoot.MakeItem("Base.SutureNeedleHolder", 35))
table.insert(BanditClan.DoomRider.Loot, BanditLoot.MakeItem("Base.Tweezers", 11))
table.insert(BanditClan.DoomRider.Loot, BanditLoot.MakeItem("Base.Toothbrush", 33))
table.insert(BanditClan.DoomRider.Loot, BanditLoot.MakeItem("Base.Toothpaste", 33))
table.insert(BanditClan.DoomRider.Loot, BanditLoot.MakeItem("Base.ToiletPaper", 66))

table.insert(BanditClan.DoomRider.Loot, BanditLoot.MakeItem("Base.WaterBottle", 99))
table.insert(BanditClan.DoomRider.Loot, BanditLoot.MakeItem("Base.Gum", 14))
table.insert(BanditClan.DoomRider.Loot, BanditLoot.MakeItem("Base.DehydratedMeatStick", 44))
table.insert(BanditClan.DoomRider.Loot, BanditLoot.MakeItem("Base.DehydratedMeatStick", 44))
table.insert(BanditClan.DoomRider.Loot, BanditLoot.MakeItem("Base.ToiletPaper", 66))
table.insert(BanditClan.DoomRider.Loot, BanditLoot.MakeItem("Base.MugWhite", 22))
table.insert(BanditClan.DoomRider.Loot, BanditLoot.MakeItem("Base.HuntingKnife", 22))
table.insert(BanditClan.DoomRider.Loot, BanditLoot.MakeItem("Base.Fork", 77))
table.insert(BanditClan.DoomRider.Loot, BanditLoot.MakeItem("Base.Spoon", 77))
table.insert(BanditClan.DoomRider.Loot, BanditLoot.MakeItem("Base.Chocolate", 33))

table.insert(BanditClan.DoomRider.Loot, BanditLoot.MakeItem("Base.CannedCornedBeef", 80))
table.insert(BanditClan.DoomRider.Loot, BanditLoot.MakeItem("Base.CannedCornedBeef", 80))
table.insert(BanditClan.DoomRider.Loot, BanditLoot.MakeItem("Base.CannedCornedBeef", 70))
table.insert(BanditClan.DoomRider.Loot, BanditLoot.MakeItem("Base.CannedCornedBeef", 10))

-- register this clan for spawn system
BanditCreator.ClanMap = BanditCreator.GroupMap or {}
BanditCreator.ClanMap[13] = BanditClan.DoomRider