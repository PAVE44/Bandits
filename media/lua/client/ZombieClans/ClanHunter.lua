BanditClan = BanditClan or {}

BanditClan.Hunter = BanditClan.Hunter or {}

-- The unique id of the clan, ids 1-16 are reserved for waves
BanditClan.Hunter.id = 10

-- Name of the clan
BanditClan.Hunter.name = "Hunter"

-- % chance of a clan member to be a female. Outfit must support it.
BanditClan.Hunter.femaleChance = 0

-- health ranges from 1 - 14. Higher values may produce unexpected results,
BanditClan.Hunter.health = 1.4

-- if the bandit will eat player's body after death
BanditClan.Hunter.eatBody = false

-- Ranged weapon accuracy multiplayer (1=default)
BanditClan.Hunter.accuracyBoost = 1.1

-- Favorite zones 
BanditClan.Hunter.favoriteZones = {"Forest", "DeepForest"}
BanditClan.Hunter.avoidZones = {"TownZone", "Nav"}

-- available outfits
BanditClan.Hunter.Outfits = BanditClan.Hunter.Outfits or {}
table.insert(BanditClan.Hunter.Outfits, "Hunter")

-- available melee weapons
BanditClan.Hunter.Melee = BanditClan.Hunter.Melee or {}
table.insert(BanditClan.Hunter.Melee, BanditCompatibility.GetLegacyItem("Base.HuntingKnife"))
table.insert(BanditClan.Hunter.Melee, BanditCompatibility.GetLegacyItem("Base.Machete"))
table.insert(BanditClan.Hunter.Melee, BanditCompatibility.GetLegacyItem("Base.HandAxe"))

-- available primary weapons
BanditClan.Hunter.Primary = BanditClan.Hunter.Primary or BanditWeapons.Primary

-- available secondary weapons
BanditClan.Hunter.Secondary = BanditClan.Hunter.Secondary or BanditWeapons.Secondary

-- loot table
BanditClan.Hunter.Loot = BanditClan.Hunter.Loot or {}
table.insert(BanditClan.Hunter.Loot, BanditLoot.MakeItem("Base.WristWatch_Left_DigitalBlack", 100))
table.insert(BanditClan.Hunter.Loot, BanditLoot.MakeItem("Base.HandTorch", 100))
table.insert(BanditClan.Hunter.Loot, BanditLoot.MakeItem("Base.FishingRod", 87))
table.insert(BanditClan.Hunter.Loot, BanditLoot.MakeItem("Base.Worm", 90))
table.insert(BanditClan.Hunter.Loot, BanditLoot.MakeItem("Base.Worm", 80))
table.insert(BanditClan.Hunter.Loot, BanditLoot.MakeItem("Base.Worm", 70))
table.insert(BanditClan.Hunter.Loot, BanditLoot.MakeItem("Base.HandTorch", 100))
table.insert(BanditClan.Hunter.Loot, BanditLoot.MakeItem("Base.Battery", 88))
table.insert(BanditClan.Hunter.Loot, BanditLoot.MakeItem("camping.CampfireKit", 33))
table.insert(BanditClan.Hunter.Loot, BanditLoot.MakeItem("Base.Matches", 99))
table.insert(BanditClan.Hunter.Loot, BanditLoot.MakeItem("Base.CampingTentKit", 88))
table.insert(BanditClan.Hunter.Loot, BanditLoot.MakeItem("Base.HuntingKnife", 80))
table.insert(BanditClan.Hunter.Loot, BanditLoot.MakeItem("Base.Twine", 80))
table.insert(BanditClan.Hunter.Loot, BanditLoot.MakeItem("Base.AlcoholBandage", 33))
table.insert(BanditClan.Hunter.Loot, BanditLoot.MakeItem("Base.Disinfectant", 55))
table.insert(BanditClan.Hunter.Loot, BanditLoot.MakeItem("Base.Pills", 2))
table.insert(BanditClan.Hunter.Loot, BanditLoot.MakeItem("Base.Spoon", 40))
table.insert(BanditClan.Hunter.Loot, BanditLoot.MakeItem("Base.Pencil", 35))
table.insert(BanditClan.Hunter.Loot, BanditLoot.MakeItem("Base.Pot", 21))
table.insert(BanditClan.Hunter.Loot, BanditLoot.MakeItem("Base.Scissors", 17))
table.insert(BanditClan.Hunter.Loot, BanditLoot.MakeItem("Base.Toothbrush", 77))
table.insert(BanditClan.Hunter.Loot, BanditLoot.MakeItem("Base.Toothpaste", 77))
table.insert(BanditClan.Hunter.Loot, BanditLoot.MakeItem("Base.Soap2", 66))
table.insert(BanditClan.Hunter.Loot, BanditLoot.MakeItem("Base.TrapStick", 52))
table.insert(BanditClan.Hunter.Loot, BanditLoot.MakeItem("Base.TrapSnare", 62))

