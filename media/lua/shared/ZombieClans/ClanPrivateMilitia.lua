BanditClan = BanditClan or {}

BanditClan.PrivateMilitia = BanditClan.PrivateMilitia or {}

-- The unique id of the clan, ids 1-16 are reserved for waves
BanditClan.PrivateMilitia.id = 14

-- Name of the clan
BanditClan.PrivateMilitia.name = "Private Militia"

-- % chance of a clan member to be a female. Outfit must support it.
BanditClan.PrivateMilitia.femaleChance = 0

-- health ranges from 1 - 14. Higher values may produce unexpected results,
BanditClan.PrivateMilitia.health = 6

-- if the bandit will eat player's body after death
BanditClan.PrivateMilitia.eatBody = false

-- Ranged weapon accuracy multiplayer (1=default)
BanditClan.PrivateMilitia.accuracyBoost = 1.1

-- Favorite zones 
BanditClan.PrivateMilitia.favoriteZones = {"Nav"}
BanditClan.PrivateMilitia.avoidZones = {"Forest", "DeepForest"}

-- available outfits
BanditClan.PrivateMilitia.Outfits = BanditClan.PrivateMilitia.Outfits or {}
if getActivatedMods():contains("USMilitaryPack") then
    table.insert(BanditClan.PrivateMilitia.Outfits, "INFANTRY_USMP1")
    table.insert(BanditClan.PrivateMilitia.Outfits, "INFANTRY_USMP2")
elseif getActivatedMods():contains("Brita_2") then
    table.insert(BanditClan.PrivateMilitia.Outfits, "Brita_Gorka")
    table.insert(BanditClan.PrivateMilitia.Outfits, "Brita_Hunter_2")
else
    table.insert(BanditClan.PrivateMilitia.Outfits, "PrivateMilitia")
    table.insert(BanditClan.PrivateMilitia.Outfits, "Camper")
end

-- available melee weapons
BanditClan.PrivateMilitia.Melee = BanditClan.PrivateMilitia.Melee or {}
table.insert(BanditClan.PrivateMilitia.Melee, "Base.Machete")
table.insert(BanditClan.PrivateMilitia.Melee, "Base.HuntingKnife")

-- available primary weapons
BanditClan.PrivateMilitia.Primary = BanditClan.PrivateMilitia.Primary or BanditWeapons.Primary

-- available secondary weapons
BanditClan.PrivateMilitia.Secondary = BanditClan.PrivateMilitia.Secondary or BanditWeapons.Secondary

-- loot table
BanditClan.PrivateMilitia.Loot = BanditClan.PrivateMilitia.Loot or {}

table.insert(BanditClan.PrivateMilitia.Loot, BanditLoot.MakeItem("Base.Necklace_DogTag", 100))
table.insert(BanditClan.PrivateMilitia.Loot, BanditLoot.MakeItem("Base.HandTorch", 100))
table.insert(BanditClan.PrivateMilitia.Loot, BanditLoot.MakeItem("Base.Battery", 88))
table.insert(BanditClan.PrivateMilitia.Loot, BanditLoot.MakeItem("Base.Battery", 88))
table.insert(BanditClan.PrivateMilitia.Loot, BanditLoot.MakeItem("Radio.WalkieTalkieMakeShift", 99))
table.insert(BanditClan.PrivateMilitia.Loot, BanditLoot.MakeItem("Base.AlcoholBandage", 33))
table.insert(BanditClan.PrivateMilitia.Loot, BanditLoot.MakeItem("Base.AlcoholBandage", 33))
table.insert(BanditClan.PrivateMilitia.Loot, BanditLoot.MakeItem("Base.Disinfectant", 99))
table.insert(BanditClan.PrivateMilitia.Loot, BanditLoot.MakeItem("Base.Pills", 77))
table.insert(BanditClan.PrivateMilitia.Loot, BanditLoot.MakeItem("Base.Pencil", 35))
table.insert(BanditClan.PrivateMilitia.Loot, BanditLoot.MakeItem("Base.SutureNeedle", 35))
table.insert(BanditClan.PrivateMilitia.Loot, BanditLoot.MakeItem("Base.SutureNeedleHolder", 35))
table.insert(BanditClan.PrivateMilitia.Loot, BanditLoot.MakeItem("Base.Tweezers", 11))
table.insert(BanditClan.PrivateMilitia.Loot, BanditLoot.MakeItem("Base.Toothbrush", 33))
table.insert(BanditClan.PrivateMilitia.Loot, BanditLoot.MakeItem("Base.Toothpaste", 33))
table.insert(BanditClan.PrivateMilitia.Loot, BanditLoot.MakeItem("Base.ToiletPaper", 66))

