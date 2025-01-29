BanditClan = BanditClan or {}

BanditClan.Cannibal = BanditClan.Cannibal or {}

-- The unique id of the clan, ids 1-16 are reserved for waves
BanditClan.Cannibal.id = 3

-- Name of the clan
BanditClan.Cannibal.name = "Cannibal"

-- % chance of a clan member to be a female. Outfit must support it.
BanditClan.Cannibal.femaleChance = 0

-- health ranges from 1 - 14. Higher values may produce unexpected results,
BanditClan.Cannibal.health = 2

-- if the bandit will eat player's body after death
BanditClan.Cannibal.eatBody = true

-- Ranged weapon accuracy multiplayer (1=default)
BanditClan.Cannibal.accuracyBoost = 0.8

-- Favorite zones 
BanditClan.Cannibal.favoriteZones = {}
BanditClan.Cannibal.avoidZones = {"Vegitation", "Forest", "DeepForest"}

-- available outfits
BanditClan.Cannibal.Outfits = BanditClan.Cannibal.Outfits or {}
table.insert(BanditClan.Cannibal.Outfits, "Woodcut")
table.insert(BanditClan.Cannibal.Outfits, "Waiter_Restaurant")
table.insert(BanditClan.Cannibal.Outfits, "Waiter_Diner")
if getActivatedMods():contains("Authentic Z - Current") then
    table.insert(BanditClan.Cannibal.Outfits, "AuthenticNMRIHButcher")
    table.insert(BanditClan.Cannibal.Outfits, "AuthenticLeatherFace")
end

-- available melee weapons
BanditClan.Cannibal.Melee = BanditClan.Cannibal.Melee or {}
table.insert(BanditClan.Cannibal.Melee, "Base.MeatCleaver")
table.insert(BanditClan.Cannibal.Melee, "Base.KitchenKnife")
table.insert(BanditClan.Cannibal.Melee, "Base.BreadKnife")
table.insert(BanditClan.Cannibal.Melee, "Base.Machete")

if getActivatedMods():contains("Authentic Z - Current") then
    table.insert(BanditClan.Cannibal.Melee, "AuthenticZClothing.Chainsaw")
end

-- available primary weapons
BanditClan.Cannibal.Primary = BanditClan.Cannibal.Primary or BanditWeapons.Primary

-- available secondary weapons
BanditClan.Cannibal.Secondary = BanditClan.Cannibal.Secondary or BanditWeapons.Secondary

-- loot table
BanditClan.Cannibal.Loot = BanditClan.Cannibal.Loot or {}
table.insert(BanditClan.Cannibal.Loot, BanditLoot.MakeItem("Base.WaterBottle", 30))
table.insert(BanditClan.Cannibal.Loot, BanditLoot.MakeItem("Base.Salt", 12))
table.insert(BanditClan.Cannibal.Loot, BanditLoot.MakeItem("Base.Steak", 99))
table.insert(BanditClan.Cannibal.Loot, BanditLoot.MakeItem("Base.Steak", 44))
table.insert(BanditClan.Cannibal.Loot, BanditLoot.MakeItem("Base.BaconBits", 44))
table.insert(BanditClan.Cannibal.Loot, BanditLoot.MakeItem("Base.CarvingFork", 33))
table.insert(BanditClan.Cannibal.Loot, BanditLoot.MakeItem("Base.Rope", 66))
table.insert(BanditClan.Cannibal.Loot, BanditLoot.MakeItem("Base.DuctTape", 65))
table.insert(BanditClan.Cannibal.Loot, BanditLoot.MakeItem("Base.Saw", 29))
table.insert(BanditClan.Cannibal.Loot, BanditLoot.MakeItem("Base.HandAxe", 7))
table.insert(BanditClan.Cannibal.Loot, BanditLoot.MakeItem("Base.Machete", 1))

-- register this clan for spawn system
BanditCreator.ClanMap = BanditCreator.GroupMap or {}
BanditCreator.ClanMap[3] = BanditClan.Cannibal
 