ClanInmate = ClanInmate or {}

-- The unique id of the clan, ids 1-16 are reserved for waves
ClanInmate.id = 6

-- Name of the clan
ClanInmate.name = "Inmate"

-- % chance of a clan member to be a female. Outfit must support it.
ClanInmate.femaleChance = 0

-- health ranges from 1 - 14. Higher values may produce unexpected results,
ClanInmate.health = 3

-- if the bandit will eat player's body after death
ClanInmate.EatBody = false

-- available outfits
ClanInmate.Outfits = ClanInmate.Outfits or {}
table.insert(ClanInmate.Outfits, "Inmate")
table.insert(ClanInmate.Outfits, "InmateEscaped")

-- available melee weapons
ClanInmate.Melee = ClanInmate.Melee or {}
table.insert(ClanInmate.Melee, "Base.BreadKnife")
table.insert(ClanInmate.Melee, "Base.KitchenKnife")
table.insert(ClanInmate.Melee, "Base.MetalBar")
table.insert(ClanInmate.Melee, "Base.Shovel2") 
table.insert(ClanInmate.Melee, "Base.SmashedBottle")

-- available primary weapons
ClanInmate.Primary = ClanInmate.Primary or BanditWeapons.Primary

-- available secondary weapons
ClanInmate.Secondary = ClanInmate.Secondary or BanditWeapons.Secondary

-- loot table
ClanInmate.Loot = ClanInmate.Loot or {}
table.insert(ClanInmate.Loot, BanditLoot.MakeItem("Base.WaterBottleFull", 44))
table.insert(ClanInmate.Loot, BanditLoot.MakeItem("Base.Crowbar", 77))
table.insert(ClanInmate.Loot, BanditLoot.MakeItem("Base.Hammer", 33))
table.insert(ClanInmate.Loot, BanditLoot.MakeItem("Base.Saw", 3))
table.insert(ClanInmate.Loot, BanditLoot.MakeItem("Base.WeldingMask", 8))
table.insert(ClanInmate.Loot, BanditLoot.MakeItem("Base.BlowTorch", 8))
table.insert(ClanInmate.Loot, BanditLoot.MakeItem("Base.Screwdriver", 6))
table.insert(ClanInmate.Loot, BanditLoot.MakeItem("Base.IcePick", 13))
table.insert(ClanInmate.Loot, BanditLoot.MakeItem("Base.HandTorch", 100))
table.insert(ClanInmate.Loot, BanditLoot.MakeItem("Base.TinOpener", 11))
table.insert(ClanInmate.Loot, BanditLoot.MakeItem("Base.Screwdriver", 6))

table.insert(ClanInmate.Loot, BanditLoot.MakeItem("Base.TinnedBeans", 3))
table.insert(ClanInmate.Loot, BanditLoot.MakeItem("Base.CannedCarrots2", 3))
table.insert(ClanInmate.Loot, BanditLoot.MakeItem("Base.CannedChili", 3))
table.insert(ClanInmate.Loot, BanditLoot.MakeItem("Base.CannedCorn", 3))
table.insert(ClanInmate.Loot, BanditLoot.MakeItem("Base.CannedCornedBeef", 3))
table.insert(ClanInmate.Loot, BanditLoot.MakeItem("Base.CannedFruitCocktail", 3))
table.insert(ClanInmate.Loot, BanditLoot.MakeItem("Base.CannedMushroomSoup", 3))
table.insert(ClanInmate.Loot, BanditLoot.MakeItem("Base.CannedPeaches", 3))
table.insert(ClanInmate.Loot, BanditLoot.MakeItem("Base.CannedPeas", 3))
table.insert(ClanInmate.Loot, BanditLoot.MakeItem("Base.CannedPineapple", 3))
table.insert(ClanInmate.Loot, BanditLoot.MakeItem("Base.CannedPotato2", 3))
table.insert(ClanInmate.Loot, BanditLoot.MakeItem("Base.CannedSardines", 3))
table.insert(ClanInmate.Loot, BanditLoot.MakeItem("Base.TinnedSoup", 3))
table.insert(ClanInmate.Loot, BanditLoot.MakeItem("Base.CannedBolognese", 3))
table.insert(ClanInmate.Loot, BanditLoot.MakeItem("Base.CannedTomato2", 3))

table.insert(ClanInmate.Loot, BanditLoot.MakeItem("Base.CannedBroccoli", 1))
table.insert(ClanInmate.Loot, BanditLoot.MakeItem("Base.CannedCabbage", 1))
table.insert(ClanInmate.Loot, BanditLoot.MakeItem("Base.CannedCarrots", 1))
table.insert(ClanInmate.Loot, BanditLoot.MakeItem("Base.CannedPotato", 1))
table.insert(ClanInmate.Loot, BanditLoot.MakeItem("Base.CannedTomato", 1))
table.insert(ClanInmate.Loot, BanditLoot.MakeItem("Base.CannedEggplant", 1))
table.insert(ClanInmate.Loot, BanditLoot.MakeItem("Base.CannedBellPepper", 1))