table.insert(BanditClan.PrivateMilitia.Loot, BanditLoot.MakeItem("Base.WaterBottleFull", 99))
table.insert(BanditClan.PrivateMilitia.Loot, BanditLoot.MakeItem("Base.Gum", 14))
table.insert(BanditClan.PrivateMilitia.Loot, BanditLoot.MakeItem("Base.DehydratedMeatStick", 44))
table.insert(BanditClan.PrivateMilitia.Loot, BanditLoot.MakeItem("Base.DehydratedMeatStick", 44))
table.insert(BanditClan.PrivateMilitia.Loot, BanditLoot.MakeItem("Base.ToiletPaper", 66))
table.insert(BanditClan.PrivateMilitia.Loot, BanditLoot.MakeItem("Base.Coffee2", 22))
table.insert(BanditClan.PrivateMilitia.Loot, BanditLoot.MakeItem("Base.Teabag2", 55))
table.insert(BanditClan.PrivateMilitia.Loot, BanditLoot.MakeItem("Base.MugWhite", 22))
table.insert(BanditClan.PrivateMilitia.Loot, BanditLoot.MakeItem("Base.HuntingKnife", 22))
table.insert(BanditClan.PrivateMilitia.Loot, BanditLoot.MakeItem("Base.Fork", 77))
table.insert(BanditClan.PrivateMilitia.Loot, BanditLoot.MakeItem("Base.Spoon", 77))
table.insert(BanditClan.PrivateMilitia.Loot, BanditLoot.MakeItem("Base.SugarPacket", 66))
table.insert(BanditClan.PrivateMilitia.Loot, BanditLoot.MakeItem("Base.SugarPacket", 66))
table.insert(BanditClan.PrivateMilitia.Loot, BanditLoot.MakeItem("Base.Chocolate", 33))

if getActivatedMods():contains("ExpandedHelicopterEvents") then
    table.insert(BanditClan.PrivateMilitia.Loot, BanditLoot.MakeItem("Base.MealReadytoEatEHE", 80))
    table.insert(BanditClan.PrivateMilitia.Loot, BanditLoot.MakeItem("Base.MealReadytoEatEHE", 80))
    table.insert(BanditClan.PrivateMilitia.Loot, BanditLoot.MakeItem("Base.MealReadytoEatEHE", 70))
    table.insert(BanditClan.PrivateMilitia.Loot, BanditLoot.MakeItem("Base.MealReadytoEatEHE", 10))
elseif getActivatedMods():contains("MREM") then
    table.insert(BanditClan.PrivateMilitia.Loot, BanditLoot.MakeItem("MREM.MRE", 60))
    table.insert(BanditClan.PrivateMilitia.Loot, BanditLoot.MakeItem("MREM.MRE", 60))
    table.insert(BanditClan.PrivateMilitia.Loot, BanditLoot.MakeItem("MREM.MRE", 50))
    table.insert(BanditClan.PrivateMilitia.Loot, BanditLoot.MakeItem("MREM.MRE", 10))
    table.insert(BanditClan.PrivateMilitia.Loot, BanditLoot.MakeItem("MREM.MREBox", 10))
else
    table.insert(BanditClan.PrivateMilitia.Loot, BanditLoot.MakeItem("Base.CannedCornedBeef", 80))
    table.insert(BanditClan.PrivateMilitia.Loot, BanditLoot.MakeItem("Base.CannedCornedBeef", 80))
    table.insert(BanditClan.PrivateMilitia.Loot, BanditLoot.MakeItem("Base.CannedCornedBeef", 70))
    table.insert(BanditClan.PrivateMilitia.Loot, BanditLoot.MakeItem("Base.CannedCornedBeef", 10))
end

for i=1, 37 do
    table.insert(BanditClan.PrivateMilitia.Loot, BanditLoot.MakeItem("Base.Money", 66))
end

-- register this clan for spawn system
BanditCreator.ClanMap = BanditCreator.GroupMap or {}
BanditCreator.ClanMap[14] = BanditClan.PrivateMilitia
