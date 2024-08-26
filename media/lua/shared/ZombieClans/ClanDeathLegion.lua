BanditClan = BanditClan or {}

BanditClan.DeathLegion = BanditClan.DeathLegion or {}

-- The unique id of the clan, ids 1-16 are reserved for waves
BanditClan.DeathLegion.id = 15

-- Name of the clan
BanditClan.DeathLegion.name = "Death Legion"

-- % chance of a clan member to be a female. Outfit must support it.
BanditClan.DeathLegion.femaleChance = 0

-- health ranges from 1 - 14. Higher values may produce unexpected results,
BanditClan.DeathLegion.health = 7

-- if the bandit will eat player's body after death
BanditClan.DeathLegion.eatBody = false

-- available outfits
BanditClan.DeathLegion.Outfits = BanditClan.DeathLegion.Outfits or {}
if getActivatedMods():contains("Insurgent") then
    table.insert(BanditClan.DeathLegion.Outfits, "InsurgentRifleman")
    table.insert(BanditClan.DeathLegion.Outfits, "InsurgentAssault")
    table.insert(BanditClan.DeathLegion.Outfits, "InsurgentOfficer")
else
    table.insert(BanditClan.DeathLegion.Outfits, "ArmyCamoDesert")
end

-- available melee weapons
BanditClan.DeathLegion.Melee = BanditClan.DeathLegion.Melee or {}
table.insert(BanditClan.DeathLegion.Melee, "Base.Machete")
table.insert(BanditClan.DeathLegion.Melee, "Base.HuntingKnife")

-- available primary weapons
BanditClan.DeathLegion.Primary = BanditClan.DeathLegion.Primary or BanditWeapons.Primary

-- available secondary weapons
BanditClan.DeathLegion.Secondary = BanditClan.DeathLegion.Secondary or BanditWeapons.Secondary

-- loot table
BanditClan.DeathLegion.Loot = BanditClan.DeathLegion.Loot or {}

table.insert(BanditClan.DeathLegion.Loot, BanditLoot.MakeItem("Base.Necklace_DogTag", 100))
table.insert(BanditClan.DeathLegion.Loot, BanditLoot.MakeItem("Base.HandTorch", 100))
table.insert(BanditClan.DeathLegion.Loot, BanditLoot.MakeItem("Base.Battery", 88))
table.insert(BanditClan.DeathLegion.Loot, BanditLoot.MakeItem("Base.Battery", 88))
table.insert(BanditClan.DeathLegion.Loot, BanditLoot.MakeItem("Base.Battery", 88))
table.insert(BanditClan.DeathLegion.Loot, BanditLoot.MakeItem("Radio.WalkieTalkieMakeShift", 99))
table.insert(BanditClan.DeathLegion.Loot, BanditLoot.MakeItem("Base.AlcoholBandage", 33))
table.insert(BanditClan.DeathLegion.Loot, BanditLoot.MakeItem("Base.AlcoholBandage", 33))
table.insert(BanditClan.DeathLegion.Loot, BanditLoot.MakeItem("Base.AlcoholBandage", 33))
table.insert(BanditClan.DeathLegion.Loot, BanditLoot.MakeItem("Base.Disinfectant", 99))
table.insert(BanditClan.DeathLegion.Loot, BanditLoot.MakeItem("Base.Pills", 77))
table.insert(BanditClan.DeathLegion.Loot, BanditLoot.MakeItem("Base.Pencil", 35))
table.insert(BanditClan.DeathLegion.Loot, BanditLoot.MakeItem("Base.SutureNeedle", 35))
table.insert(BanditClan.DeathLegion.Loot, BanditLoot.MakeItem("Base.SutureNeedle", 35))
table.insert(BanditClan.DeathLegion.Loot, BanditLoot.MakeItem("Base.SutureNeedleHolder", 35))
table.insert(BanditClan.DeathLegion.Loot, BanditLoot.MakeItem("Base.Tweezers", 11))
table.insert(BanditClan.DeathLegion.Loot, BanditLoot.MakeItem("Base.Toothbrush", 33))
table.insert(BanditClan.DeathLegion.Loot, BanditLoot.MakeItem("Base.Toothpaste", 33))
table.insert(BanditClan.DeathLegion.Loot, BanditLoot.MakeItem("Base.ToiletPaper", 66))

