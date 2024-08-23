ClanHunter = ClanHunter or {}

-- The unique id of the clan, ids 1-16 are reserved for waves
ClanHunter.id = 9

-- Name of the clan
ClanHunter.name = "Hunter"

-- % chance of a clan member to be a female. Outfit must support it.
ClanHunter.femaleChance = 0

-- health ranges from 1 - 14. Higher values may produce unexpected results,
ClanHunter.health = 4

-- if the bandit will eat player's body after death
ClanHunter.EatBody = false

-- available outfits
ClanHunter.Outfits = ClanHunter.Outfits or {}
table.insert(ClanHunter.Outfits, "Hunter")

-- available melee weapons
ClanHunter.Melee = ClanHunter.Melee or {}
table.insert(ClanHunter.Melee, "Base.HuntingKnife")
table.insert(ClanHunter.Melee, "Base.Machete")
table.insert(ClanHunter.Melee, "Base.HandAxe")

-- available primary weapons
ClanHunter.Primary = ClanHunter.Primary or BanditWeapons.Primary

-- available secondary weapons
ClanHunter.Secondary = ClanHunter.Secondary or BanditWeapons.Secondary

-- loot table
ClanHunter.Loot = ClanHunter.Loot or {}
table.insert(ClanHunter.Loot, BanditLoot.MakeItem("Base.HandTorch", 100))
table.insert(ClanHunter.Loot, BanditLoot.MakeItem("Base.FishingRod", 87))
table.insert(ClanHunter.Loot, BanditLoot.MakeItem("Base.Worm", 90))
table.insert(ClanHunter.Loot, BanditLoot.MakeItem("Base.Worm", 80))
table.insert(ClanHunter.Loot, BanditLoot.MakeItem("Base.Worm", 70))
table.insert(ClanHunter.Loot, BanditLoot.MakeItem("Base.HandTorch", 100))
table.insert(ClanHunter.Loot, BanditLoot.MakeItem("Base.Battery", 88))
table.insert(ClanHunter.Loot, BanditLoot.MakeItem("camping.CampfireKit", 33))
table.insert(ClanHunter.Loot, BanditLoot.MakeItem("Base.Matches", 99))
table.insert(ClanHunter.Loot, BanditLoot.MakeItem("Base.CampingTentKit", 88))
table.insert(ClanHunter.Loot, BanditLoot.MakeItem("Base.HuntingKnife", 80))
table.insert(ClanHunter.Loot, BanditLoot.MakeItem("Base.Twine", 80))
table.insert(ClanHunter.Loot, BanditLoot.MakeItem("Radio.WalkieTalkieMakeShift", 23))
table.insert(ClanHunter.Loot, BanditLoot.MakeItem("Base.AlcoholBandage", 33))
table.insert(ClanHunter.Loot, BanditLoot.MakeItem("Base.Disinfectant", 55))
table.insert(ClanHunter.Loot, BanditLoot.MakeItem("Base.Pills", 2))
table.insert(ClanHunter.Loot, BanditLoot.MakeItem("Base.Spoon", 40))
table.insert(ClanHunter.Loot, BanditLoot.MakeItem("Base.Pencil", 35))
table.insert(ClanHunter.Loot, BanditLoot.MakeItem("Base.Pot", 21))
table.insert(ClanHunter.Loot, BanditLoot.MakeItem("Base.Scissors", 17))
table.insert(ClanHunter.Loot, BanditLoot.MakeItem("Base.Toothbrush", 77))
table.insert(ClanHunter.Loot, BanditLoot.MakeItem("Base.Toothpaste", 77))
table.insert(ClanHunter.Loot, BanditLoot.MakeItem("Base.Soap", 66))
table.insert(ClanHunter.Loot, BanditLoot.MakeItem("Base.TrapStick", 52))
table.insert(ClanHunter.Loot, BanditLoot.MakeItem("Base.TrapSnare", 62))

