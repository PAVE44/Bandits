BanditClan = BanditClan or {}

BanditClan.Scientist = BanditClan.Scientist or {}

-- The unique id of the clan, ids 1-16 are reserved for waves
BanditClan.Scientist.id = 12

-- Name of the clan
BanditClan.Scientist.name = "Scientist"

-- % chance of a clan member to be a female. Outfit must support it.
BanditClan.Scientist.femaleChance = 60

-- health ranges from 1 - 14. Higher values may produce unexpected results,
BanditClan.Scientist.health = 4

-- if the bandit will eat player's body after death
BanditClan.Scientist.eatBody = false

-- Ranged weapon accuracy multiplayer (1=default)
BanditClan.Scientist.accuracyBoost = 0.8

-- Favorite zones 
BanditClan.Scientist.favoriteZones = {}
BanditClan.Scientist.avoidZones = {"Forest", "DeepForest"}

-- available outfits
BanditClan.Scientist.Outfits = BanditClan.Scientist.Outfits or {}
table.insert(BanditClan.Scientist.Outfits, "HazardSuit")

if getActivatedMods():contains("Authentic Z - Current") then
    table.insert(BanditClan.Scientist.Outfits, "AuthenticHazardSuit")
    table.insert(BanditClan.Scientist.Outfits, "AuthenticCEDAHazmatBlue")
    table.insert(BanditClan.Scientist.Outfits, "AuthenticCEDAHazmatGreen")
    table.insert(BanditClan.Scientist.Outfits, "AuthenticNBHHazmat")
    table.insert(BanditClan.Scientist.Outfits, "AuthenticSurvivorHazardSuit")
end

-- available melee weapons
BanditClan.Scientist.Melee = BanditClan.Scientist.Melee or {}
table.insert(BanditClan.Scientist.Melee, BanditCompatibility.GetLegacyItem("Base.Scalpel"))

-- available primary weapons
BanditClan.Scientist.Primary = BanditClan.Scientist.Primary or BanditWeapons.Primary

-- available secondary weapons
BanditClan.Scientist.Secondary = BanditClan.Scientist.Secondary or BanditWeapons.Secondary

-- loot table
BanditClan.Scientist.Loot = BanditClan.Scientist.Loot or {}

table.insert(BanditClan.Scientist.Loot, BanditLoot.MakeItem("Base.HandTorch", 100))
table.insert(BanditClan.Scientist.Loot, BanditLoot.MakeItem("Base.Battery", 88))
table.insert(BanditClan.Scientist.Loot, BanditLoot.MakeItem("Base.AlcoholBandage", 33))
table.insert(BanditClan.Scientist.Loot, BanditLoot.MakeItem("Base.AlcoholBandage", 33))
table.insert(BanditClan.Scientist.Loot, BanditLoot.MakeItem("Base.AlcoholBandage", 33))
table.insert(BanditClan.Scientist.Loot, BanditLoot.MakeItem("Base.Disinfectant", 99))
table.insert(BanditClan.Scientist.Loot, BanditLoot.MakeItem("Base.Pills", 77))
table.insert(BanditClan.Scientist.Loot, BanditLoot.MakeItem("Base.Pencil", 35))
table.insert(BanditClan.Scientist.Loot, BanditLoot.MakeItem("Base.SutureNeedle", 35))
table.insert(BanditClan.Scientist.Loot, BanditLoot.MakeItem("Base.SutureNeedleHolder", 35))
table.insert(BanditClan.Scientist.Loot, BanditLoot.MakeItem("Base.Tweezers", 11))
table.insert(BanditClan.Scientist.Loot, BanditLoot.MakeItem("Base.Toothbrush", 33))
table.insert(BanditClan.Scientist.Loot, BanditLoot.MakeItem("Base.Toothpaste", 33))
table.insert(BanditClan.Scientist.Loot, BanditLoot.MakeItem("Base.CottonBalls", 33))
table.insert(BanditClan.Scientist.Loot, BanditLoot.MakeItem("Base.Soap", 22))
table.insert(BanditClan.Scientist.Loot, BanditLoot.MakeItem("Base.CleaningLiquid", 22))
table.insert(BanditClan.Scientist.Loot, BanditLoot.MakeItem("Base.Bleach", 22))
table.insert(BanditClan.Scientist.Loot, BanditLoot.MakeItem("Base.WaterBottle", 99))

if getActivatedMods():contains("ExpandedHelicopterEvents") then
    table.insert(BanditClan.Scientist.Loot, BanditLoot.MakeItem("Base.MealReadytoEatEHE", 80))
    table.insert(BanditClan.Scientist.Loot, BanditLoot.MakeItem("Base.MealReadytoEatEHE", 70))
    table.insert(BanditClan.Scientist.Loot, BanditLoot.MakeItem("Base.MealReadytoEatEHE", 10))
end

if getActivatedMods():contains("VaccinDrReapersMP") or getActivatedMods():contains("VaccinDrReapers") then
    table.insert(BanditClan.Scientist.Loot, BanditLoot.MakeItem("LabItems.LabTestResultNegative", 100))
    table.insert(BanditClan.Scientist.Loot, BanditLoot.MakeItem("LabItems.ChAmmonia", 15))
    table.insert(BanditClan.Scientist.Loot, BanditLoot.MakeItem("LabItems.ChSulfuricAcidCan", 15))
    table.insert(BanditClan.Scientist.Loot, BanditLoot.MakeItem("LabItems.ChHydrochloricAcidCan", 15))
    table.insert(BanditClan.Scientist.Loot, BanditLoot.MakeItem("LabItems.ChSodiumHydroxideBag", 15))
    table.insert(BanditClan.Scientist.Loot, BanditLoot.MakeItem("LabItems.LabSyringe", 99))
    table.insert(BanditClan.Scientist.Loot, BanditLoot.MakeItem("LabItems.LabSyringeUsed", 99))
    table.insert(BanditClan.Scientist.Loot, BanditLoot.MakeItem("LabItems.CmpSyringeWithPlainVaccine", 4))
    table.insert(BanditClan.Scientist.Loot, BanditLoot.MakeItem("LabItems.CmpSyringeReusableWithPlainVaccine", 4))
    table.insert(BanditClan.Scientist.Loot, BanditLoot.MakeItem("LabItems.CmpSyringeWithQualityVaccine", 3))
    table.insert(BanditClan.Scientist.Loot, BanditLoot.MakeItem("LabItems.CmpSyringeReusableWithQualityVaccine", 3))
    table.insert(BanditClan.Scientist.Loot, BanditLoot.MakeItem("LabItems.CmpSyringeWithAdvancedVaccine", 2))
    table.insert(BanditClan.Scientist.Loot, BanditLoot.MakeItem("LabItems.CmpSyringeReusableWithAdvancedVaccine", 2))
    table.insert(BanditClan.Scientist.Loot, BanditLoot.MakeItem("LabItems.CmpSyringeWithCure", 1))
    table.insert(BanditClan.Scientist.Loot, BanditLoot.MakeItem("LabItems.CmpSyringeReusableWithCure", 1))
end

-- register this clan for spawn system
BanditCreator.ClanMap = BanditCreator.GroupMap or {}
BanditCreator.ClanMap[12] = BanditClan.Scientist
