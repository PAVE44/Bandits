BanditClan = BanditClan or {}

BanditClan.Psychopath = BanditClan.Psychopath or {}

-- The unique id of the clan, ids 1-16 are reserved for waves
BanditClan.Psychopath.id = 2

-- Name of the clan
BanditClan.Psychopath.name = "Psychopath"

-- % chance of a clan member to be a female. Outfit must support it.
BanditClan.Psychopath.femaleChance = 0

-- health ranges from 1 - 14. Higher values may produce unexpected results,
BanditClan.Psychopath.health = 2

-- if the bandit will eat player's body after death
BanditClan.Psychopath.eatBody = false

-- Ranged weapon accuracy multiplayer (1=default)
BanditClan.Psychopath.accuracyBoost = 0.7

-- Favorite zones 
BanditClan.Psychopath.favoriteZones = {}
BanditClan.Psychopath.avoidZones = {"Vegitation", "Forest", "DeepForest"}

-- available outfits
BanditClan.Psychopath.Outfits = BanditClan.Psychopath.Outfits or {}
table.insert(BanditClan.Psychopath.Outfits, "Naked")
table.insert(BanditClan.Psychopath.Outfits, "HockeyPsycho")
table.insert(BanditClan.Psychopath.Outfits, "HospitalPatient")
table.insert(BanditClan.Psychopath.Outfits, "TinFoilHat")

if BanditCompatibility.GetGameVersion() >= 42 then
    table.insert(BanditClan.Psychopath.Outfits, "ArmorTest_RoadRash")
    table.insert(BanditClan.Psychopath.Outfits, "ArmorTest_Spikey")
    table.insert(BanditClan.Psychopath.Outfits, "ArmorTest_TrashPack")
    table.insert(BanditClan.Psychopath.Outfits, "ExterminatorSuited")
end

if getActivatedMods():contains("Authentic Z - Current") then
    table.insert(BanditClan.Psychopath.Outfits, "AuthenticJasonPart3")
    table.insert(BanditClan.Psychopath.Outfits, "AuthenticFat01")
    table.insert(BanditClan.Psychopath.Outfits, "AuthenticFat02")
    table.insert(BanditClan.Psychopath.Outfits, "AuthenticFat03")
    table.insert(BanditClan.Psychopath.Outfits, "AuthenticGhostFace")
    table.insert(BanditClan.Psychopath.Outfits, "AuthenticPolitician")
    table.insert(BanditClan.Psychopath.Outfits, "AuthenticShortgunFace")
end

-- available melee weapons
BanditClan.Psychopath.Melee = BanditClan.Psychopath.Melee or {}
table.insert(BanditClan.Psychopath.Melee, "Base.WoodAxe")
table.insert(BanditClan.Psychopath.Melee, "Base.HammerStone")
table.insert(BanditClan.Psychopath.Melee, "Base.Hammer")
table.insert(BanditClan.Psychopath.Melee, "Base.Plank_Nails")
table.insert(BanditClan.Psychopath.Melee, "Base.PickAxe")
table.insert(BanditClan.Psychopath.Melee, "Base.MetalBar")
table.insert(BanditClan.Psychopath.Melee, "Base.LeadPipe")

if BanditCompatibility.GetGameVersion() >= 42 then
    table.insert(BanditClan.Psychopath.Melee, "Base.BucketMace_Metal")
    table.insert(BanditClan.Psychopath.Melee, "Base.LongSpikedClub")
    table.insert(BanditClan.Psychopath.Melee, "Base.LongMace")
    table.insert(BanditClan.Psychopath.Melee, "Base.Mace")
end

if getActivatedMods():contains("Authentic Z - Current") then
    table.insert(BanditClan.Psychopath.Melee, "AuthenticZClothing.Chainsaw")
end

-- available primary weapons
BanditClan.Psychopath.Primary = BanditClan.Psychopath.Primary or BanditWeapons.Primary

-- available secondary weapons
BanditClan.Psychopath.Secondary = BanditClan.Psychopath.Secondary or BanditWeapons.Secondary

-- loot table
BanditClan.Psychopath.Loot = BanditClan.Psychopath.Loot or {}
table.insert(BanditClan.Psychopath.Loot, BanditLoot.MakeItem("Base.WaterBottle", 30))
table.insert(BanditClan.Psychopath.Loot, BanditLoot.MakeItem("Base.Pills", 99))
table.insert(BanditClan.Psychopath.Loot, BanditLoot.MakeItem("Base.Pills", 33))
table.insert(BanditClan.Psychopath.Loot, BanditLoot.MakeItem("Base.PillsAntiDep", 77))
table.insert(BanditClan.Psychopath.Loot, BanditLoot.MakeItem("Base.Jujubes", 1))
table.insert(BanditClan.Psychopath.Loot, BanditLoot.MakeItem("Base.HiHis", 1))
table.insert(BanditClan.Psychopath.Loot, BanditLoot.MakeItem("Base.CandyFruitSlices", 1))
table.insert(BanditClan.Psychopath.Loot, BanditLoot.MakeItem("Base.Doll", 33))
table.insert(BanditClan.Psychopath.Loot, BanditLoot.MakeItem("Base.CatToy", 22))
table.insert(BanditClan.Psychopath.Loot, BanditLoot.MakeItem("Base.Rubberducky ", 22))
table.insert(BanditClan.Psychopath.Loot, BanditLoot.MakeItem("Base.ToyCar ", 22))
table.insert(BanditClan.Psychopath.Loot, BanditLoot.MakeItem("Base.Bricktoys ", 11))
table.insert(BanditClan.Psychopath.Loot, BanditLoot.MakeItem("Base.Cube", 11))
table.insert(BanditClan.Psychopath.Loot, BanditLoot.MakeItem("Base.FrillyUnderpants_Red", 5))
table.insert(BanditClan.Psychopath.Loot, BanditLoot.MakeItem("Base.FrillyUnderpants_Pink", 4))

-- register this clan for spawn system
BanditCreator.ClanMap = BanditCreator.GroupMap or {}
BanditCreator.ClanMap[2] = BanditClan.Psychopath