if if getActivatedMods():contains("MandelaBowAndArrow") then
    table.insert(ClanHunter.Loot, BanditLoot.MakeItem("MandelaBowAndArrow.MandelaBowWoodLong", 100))
    table.insert(ClanHunter.Loot, BanditLoot.MakeItem("MandelaBowAndArrow.MandelaArrowBundle", 12))
    table.insert(ClanHunter.Loot, BanditLoot.MakeItem("MandelaArrowWoodDucttapeIron", 77))
    table.insert(ClanHunter.Loot, BanditLoot.MakeItem("MandelaArrowWoodDucttapeIron", 66))
    table.insert(ClanHunter.Loot, BanditLoot.MakeItem("MandelaArrowWoodDucttapeIron", 55))
    table.insert(ClanHunter.Loot, BanditLoot.MakeItem("MandelaArrowWoodDucttapeIron", 44))
end

table.insert(ClanHunter.Loot, BanditLoot.MakeItem("Base.WaterBottleFull", 99))
table.insert(ClanHunter.Loot, BanditLoot.MakeItem("Base.WhiskeyFull", 22))
table.insert(ClanHunter.Loot, BanditLoot.MakeItem("Base.DehydratedMeatStick", 34))
table.insert(ClanHunter.Loot, BanditLoot.MakeItem("Base.Sausage", 34))
table.insert(ClanHunter.Loot, BanditLoot.MakeItem("Base.Baloney", 31))
table.insert(ClanHunter.Loot, BanditLoot.MakeItem("Base.Salami", 23))
table.insert(ClanHunter.Loot, BanditLoot.MakeItem("Base.DeadRabbit", 77))
table.insert(ClanHunter.Loot, BanditLoot.MakeItem("Base.DeadRabbit", 44))
table.insert(ClanHunter.Loot, BanditLoot.MakeItem("Base.DeadRabbit", 4))
table.insert(ClanHunter.Loot, BanditLoot.MakeItem("Base.DeadSquirrel", 66))
table.insert(ClanHunter.Loot, BanditLoot.MakeItem("Base.DeadSquirrel", 55))
table.insert(ClanHunter.Loot, BanditLoot.MakeItem("Base.DeadSquirrel", 22))
table.insert(ClanHunter.Loot, BanditLoot.MakeItem("Base.Trout", 11))
table.insert(ClanHunter.Loot, BanditLoot.MakeItem("Base.Trout", 11))
table.insert(ClanHunter.Loot, BanditLoot.MakeItem("Base.Trout", 11))
table.insert(ClanHunter.Loot, BanditLoot.MakeItem("Base.Perch", 11))
table.insert(ClanHunter.Loot, BanditLoot.MakeItem("Base.Perch", 11))
table.insert(ClanHunter.Loot, BanditLoot.MakeItem("Base.Crappie", 11))
table.insert(ClanHunter.Loot, BanditLoot.MakeItem("Base.Crappie", 11))

table.insert(ClanHunter.Loot, BanditLoot.MakeItem("Base.Chocolate", 1))
table.insert(ClanHunter.Loot, BanditLoot.MakeItem("Base.PeanutButter", 1))
table.insert(ClanHunter.Loot, BanditLoot.MakeItem("Base.Apple", 1))
table.insert(ClanHunter.Loot, BanditLoot.MakeItem("Base.Cherry", 1))
table.insert(ClanHunter.Loot, BanditLoot.MakeItem("Base.Grapes", 8))
table.insert(ClanHunter.Loot, BanditLoot.MakeItem("Base.Onion", 5))
table.insert(ClanHunter.Loot, BanditLoot.MakeItem("Base.Frog", 19))

table.insert(ClanHunter.Loot, BanditLoot.MakeItem("Base.HuntingMag1", 5))
table.insert(ClanHunter.Loot, BanditLoot.MakeItem("Base.HuntingMag2", 5))
table.insert(ClanHunter.Loot, BanditLoot.MakeItem("Base.HuntingMag3", 5))

