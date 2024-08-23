ClanDesperateCitizen = ClanDesperateCitizen or {}

-- The unique id of the clan, ids 1-16 are reserved for waves
ClanDesperateCitizen.id = 1

-- Name of the clan
ClanDesperateCitizen.name = "Desperate Cizizen"

-- % chance of a clan member to be a female. Outfit must support it.
ClanDesperateCitizen.femaleChance = 50

-- health ranges from 1 - 14. Higher values may produce unexpected results,
ClanDesperateCitizen.health = 1

-- if the bandit will eat player's body after death
ClanDesperateCitizen.EatBody = false

-- available outfits
ClanDesperateCitizen.Outfits = ClanDesperateCitizen.Outfits or {}
table.insert(ClanDesperateCitizen.Outfits, "Bathrobe")
table.insert(ClanDesperateCitizen.Outfits, "Generic02")
table.insert(ClanDesperateCitizen.Outfits, "Generic01")
table.insert(ClanDesperateCitizen.Outfits, "Punk")
table.insert(ClanDesperateCitizen.Outfits, "Rocker")
table.insert(ClanDesperateCitizen.Outfits, "Tourist")

if getActivatedMods():contains("Authentic Z - Current") then
    table.insert(ClanDesperateCitizen.Outfits, "AuthenticHomeless")
    table.insert(ClanDesperateCitizen.Outfits, "AuthenticElderly")
    table.insert(ClanDesperateCitizen.Outfits, "AuthenticSurvivorCovid")
end

-- available melee weapons
ClanDesperateCitizen.Melee = ClanDesperateCitizen.Melee or {}
table.insert(ClanDesperateCitizen.Melee, "Base.BreadKnife")
table.insert(ClanDesperateCitizen.Melee, "Base.Pan")
table.insert(ClanDesperateCitizen.Melee, "Base.RollingPin")
table.insert(ClanDesperateCitizen.Melee, "Base.SmashedBottle")
table.insert(ClanDesperateCitizen.Melee, "Base.HandScythe")
table.insert(ClanDesperateCitizen.Melee, "Base.WoodenLance")
table.insert(ClanDesperateCitizen.Melee, "Base.Banjo")
table.insert(ClanDesperateCitizen.Melee, "Base.ChairLeg")
table.insert(ClanDesperateCitizen.Melee, "Base.GardenFork")
table.insert(ClanDesperateCitizen.Melee, "Base.GridlePan")
table.insert(ClanDesperateCitizen.Melee, "Base.Hammer")
table.insert(ClanDesperateCitizen.Melee, "Base.HockeyStick")
table.insert(ClanDesperateCitizen.Melee, "Base.MetalPipe")
table.insert(ClanDesperateCitizen.Melee, "Base.PipeWrench")
table.insert(ClanDesperateCitizen.Melee, "Base.Plunger")
table.insert(ClanDesperateCitizen.Melee, "Base.GuitarElectricRed")
table.insert(ClanDesperateCitizen.Melee, "Base.Saucepan")
table.insert(ClanDesperateCitizen.Melee, "Base.TableLeg")
table.insert(ClanDesperateCitizen.Melee, "Base.Wrench")

-- available primary weapons
ClanDesperateCitizen.Primary = ClanDesperateCitizen.Primary or BanditWeapons.Primary

-- available secondary weapons
ClanDesperateCitizen.Secondary = ClanDesperateCitizen.Secondary or BanditWeapons.Secondary

-- loot table
ClanDesperateCitizen.Loot = ClanDesperateCitizen.Loot or {}
table.insert(ClanDesperateCitizen.Loot, BanditLoot.MakeItem("Base.WaterBottleFull", 30))
table.insert(ClanDesperateCitizen.Loot, BanditLoot.MakeItem("Base.Gum", 5))
table.insert(ClanDesperateCitizen.Loot, BanditLoot.MakeItem("Base.Peppermint", 2))
table.insert(ClanDesperateCitizen.Loot, BanditLoot.MakeItem("Base.GummyWorms", 1))
table.insert(ClanDesperateCitizen.Loot, BanditLoot.MakeItem("Base.Jujubes", 1))
table.insert(ClanDesperateCitizen.Loot, BanditLoot.MakeItem("Base.HiHis", 1))
table.insert(ClanDesperateCitizen.Loot, BanditLoot.MakeItem("Base.CandyFruitSlices", 1))
table.insert(ClanDesperateCitizen.Loot, BanditLoot.MakeItem("Base.Crisps", 1))
table.insert(ClanDesperateCitizen.Loot, BanditLoot.MakeItem("Base.Crisps2", 1))
table.insert(ClanDesperateCitizen.Loot, BanditLoot.MakeItem("Base.Crisps3", 1))