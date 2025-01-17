require "BanditWeapons"
BanditClan = BanditClan or {}

BanditClan.Veteran = BanditClan.Veteran or {}

-- The unique id of the clan, ids 1-16 are reserved for waves
BanditClan.Veteran.id = 8

-- Name of the clan
BanditClan.Veteran.name = "Veteran"

-- % chance of a clan member to be a female. Outfit must support it.
BanditClan.Veteran.femaleChance = 0

-- health ranges from 1 - 14. Higher values may produce unexpected results,
BanditClan.Veteran.health = 4

-- if the bandit will eat player's body after death
BanditClan.Veteran.eatBody = false

-- Ranged weapon accuracy multiplayer (1=default)
BanditClan.Veteran.accuracyBoost = 1.5

-- Favorite zones 
BanditClan.Veteran.favoriteZones = {}
BanditClan.Veteran.avoidZones = {}

-- available outfits
BanditClan.Veteran.Outfits = BanditClan.Veteran.Outfits or {}
table.insert(BanditClan.Veteran.Outfits, "Veteran")
table.insert(BanditClan.Veteran.Outfits, "CostumeBloodFirst")
table.insert(BanditClan.Veteran.Outfits, "ArmyInstructor")


-- available melee weapons
BanditClan.Veteran.Melee = BanditClan.Veteran.Melee or {}
table.insert(BanditClan.Veteran.Melee, "Base.Machete")
table.insert(BanditClan.Veteran.Melee, "Base.HuntingKnife")

-- available primary weapons
BanditClan.Veteran.Primary = BanditClan.Veteran.Primary or BanditWeapons.Primary

-- available secondary weapons
BanditClan.Veteran.Secondary = BanditClan.Veteran.Secondary or BanditWeapons.Secondary

-- loot table
BanditClan.Veteran.Loot = BanditClan.Veteran.Loot or {}

table.insert(BanditClan.Veteran.Loot, BanditLoot.MakeItem("Base.HandTorch", 100))
table.insert(BanditClan.Veteran.Loot, BanditLoot.MakeItem("Base.Necklace_DogTag", 100))
table.insert(BanditClan.Veteran.Loot, BanditLoot.MakeItem("Base.Battery", 88))
table.insert(BanditClan.Veteran.Loot, BanditLoot.MakeItem("Base.Lighter", 99))
table.insert(BanditClan.Veteran.Loot, BanditLoot.MakeItem("Base.AlcoholBandage", 33))
table.insert(BanditClan.Veteran.Loot, BanditLoot.MakeItem("Base.AlcoholBandage", 33))
table.insert(BanditClan.Veteran.Loot, BanditLoot.MakeItem("Base.Disinfectant", 55))
table.insert(BanditClan.Veteran.Loot, BanditLoot.MakeItem("Base.Pills", 2))
table.insert(BanditClan.Veteran.Loot, BanditLoot.MakeItem("Base.TinOpener", 11))
table.insert(BanditClan.Veteran.Loot, BanditLoot.MakeItem("Base.Spoon", 40))
table.insert(BanditClan.Veteran.Loot, BanditLoot.MakeItem("Base.Pencil", 35))
table.insert(BanditClan.Veteran.Loot, BanditLoot.MakeItem("Base.Toothbrush", 33))
table.insert(BanditClan.Veteran.Loot, BanditLoot.MakeItem("Base.Toothpaste", 33))
table.insert(BanditClan.Veteran.Loot, BanditLoot.MakeItem("Base.ToiletPaper", 66))

table.insert(BanditClan.Veteran.Loot, BanditLoot.MakeItem("Base.Soap", 66))
table.insert(BanditClan.Veteran.Loot, BanditLoot.MakeItem("Base.WaterBottle", 99))
table.insert(BanditClan.Veteran.Loot, BanditLoot.MakeItem("Base.Whiskey", 44))
table.insert(BanditClan.Veteran.Loot, BanditLoot.MakeItem("Base.DehydratedMeatStick", 12))
table.insert(BanditClan.Veteran.Loot, BanditLoot.MakeItem("Base.BeefJerky", 18))
table.insert(BanditClan.Veteran.Loot, BanditLoot.MakeItem("Base.TinnedBeans", 1))
table.insert(BanditClan.Veteran.Loot, BanditLoot.MakeItem("Base.CannedChili", 3))
table.insert(BanditClan.Veteran.Loot, BanditLoot.MakeItem("Base.CannedCorn", 3))
table.insert(BanditClan.Veteran.Loot, BanditLoot.MakeItem("Base.CannedCornedBeef", 3))
table.insert(BanditClan.Veteran.Loot, BanditLoot.MakeItem("Base.CannedFruitCocktail", 2))
table.insert(BanditClan.Veteran.Loot, BanditLoot.MakeItem("Base.CannedMushroomSoup", 2))
table.insert(BanditClan.Veteran.Loot, BanditLoot.MakeItem("Base.CannedPeas", 3))
table.insert(BanditClan.Veteran.Loot, BanditLoot.MakeItem("Base.CannedPotato2", 3))
table.insert(BanditClan.Veteran.Loot, BanditLoot.MakeItem("Base.CannedSardines", 3))
table.insert(BanditClan.Veteran.Loot, BanditLoot.MakeItem("Base.TinnedSoup", 3))
table.insert(BanditClan.Veteran.Loot, BanditLoot.MakeItem("Base.CannedBolognese", 3))

if getActivatedMods():contains("ExpandedHelicopterEvents") then
    table.insert(BanditClan.Veteran.Loot, BanditLoot.MakeItem("Base.MealReadytoEatEHE", 80))
    table.insert(BanditClan.Veteran.Loot, BanditLoot.MakeItem("Base.MealReadytoEatEHE", 70))
    table.insert(BanditClan.Veteran.Loot, BanditLoot.MakeItem("Base.MealReadytoEatEHE", 10))
elseif getActivatedMods():contains("MREM") then
    table.insert(BanditClan.Veteran.Loot, BanditLoot.MakeItem("MREM.MRE", 80))
    table.insert(BanditClan.Veteran.Loot, BanditLoot.MakeItem("MREM.MRE", 70))
    table.insert(BanditClan.Veteran.Loot, BanditLoot.MakeItem("MREM.MRE", 10))
else
    table.insert(BanditClan.Veteran.Loot, BanditLoot.MakeItem("Base.CannedCornedBeef", 80))
    table.insert(BanditClan.Veteran.Loot, BanditLoot.MakeItem("Base.CannedCornedBeef", 70))
    table.insert(BanditClan.Veteran.Loot, BanditLoot.MakeItem("Base.CannedCornedBeef", 10))
end

if getActivatedMods():contains("thebible") then
    table.insert(BanditClan.Veteran.Loot, BanditLoot.MakeItem("BIBLE.TheBible", 50))
end

-- register this clan for spawn system
BanditCreator.ClanMap = BanditCreator.GroupMap or {}
BanditCreator.ClanMap[8] = BanditClan.Veteran
