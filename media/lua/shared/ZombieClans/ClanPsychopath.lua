ClanPsychopath = ClanPsychopath or {}

-- The unique id of the clan, ids 1-16 are reserved for waves
ClanPsychopath.id = 2

-- Name of the clan
ClanPsychopath.name = "Psychopath"

-- % chance of a clan member to be a female. Outfit must support it.
ClanPsychopath.femaleChance = 0

-- health ranges from 1 - 14. Higher values may produce unexpected results,
ClanPsychopath.health = 2

-- if the bandit will eat player's body after death
ClanPsychopath.EatBody = false

-- available outfits
ClanPsychopath.Outfits = ClanPsychopath.Outfits or {}
table.insert(ClanPsychopath.Outfits, "Naked")
table.insert(ClanPsychopath.Outfits, "HockeyPsycho")
table.insert(ClanPsychopath.Outfits, "HospitalPatient")
table.insert(ClanPsychopath.Outfits, "Trader")
table.insert(ClanPsychopath.Outfits, "TinFoilHat")

if getActivatedMods():contains("Authentic Z - Current") then
    table.insert(ClanPsychopath.Outfits, "AuthenticJasonPart3")
    table.insert(ClanPsychopath.Outfits, "AuthenticFat01")
    table.insert(ClanPsychopath.Outfits, "AuthenticFat02")
    table.insert(ClanPsychopath.Outfits, "AuthenticFat03")
    table.insert(ClanPsychopath.Outfits, "AuthenticGhostFace")
    table.insert(ClanPsychopath.Outfits, "AuthenticPolitician")
    table.insert(ClanPsychopath.Outfits, "AuthenticShortgunFace")
end

-- available melee weapons
ClanPsychopath.Melee = ClanPsychopath.Melee or {}
table.insert(ClanPsychopath.Melee, "Base.WoodAxe")
table.insert(ClanPsychopath.Melee, "Base.HammerStone")
table.insert(ClanPsychopath.Melee, "Base.Hammer")
table.insert(ClanPsychopath.Melee, "Base.PlankNail")
table.insert(ClanPsychopath.Melee, "Base.PickAxe")
table.insert(ClanPsychopath.Melee, "Base.MetalBar")
table.insert(ClanPsychopath.Melee, "Base.LeadPipe")
table.insert(ClanPsychopath.Melee, "Base.Scalpel")

if getActivatedMods():contains("Authentic Z - Current") then
    table.insert(ClanPsychopath.Melee, "AuthenticZClothing.Chainsaw")
end

-- available primary weapons
ClanPsychopath.Primary = ClanPsychopath.Primary or BanditWeapons.Primary

-- available secondary weapons
ClanPsychopath.Secondary = ClanPsychopath.Secondary or BanditWeapons.Secondary

-- loot table
ClanPsychopath.Loot = ClanPsychopath.Loot or {}
table.insert(ClanPsychopath.Loot, BanditLoot.MakeItem("Base.WaterBottleFull", 30))
table.insert(ClanPsychopath.Loot, BanditLoot.MakeItem("Base.Pills", 99))
table.insert(ClanPsychopath.Loot, BanditLoot.MakeItem("Base.Pills", 33))
table.insert(ClanPsychopath.Loot, BanditLoot.MakeItem("Base.PillsAntiDep", 77))
table.insert(ClanPsychopath.Loot, BanditLoot.MakeItem("Base.Jujubes", 1))
table.insert(ClanPsychopath.Loot, BanditLoot.MakeItem("Base.HiHis", 1))
table.insert(ClanPsychopath.Loot, BanditLoot.MakeItem("Base.CandyFruitSlices", 1))
table.insert(ClanPsychopath.Loot, BanditLoot.MakeItem("Base.Doll", 33))
table.insert(ClanPsychopath.Loot, BanditLoot.MakeItem("Base.CatToy", 22))
table.insert(ClanPsychopath.Loot, BanditLoot.MakeItem("Base.Rubberducky ", 22))
table.insert(ClanPsychopath.Loot, BanditLoot.MakeItem("Base.ToyCar ", 22))
table.insert(ClanPsychopath.Loot, BanditLoot.MakeItem("Base.Bricktoys ", 11))
table.insert(ClanPsychopath.Loot, BanditLoot.MakeItem("Base.Cube", 11))
table.insert(ClanPsychopath.Loot, BanditLoot.MakeItem("Base.FrillyUnderpants_Red", 5))
table.insert(ClanPsychopath.Loot, BanditLoot.MakeItem("Base.FrillyUnderpants_Pink", 4))