table.insert(BanditClan.DeathLegion.Loot, BanditLoot.MakeItem("Base.WaterBottleFull", 99))
table.insert(BanditClan.DeathLegion.Loot, BanditLoot.MakeItem("Base.Gum", 14))
table.insert(BanditClan.DeathLegion.Loot, BanditLoot.MakeItem("Base.DehydratedMeatStick", 44))
table.insert(BanditClan.DeathLegion.Loot, BanditLoot.MakeItem("Base.DehydratedMeatStick", 44))
table.insert(BanditClan.DeathLegion.Loot, BanditLoot.MakeItem("Base.ToiletPaper", 66))
table.insert(BanditClan.DeathLegion.Loot, BanditLoot.MakeItem("Base.Coffee2", 33))
table.insert(BanditClan.DeathLegion.Loot, BanditLoot.MakeItem("Base.Teabag2", 66))
table.insert(BanditClan.DeathLegion.Loot, BanditLoot.MakeItem("Base.MugWhite", 22))
table.insert(BanditClan.DeathLegion.Loot, BanditLoot.MakeItem("Base.HuntingKnife", 22))
table.insert(BanditClan.DeathLegion.Loot, BanditLoot.MakeItem("Base.Fork", 77))
table.insert(BanditClan.DeathLegion.Loot, BanditLoot.MakeItem("Base.Spoon", 77))
table.insert(BanditClan.DeathLegion.Loot, BanditLoot.MakeItem("Base.SugarPacket", 66))
table.insert(BanditClan.DeathLegion.Loot, BanditLoot.MakeItem("Base.SugarPacket", 66))
table.insert(BanditClan.DeathLegion.Loot, BanditLoot.MakeItem("Base.Chocolate", 33))

if getActivatedMods():contains("ExpandedHelicopterEvents") then
    table.insert(BanditClan.DeathLegion.Loot, BanditLoot.MakeItem("Base.MealReadytoEatEHE", 80))
    table.insert(BanditClan.DeathLegion.Loot, BanditLoot.MakeItem("Base.MealReadytoEatEHE", 80))
    table.insert(BanditClan.DeathLegion.Loot, BanditLoot.MakeItem("Base.MealReadytoEatEHE", 70))
    table.insert(BanditClan.DeathLegion.Loot, BanditLoot.MakeItem("Base.MealReadytoEatEHE", 10))
elseif getActivatedMods():contains("MREM") then
    table.insert(BanditClan.DeathLegion.Loot, BanditLoot.MakeItem("MREM.MRE", 60))
    table.insert(BanditClan.DeathLegion.Loot, BanditLoot.MakeItem("MREM.MRE", 60))
    table.insert(BanditClan.DeathLegion.Loot, BanditLoot.MakeItem("MREM.MRE", 50))
    table.insert(BanditClan.DeathLegion.Loot, BanditLoot.MakeItem("MREM.MRE", 10))
    table.insert(BanditClan.DeathLegion.Loot, BanditLoot.MakeItem("MREM.MREBox", 10))
else
    table.insert(BanditClan.DeathLegion.Loot, BanditLoot.MakeItem("Base.CannedCornedBeef", 80))
    table.insert(BanditClan.DeathLegion.Loot, BanditLoot.MakeItem("Base.CannedCornedBeef", 80))
    table.insert(BanditClan.DeathLegion.Loot, BanditLoot.MakeItem("Base.CannedCornedBeef", 70))
    table.insert(BanditClan.DeathLegion.Loot, BanditLoot.MakeItem("Base.CannedCornedBeef", 10))
end

-- register this clan for spawn system
BanditCreator.ClanMap = BanditCreator.GroupMap or {}
BanditCreator.ClanMap[15] = BanditClan.DeathLegion
