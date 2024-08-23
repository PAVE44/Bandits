ClanPolice = ClanPolice or {}

-- The unique id of the clan, ids 1-16 are reserved for waves
ClanPolice.id = 5

-- Name of the clan
ClanPolice.name = "Police"

-- % chance of a clan member to be a female. Outfit must support it.
ClanPolice.femaleChance = 30

-- health ranges from 1 - 14. Higher values may produce unexpected results,
ClanPolice.health = 4

-- if the bandit will eat player's body after death
ClanPolice.EatBody = false

-- available outfits
ClanPolice.Outfits = ClanPolice.Outfits or {}
table.insert(ClanPolice.Outfits, "Police")
table.insert(ClanPolice.Outfits, "PoliceState")
table.insert(ClanPolice.Outfits, "PoliceRiot")
table.insert(ClanPolice.Outfits, "PrisonGuard")

if getActivatedMods():contains("Authentic Z - Current") then
    table.insert(ClanPolice.Outfits, "AuthenticSurvivorPolice")
    table.insert(ClanPolice.Outfits, "AuthenticSecretService")
end

if getActivatedMods():contains("zReSWATARMORbykK") then
    table.insert(ClanPolice.Outfits, "zReSA_SWAT1")
    table.insert(ClanPolice.Outfits, "zReSA_SWAT2")
end

-- available melee weapons
ClanPolice.Melee = ClanPolice.Melee or {}
table.insert(ClanPolice.Melee, "Base.Nightstick")

-- available primary weapons
ClanPolice.Primary = ClanPolice.Primary or BanditWeapons.Primary

-- available secondary weapons
ClanPolice.Secondary = ClanPolice.Secondary or BanditWeapons.Secondary

-- loot table
ClanPolice.Loot = ClanPolice.Loot or {}
table.insert(ClanPolice.Loot, BanditLoot.MakeItem("Base.PaperBag", 96))
table.insert(ClanPolice.Loot, BanditLoot.MakeItem("Base.WaterBottleFull", 44))
table.insert(ClanPolice.Loot, BanditLoot.MakeItem("Base.DoughnutPlain", 99))
table.insert(ClanPolice.Loot, BanditLoot.MakeItem("Base.DoughnutPlain", 88))
table.insert(ClanPolice.Loot, BanditLoot.MakeItem("Base.DoughnutChocolate", 77))
table.insert(ClanPolice.Loot, BanditLoot.MakeItem("Base.DoughnutFrosted", 66))
table.insert(ClanPolice.Loot, BanditLoot.MakeItem("Base.DoughnutJelly", 55))
table.insert(ClanPolice.Loot, BanditLoot.MakeItem("Base.Coffee2", 88))
table.insert(ClanPolice.Loot, BanditLoot.MakeItem("Base.PlasticCup", 88))
table.insert(ClanPolice.Loot, BanditLoot.MakeItem("Base.SugarPacket", 44))
table.insert(ClanPolice.Loot, BanditLoot.MakeItem("Base.SugarPacket", 44))
