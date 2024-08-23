ClanCannibal = ClanCannibal or {}

-- The unique id of the clan, ids 1-16 are reserved for waves
ClanCannibal.id = 3

-- Name of the clan
ClanCannibal.name = "Cannibal"

-- % chance of a clan member to be a female. Outfit must support it.
ClanCannibal.femaleChance = 0

-- health ranges from 1 - 14. Higher values may produce unexpected results,
ClanCannibal.health = 2

-- if the bandit will eat player's body after death
ClanCannibal.EatBody = true

-- available outfits
ClanCannibal.Outfits = ClanCannibal.Outfits or {}
table.insert(ClanCannibal.Outfits, "Woodcut")
table.insert(ClanCannibal.Outfits, "Waiter_Restaurant")
table.insert(ClanCannibal.Outfits, "Waiter_Diner")
if getActivatedMods():contains("Authentic Z - Current") then
    table.insert(ClanCannibal.Outfits, "AuthenticNMRIHButcher")
    table.insert(ClanCannibal.Outfits, "AuthenticLeatherFace")
end

-- available melee weapons
ClanCannibal.Melee = ClanCannibal.Melee or {}
table.insert(ClanCannibal.Melee, "Base.MeatCleaver")
table.insert(ClanCannibal.Melee, "Base.KitchenKnife")
table.insert(ClanCannibal.Melee, "Base.BreadKnife")
table.insert(ClanCannibal.Melee, "Base.Machete ")

if getActivatedMods():contains("Authentic Z - Current") then
    table.insert(ClanCannibal.Melee, "AuthenticZClothing.Chainsaw")
end

-- available primary weapons
ClanCannibal.Primary = ClanCannibal.Primary or BanditWeapons.Primary

-- available secondary weapons
ClanCannibal.Secondary = ClanCannibal.Secondary or BanditWeapons.Secondary

-- loot table
ClanCannibal.Loot = ClanCannibal.Loot or {}
table.insert(ClanCannibal.Loot, BanditLoot.MakeItem("Base.WaterBottleFull", 30))
table.insert(ClanCannibal.Loot, BanditLoot.MakeItem("Base.Salt", 12))
table.insert(ClanCannibal.Loot, BanditLoot.MakeItem("Base.Steak", 99))
table.insert(ClanCannibal.Loot, BanditLoot.MakeItem("Base.Steak", 44))
table.insert(ClanCannibal.Loot, BanditLoot.MakeItem("farming.BaconBits", 44))
table.insert(ClanCannibal.Loot, BanditLoot.MakeItem("Base.CarvingFork", 33))
table.insert(ClanCannibal.Loot, BanditLoot.MakeItem("Base.Rope", 66))
table.insert(ClanCannibal.Loot, BanditLoot.MakeItem("Base.DuctTape", 65))
table.insert(ClanCannibal.Loot, BanditLoot.MakeItem("Base.Saw", 29))
table.insert(ClanCannibal.Loot, BanditLoot.MakeItem("Base.HandAxe", 7))
table.insert(ClanCannibal.Loot, BanditLoot.MakeItem("Base.Machete", 1))





 