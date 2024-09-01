BanditClan = BanditClan or {}

BanditClan.NewOrder = BanditClan.NewOrder or {}

-- The unique id of the clan, ids 1-16 are reserved for waves
BanditClan.NewOrder.id = 16

-- Name of the clan
BanditClan.NewOrder.name = "New Order"

-- % chance of a clan member to be a female. Outfit must support it.
BanditClan.NewOrder.femaleChance = 0

-- health ranges from 1 - 14. Higher values may produce unexpected results,
BanditClan.NewOrder.health = 6

-- if the bandit will eat player's body after death
BanditClan.NewOrder.eatBody = false

-- Ranged weapon accuracy multiplayer (1=default)
BanditClan.NewOrder.accuracyBoost = 1.2

-- Favorite zones 
BanditClan.NewOrder.favoriteZones = {}
BanditClan.NewOrder.avoidZones = {}

-- available outfits
BanditClan.NewOrder.Outfits = BanditClan.NewOrder.Outfits or {}
if getActivatedMods():contains("KATTAJ1_Military") then
    table.insert(BanditClan.NewOrder.Outfits, "KATTAJ1_Army_Black_Patriot")
    table.insert(BanditClan.NewOrder.Outfits, "KATTAJ1_Army_Black_Defender")
    table.insert(BanditClan.NewOrder.Outfits, "KATTAJ1_Army_Black_Vanguard")
    table.insert(BanditClan.NewOrder.Outfits, "KATTAJ1_Army_Green_Patriot")
    table.insert(BanditClan.NewOrder.Outfits, "KATTAJ1_Army_Green_Defender")
    table.insert(BanditClan.NewOrder.Outfits, "KATTAJ1_Army_Green_Vanguard")
else
    table.insert(BanditClan.NewOrder.Outfits, "ArmyCamoGreen")
    table.insert(BanditClan.NewOrder.Outfits, "Ghillie")
end

-- available melee weapons
BanditClan.NewOrder.Melee = BanditClan.NewOrder.Melee or {}
table.insert(BanditClan.NewOrder.Melee, "Base.HuntingKnife")

-- available primary weapons
BanditClan.NewOrder.Primary = BanditClan.NewOrder.Primary or BanditWeapons.Primary

-- available secondary weapons
BanditClan.NewOrder.Secondary = BanditClan.NewOrder.Secondary or BanditWeapons.Secondary

-- loot table
BanditClan.NewOrder.Loot = BanditClan.NewOrder.Loot or {}

table.insert(BanditClan.NewOrder.Loot, BanditLoot.MakeItem("Base.Necklace_DogTag", 100))
table.insert(BanditClan.NewOrder.Loot, BanditLoot.MakeItem("Base.HandTorch", 100))
table.insert(BanditClan.NewOrder.Loot, BanditLoot.MakeItem("Base.Battery", 88))
table.insert(BanditClan.NewOrder.Loot, BanditLoot.MakeItem("Base.Battery", 88))
table.insert(BanditClan.NewOrder.Loot, BanditLoot.MakeItem("Base.Battery", 88))
table.insert(BanditClan.NewOrder.Loot, BanditLoot.MakeItem("Radio.WalkieTalkieMakeShift", 99))
table.insert(BanditClan.NewOrder.Loot, BanditLoot.MakeItem("Base.AlcoholBandage", 33))
table.insert(BanditClan.NewOrder.Loot, BanditLoot.MakeItem("Base.AlcoholBandage", 33))
table.insert(BanditClan.NewOrder.Loot, BanditLoot.MakeItem("Base.AlcoholBandage", 33))
table.insert(BanditClan.NewOrder.Loot, BanditLoot.MakeItem("Base.Disinfectant", 99))
table.insert(BanditClan.NewOrder.Loot, BanditLoot.MakeItem("Base.Pills", 77))
table.insert(BanditClan.NewOrder.Loot, BanditLoot.MakeItem("Base.Pencil", 35))
table.insert(BanditClan.NewOrder.Loot, BanditLoot.MakeItem("Base.SutureNeedle", 35))
table.insert(BanditClan.NewOrder.Loot, BanditLoot.MakeItem("Base.SutureNeedle", 35))
table.insert(BanditClan.NewOrder.Loot, BanditLoot.MakeItem("Base.SutureNeedleHolder", 35))
table.insert(BanditClan.NewOrder.Loot, BanditLoot.MakeItem("Base.Tweezers", 11))
table.insert(BanditClan.NewOrder.Loot, BanditLoot.MakeItem("Base.Toothbrush", 33))
table.insert(BanditClan.NewOrder.Loot, BanditLoot.MakeItem("Base.Toothpaste", 33))
table.insert(BanditClan.NewOrder.Loot, BanditLoot.MakeItem("Base.ToiletPaper", 66))

