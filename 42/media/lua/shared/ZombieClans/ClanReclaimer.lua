require "BanditWeapons"
BanditClan = BanditClan or {}

BanditClan.Reclaimer = BanditClan.Reclaimer or {}

-- The unique id of the clan, ids 1-16 are reserved for waves
BanditClan.Reclaimer.id = 11

-- Name of the clan
BanditClan.Reclaimer.name = "Reclaimer"

-- % chance of a clan member to be a female. Outfit must support it.
BanditClan.Reclaimer.femaleChance = 0

-- health ranges from 1 - 14. Higher values may produce unexpected results,
BanditClan.Reclaimer.health = 9

-- if the bandit will eat player's body after death
BanditClan.Reclaimer.eatBody = true

-- Ranged weapon accuracy multiplayer (1=default)
BanditClan.Reclaimer.accuracyBoost = 0.8

-- Favorite zones 
BanditClan.Reclaimer.favoriteZones = {}
BanditClan.Reclaimer.avoidZones = {"Forest", "DeepForest"}

-- available outfits
BanditClan.Reclaimer.Outfits = BanditClan.Reclaimer.Outfits or {}
table.insert(BanditClan.Reclaimer.Outfits, "Priest")
table.insert(BanditClan.Reclaimer.Outfits, "CostumeMonster")
table.insert(BanditClan.Reclaimer.Outfits, "CostumeVampire")

-- available melee weapons
BanditClan.Reclaimer.Melee = BanditClan.Reclaimer.Melee or {}
table.insert(BanditClan.Reclaimer.Melee, "Base.Katana")
table.insert(BanditClan.Reclaimer.Melee, "Base.HandScythe")
table.insert(BanditClan.Reclaimer.Melee, "Base.CrudeSword")
table.insert(BanditClan.Reclaimer.Melee, "Base.Sword")

if getActivatedMods():contains("Authentic Z - Current") then
    table.insert(BanditClan.Reclaimer.Melee, "AuthenticZClothing.MandoSpear")
    table.insert(BanditClan.Reclaimer.Melee, "AuthenticZClothing.Chainsaw")
end

-- available primary weapons
BanditClan.Reclaimer.Primary = BanditClan.Reclaimer.Primary or BanditWeapons.Primary

-- available secondary weapons
BanditClan.Reclaimer.Secondary = BanditClan.Reclaimer.Secondary or BanditWeapons.Secondary

-- loot table
BanditClan.Reclaimer.Loot = BanditClan.Reclaimer.Loot or {}
table.insert(BanditClan.Reclaimer.Loot, BanditLoot.MakeItem("Base.Necklace_GoldRuby", 100))

for i=1, 3 do
    table.insert(BanditClan.Reclaimer.Loot, BanditLoot.MakeItem("Base.ChickenFoot", 22))
    table.insert(BanditClan.Reclaimer.Loot, BanditLoot.MakeItem("Base.Centipede", 22))
    table.insert(BanditClan.Reclaimer.Loot, BanditLoot.MakeItem("Base.Centipede2", 22))
    table.insert(BanditClan.Reclaimer.Loot, BanditLoot.MakeItem("Base.Cockroach", 22))
    table.insert(BanditClan.Reclaimer.Loot, BanditLoot.MakeItem("Base.Cricket", 22))
    table.insert(BanditClan.Reclaimer.Loot, BanditLoot.MakeItem("Base.Maggots", 22))
    table.insert(BanditClan.Reclaimer.Loot, BanditLoot.MakeItem("Base.Millipede", 22))
    table.insert(BanditClan.Reclaimer.Loot, BanditLoot.MakeItem("Base.Pillbug", 22))
    table.insert(BanditClan.Reclaimer.Loot, BanditLoot.MakeItem("Base.Worm", 22))
    table.insert(BanditClan.Reclaimer.Loot, BanditLoot.MakeItem("Base.RippedSheetsDirty", 22))
    table.insert(BanditClan.Reclaimer.Loot, BanditLoot.MakeItem("Base.BarbedWire", 22))
    table.insert(BanditClan.Reclaimer.Loot, BanditLoot.MakeItem("Base.Saw", 22))
    table.insert(BanditClan.Reclaimer.Loot, BanditLoot.MakeItem("Base.Plank", 22))
end

for i=1, 17 do
    table.insert(BanditClan.Reclaimer.Loot, BanditLoot.MakeItem("Base.Nails", 22))
end

-- register this clan for spawn system
BanditCreator.ClanMap = BanditCreator.GroupMap or {}
BanditCreator.ClanMap[11] = BanditClan.Reclaimer
