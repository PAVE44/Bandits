BanditClan = BanditClan or {}

BanditClan.Police = BanditClan.Police or {}

-- The unique id of the clan, ids 1-16 are reserved for waves
BanditClan.Police.id = 6

-- Name of the clan
BanditClan.Police.name = "Police"

-- % chance of a clan member to be a female. Outfit must support it.
BanditClan.Police.femaleChance = 0

-- health ranges from 1 - 14. Higher values may produce unexpected results,
BanditClan.Police.health = 4

-- if the bandit will eat player's body after death
BanditClan.Police.eatBody = false

-- Ranged weapon accuracy multiplayer (1=default)
BanditClan.Police.accuracyBoost = 1

-- Favorite zones 
BanditClan.Police.favoriteZones = {"Nav"}
BanditClan.Police.avoidZones = {"Vegitation", "Forest", "DeepForest"}

-- available outfits
BanditClan.Police.Outfits = BanditClan.Police.Outfits or {}
table.insert(BanditClan.Police.Outfits, "Police")
table.insert(BanditClan.Police.Outfits, "Police_SWAT")
table.insert(BanditClan.Police.Outfits, "ZSPoliceSpecialOps")

-- available melee weapons
BanditClan.Police.Melee = BanditClan.Police.Melee or {}
table.insert(BanditClan.Police.Melee, "Base.Nightstick")

-- available primary weapons
BanditClan.Police.Primary = BanditClan.Police.Primary or BanditWeapons.Primary

-- available secondary weapons
BanditClan.Police.Secondary = BanditClan.Police.Secondary or BanditWeapons.Secondary

-- loot table
BanditClan.Police.Loot = BanditClan.Police.Loot or {}
table.insert(BanditClan.Police.Loot, BanditLoot.MakeItem("Base.PaperBag", 96))
table.insert(BanditClan.Police.Loot, BanditLoot.MakeItem("Base.WaterBottle", 44))
table.insert(BanditClan.Police.Loot, BanditLoot.MakeItem("Base.DoughnutPlain", 99))
table.insert(BanditClan.Police.Loot, BanditLoot.MakeItem("Base.DoughnutPlain", 88))
table.insert(BanditClan.Police.Loot, BanditLoot.MakeItem("Base.DoughnutChocolate", 77))
table.insert(BanditClan.Police.Loot, BanditLoot.MakeItem("Base.DoughnutFrosted", 66))
table.insert(BanditClan.Police.Loot, BanditLoot.MakeItem("Base.DoughnutJelly", 55))
table.insert(BanditClan.Police.Loot, BanditLoot.MakeItem("Base.Coffee2", 88))
table.insert(BanditClan.Police.Loot, BanditLoot.MakeItem("Base.PlasticCup", 88))
table.insert(BanditClan.Police.Loot, BanditLoot.MakeItem("Base.SugarPacket", 44))
table.insert(BanditClan.Police.Loot, BanditLoot.MakeItem("Base.SugarPacket", 44))

if getActivatedMods():contains("Cuffs") then
    table.insert(BanditClan.Police.Loot, BanditLoot.MakeItem("Base.Cuffs", 90))
end

-- register this clan for spawn system
BanditCreator.ClanMap = BanditCreator.GroupMap or {}
BanditCreator.ClanMap[6] = BanditClan.Police