table.insert(BanditClan.NewOrder.Loot, BanditLoot.MakeItem("Base.WaterBottleFull", 99))
table.insert(BanditClan.NewOrder.Loot, BanditLoot.MakeItem("Base.Gum", 14))
table.insert(BanditClan.NewOrder.Loot, BanditLoot.MakeItem("Base.DehydratedMeatStick", 44))
table.insert(BanditClan.NewOrder.Loot, BanditLoot.MakeItem("Base.DehydratedMeatStick", 44))
table.insert(BanditClan.NewOrder.Loot, BanditLoot.MakeItem("Base.ToiletPaper", 66))
table.insert(BanditClan.NewOrder.Loot, BanditLoot.MakeItem("Base.Coffee2", 33))
table.insert(BanditClan.NewOrder.Loot, BanditLoot.MakeItem("Base.Teabag2", 66))
table.insert(BanditClan.NewOrder.Loot, BanditLoot.MakeItem("Base.MugWhite", 22))
table.insert(BanditClan.NewOrder.Loot, BanditLoot.MakeItem("Base.HuntingKnife", 22))
table.insert(BanditClan.NewOrder.Loot, BanditLoot.MakeItem("Base.Fork", 77))
table.insert(BanditClan.NewOrder.Loot, BanditLoot.MakeItem("Base.Spoon", 77))
table.insert(BanditClan.NewOrder.Loot, BanditLoot.MakeItem("Base.SugarPacket", 66))
table.insert(BanditClan.NewOrder.Loot, BanditLoot.MakeItem("Base.SugarPacket", 66))
table.insert(BanditClan.NewOrder.Loot, BanditLoot.MakeItem("Base.Chocolate", 33))

if getActivatedMods():contains("ExpandedHelicopterEvents") then
    table.insert(BanditClan.NewOrder.Loot, BanditLoot.MakeItem("Base.MealReadytoEatEHE", 80))
    table.insert(BanditClan.NewOrder.Loot, BanditLoot.MakeItem("Base.MealReadytoEatEHE", 80))
    table.insert(BanditClan.NewOrder.Loot, BanditLoot.MakeItem("Base.MealReadytoEatEHE", 70))
    table.insert(BanditClan.NewOrder.Loot, BanditLoot.MakeItem("Base.MealReadytoEatEHE", 10))
elseif getActivatedMods():contains("MREM") then
    table.insert(BanditClan.NewOrder.Loot, BanditLoot.MakeItem("MREM.MRE", 60))
    table.insert(BanditClan.NewOrder.Loot, BanditLoot.MakeItem("MREM.MRE", 60))
    table.insert(BanditClan.NewOrder.Loot, BanditLoot.MakeItem("MREM.MRE", 50))
    table.insert(BanditClan.NewOrder.Loot, BanditLoot.MakeItem("MREM.MRE", 10))
    table.insert(BanditClan.NewOrder.Loot, BanditLoot.MakeItem("MREM.MREBox", 10))
else
    table.insert(BanditClan.NewOrder.Loot, BanditLoot.MakeItem("Base.CannedCornedBeef", 80))
    table.insert(BanditClan.NewOrder.Loot, BanditLoot.MakeItem("Base.CannedCornedBeef", 80))
    table.insert(BanditClan.NewOrder.Loot, BanditLoot.MakeItem("Base.CannedCornedBeef", 70))
    table.insert(BanditClan.NewOrder.Loot, BanditLoot.MakeItem("Base.CannedCornedBeef", 10))
end

-- register this clan for spawn system
BanditCreator.ClanMap = BanditCreator.GroupMap or {}
BanditCreator.ClanMap[16] = BanditClan.NewOrder