if getActivatedMods():contains("MandelaBowAndArrow") then
    table.insert(BanditClan.Hunter.Loot, BanditLoot.MakeItem("MandelaBowAndArrow.MandelaBowWoodLong", 100))
    table.insert(BanditClan.Hunter.Loot, BanditLoot.MakeItem("MandelaBowAndArrow.MandelaArrowBundle", 12))
    table.insert(BanditClan.Hunter.Loot, BanditLoot.MakeItem("MandelaArrowWoodDucttapeIron", 77))
    table.insert(BanditClan.Hunter.Loot, BanditLoot.MakeItem("MandelaArrowWoodDucttapeIron", 66))
    table.insert(BanditClan.Hunter.Loot, BanditLoot.MakeItem("MandelaArrowWoodDucttapeIron", 55))
    table.insert(BanditClan.Hunter.Loot, BanditLoot.MakeItem("MandelaArrowWoodDucttapeIron", 44))
end

table.insert(BanditClan.Hunter.Loot, BanditLoot.MakeItem("Base.WaterBottle", 99))
table.insert(BanditClan.Hunter.Loot, BanditLoot.MakeItem("Base.Whiskey", 22))
table.insert(BanditClan.Hunter.Loot, BanditLoot.MakeItem("Base.DehydratedMeatStick", 34))
table.insert(BanditClan.Hunter.Loot, BanditLoot.MakeItem("Base.Sausage", 34))
table.insert(BanditClan.Hunter.Loot, BanditLoot.MakeItem("Base.Baloney", 31))
table.insert(BanditClan.Hunter.Loot, BanditLoot.MakeItem("Base.Salami", 23))
table.insert(BanditClan.Hunter.Loot, BanditLoot.MakeItem("Base.DeadRabbit", 77))
table.insert(BanditClan.Hunter.Loot, BanditLoot.MakeItem("Base.DeadRabbit", 44))
table.insert(BanditClan.Hunter.Loot, BanditLoot.MakeItem("Base.DeadRabbit", 4))
table.insert(BanditClan.Hunter.Loot, BanditLoot.MakeItem("Base.DeadSquirrel", 66))
table.insert(BanditClan.Hunter.Loot, BanditLoot.MakeItem("Base.DeadSquirrel", 55))
table.insert(BanditClan.Hunter.Loot, BanditLoot.MakeItem("Base.DeadSquirrel", 22))
table.insert(BanditClan.Hunter.Loot, BanditLoot.MakeItem("Base.Trout", 11))
table.insert(BanditClan.Hunter.Loot, BanditLoot.MakeItem("Base.Trout", 11))
table.insert(BanditClan.Hunter.Loot, BanditLoot.MakeItem("Base.Trout", 11))
table.insert(BanditClan.Hunter.Loot, BanditLoot.MakeItem("Base.Perch", 11))
table.insert(BanditClan.Hunter.Loot, BanditLoot.MakeItem("Base.Perch", 11))
table.insert(BanditClan.Hunter.Loot, BanditLoot.MakeItem("Base.Crappie", 11))
table.insert(BanditClan.Hunter.Loot, BanditLoot.MakeItem("Base.Crappie", 11))

table.insert(BanditClan.Hunter.Loot, BanditLoot.MakeItem("Base.Chocolate", 1))
table.insert(BanditClan.Hunter.Loot, BanditLoot.MakeItem("Base.PeanutButter", 1))
table.insert(BanditClan.Hunter.Loot, BanditLoot.MakeItem("Base.Apple", 1))
table.insert(BanditClan.Hunter.Loot, BanditLoot.MakeItem("Base.Cherry", 1))
table.insert(BanditClan.Hunter.Loot, BanditLoot.MakeItem("Base.Grapes", 8))
table.insert(BanditClan.Hunter.Loot, BanditLoot.MakeItem("Base.Onion", 5))
table.insert(BanditClan.Hunter.Loot, BanditLoot.MakeItem("Base.Frog", 19))

table.insert(BanditClan.Hunter.Loot, BanditLoot.MakeItem("Base.HuntingMag1", 5))
table.insert(BanditClan.Hunter.Loot, BanditLoot.MakeItem("Base.HuntingMag2", 5))
table.insert(BanditClan.Hunter.Loot, BanditLoot.MakeItem("Base.HuntingMag3", 5))

-- register this clan for spawn system
BanditCreator.ClanMap = BanditCreator.GroupMap or {}
BanditCreator.ClanMap[10] = BanditClan.Hunter
