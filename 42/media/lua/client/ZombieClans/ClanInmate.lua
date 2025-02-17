BanditClan = BanditClan or {}

BanditClan.Inmate = BanditClan.Inmate or {}

-- The unique id of the clan, ids 1-16 are reserved for waves
BanditClan.Inmate.id = 5

-- Name of the clan
BanditClan.Inmate.name = "Inmate"

-- % chance of a clan member to be a female. Outfit must support it.
BanditClan.Inmate.femaleChance = 0

-- health ranges from 1 - 14. Higher values may produce unexpected results,
BanditClan.Inmate.health = 1.2

-- if the bandit will eat player's body after death
BanditClan.Inmate.eatBody = false

-- Ranged weapon accuracy multiplayer (1=default)
BanditClan.Inmate.accuracyBoost = 0.9

-- Favorite zones 
BanditClan.Inmate.favoriteZones = {}
BanditClan.Inmate.avoidZones = {"Forest", "DeepForest"}

-- available outfits
BanditClan.Inmate.Outfits = BanditClan.Inmate.Outfits or {}
table.insert(BanditClan.Inmate.Outfits, "Inmate")
table.insert(BanditClan.Inmate.Outfits, "InmateEscaped")

-- available melee weapons
BanditClan.Inmate.Melee = BanditClan.Inmate.Melee or {}
table.insert(BanditClan.Inmate.Melee, BanditCompatibility.GetLegacyItem("Base.BreadKnife"))
table.insert(BanditClan.Inmate.Melee, BanditCompatibility.GetLegacyItem("Base.KitchenKnife"))
table.insert(BanditClan.Inmate.Melee, BanditCompatibility.GetLegacyItem("Base.MetalBar"))
table.insert(BanditClan.Inmate.Melee, BanditCompatibility.GetLegacyItem("Base.Shovel2")) 
table.insert(BanditClan.Inmate.Melee, BanditCompatibility.GetLegacyItem("Base.SmashedBottle"))

-- available primary weapons
BanditClan.Inmate.Primary = BanditClan.Inmate.Primary or BanditWeapons.Primary

-- available secondary weapons
BanditClan.Inmate.Secondary = BanditClan.Inmate.Secondary or BanditWeapons.Secondary

-- loot table
BanditClan.Inmate.Loot = BanditClan.Inmate.Loot or {}
table.insert(BanditClan.Inmate.Loot, BanditLoot.MakeItem("Base.WaterBottle", 44))
table.insert(BanditClan.Inmate.Loot, BanditLoot.MakeItem("Base.Crowbar", 77))
table.insert(BanditClan.Inmate.Loot, BanditLoot.MakeItem("Base.Hammer", 33))
table.insert(BanditClan.Inmate.Loot, BanditLoot.MakeItem("Base.Saw", 3))
table.insert(BanditClan.Inmate.Loot, BanditLoot.MakeItem("Base.WeldingMask", 8))
table.insert(BanditClan.Inmate.Loot, BanditLoot.MakeItem("Base.BlowTorch", 8))
table.insert(BanditClan.Inmate.Loot, BanditLoot.MakeItem("Base.Screwdriver", 6))
table.insert(BanditClan.Inmate.Loot, BanditLoot.MakeItem("Base.IcePick", 13))
table.insert(BanditClan.Inmate.Loot, BanditLoot.MakeItem("Base.HandTorch", 100))
table.insert(BanditClan.Inmate.Loot, BanditLoot.MakeItem("Base.TinOpener", 11))
table.insert(BanditClan.Inmate.Loot, BanditLoot.MakeItem("Base.Screwdriver", 6))

table.insert(BanditClan.Inmate.Loot, BanditLoot.MakeItem("Base.TinnedBeans", 3))
table.insert(BanditClan.Inmate.Loot, BanditLoot.MakeItem("Base.CannedCarrots2", 3))
table.insert(BanditClan.Inmate.Loot, BanditLoot.MakeItem("Base.CannedChili", 3))
table.insert(BanditClan.Inmate.Loot, BanditLoot.MakeItem("Base.CannedCorn", 3))
table.insert(BanditClan.Inmate.Loot, BanditLoot.MakeItem("Base.CannedCornedBeef", 3))
table.insert(BanditClan.Inmate.Loot, BanditLoot.MakeItem("Base.CannedFruitCocktail", 3))
table.insert(BanditClan.Inmate.Loot, BanditLoot.MakeItem("Base.CannedMushroomSoup", 3))
table.insert(BanditClan.Inmate.Loot, BanditLoot.MakeItem("Base.CannedPeaches", 3))
table.insert(BanditClan.Inmate.Loot, BanditLoot.MakeItem("Base.CannedPeas", 3))
table.insert(BanditClan.Inmate.Loot, BanditLoot.MakeItem("Base.CannedPineapple", 3))
table.insert(BanditClan.Inmate.Loot, BanditLoot.MakeItem("Base.CannedPotato2", 3))
table.insert(BanditClan.Inmate.Loot, BanditLoot.MakeItem("Base.CannedSardines", 3))
table.insert(BanditClan.Inmate.Loot, BanditLoot.MakeItem("Base.TinnedSoup", 3))
table.insert(BanditClan.Inmate.Loot, BanditLoot.MakeItem("Base.CannedBolognese", 3))
table.insert(BanditClan.Inmate.Loot, BanditLoot.MakeItem("Base.CannedTomato2", 3))

table.insert(BanditClan.Inmate.Loot, BanditLoot.MakeItem("Base.CannedBroccoli", 1))
table.insert(BanditClan.Inmate.Loot, BanditLoot.MakeItem("Base.CannedCabbage", 1))
table.insert(BanditClan.Inmate.Loot, BanditLoot.MakeItem("Base.CannedCarrots", 1))
table.insert(BanditClan.Inmate.Loot, BanditLoot.MakeItem("Base.CannedPotato", 1))
table.insert(BanditClan.Inmate.Loot, BanditLoot.MakeItem("Base.CannedTomato", 1))
table.insert(BanditClan.Inmate.Loot, BanditLoot.MakeItem("Base.CannedEggplant", 1))
table.insert(BanditClan.Inmate.Loot, BanditLoot.MakeItem("Base.CannedBellPepper", 1))

-- register this clan for spawn system
BanditCreator.ClanMap = BanditCreator.GroupMap or {}
BanditCreator.ClanMap[5] = BanditClan.Inmate
