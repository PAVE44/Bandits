BanditClan = BanditClan or {}

BanditClan.DesperateCitizen = BanditClan.DesperateCitizen or {}

-- The unique id of the clan, ids 1-16 are reserved for waves
BanditClan.DesperateCitizen.id = 1

-- Name of the clan
BanditClan.DesperateCitizen.name = "Desperate Cizizen"

-- % chance of a clan member to be a female. Outfit must support it.
BanditClan.DesperateCitizen.femaleChance = 51

-- health ranges from 1 - 14. Higher values may produce unexpected results,
BanditClan.DesperateCitizen.health = 1

-- if the bandit will eat player's body after death
BanditClan.DesperateCitizen.eatBody = false

-- available outfits
BanditClan.DesperateCitizen.Outfits = BanditClan.DesperateCitizen.Outfits or {}
table.insert(BanditClan.DesperateCitizen.Outfits, "Bathrobe")
table.insert(BanditClan.DesperateCitizen.Outfits, "Generic02")
table.insert(BanditClan.DesperateCitizen.Outfits, "Generic01")
table.insert(BanditClan.DesperateCitizen.Outfits, "Punk")
table.insert(BanditClan.DesperateCitizen.Outfits, "Rocker")
table.insert(BanditClan.DesperateCitizen.Outfits, "Tourist")

if getActivatedMods():contains("Authentic Z - Current") then
    table.insert(BanditClan.DesperateCitizen.Outfits, "AuthenticHomeless")
    table.insert(BanditClan.DesperateCitizen.Outfits, "AuthenticElderly")
    table.insert(BanditClan.DesperateCitizen.Outfits, "AuthenticSurvivorCovid")
end

-- available melee weapons
BanditClan.DesperateCitizen.Melee = BanditClan.DesperateCitizen.Melee or {}
table.insert(BanditClan.DesperateCitizen.Melee, "Base.BreadKnife")
table.insert(BanditClan.DesperateCitizen.Melee, "Base.Pan")
table.insert(BanditClan.DesperateCitizen.Melee, "Base.RollingPin")
table.insert(BanditClan.DesperateCitizen.Melee, "Base.SmashedBottle")
table.insert(BanditClan.DesperateCitizen.Melee, "Base.HandScythe")
table.insert(BanditClan.DesperateCitizen.Melee, "Base.WoodenLance")
table.insert(BanditClan.DesperateCitizen.Melee, "Base.Banjo")
table.insert(BanditClan.DesperateCitizen.Melee, "Base.ChairLeg")
table.insert(BanditClan.DesperateCitizen.Melee, "Base.GardenFork")
table.insert(BanditClan.DesperateCitizen.Melee, "Base.GridlePan")
table.insert(BanditClan.DesperateCitizen.Melee, "Base.Hammer")
table.insert(BanditClan.DesperateCitizen.Melee, "Base.HockeyStick")
table.insert(BanditClan.DesperateCitizen.Melee, "Base.MetalPipe")
table.insert(BanditClan.DesperateCitizen.Melee, "Base.PipeWrench")
table.insert(BanditClan.DesperateCitizen.Melee, "Base.Plunger")
table.insert(BanditClan.DesperateCitizen.Melee, "Base.GuitarElectricRed")
table.insert(BanditClan.DesperateCitizen.Melee, "Base.Saucepan")
table.insert(BanditClan.DesperateCitizen.Melee, "Base.TableLeg")
table.insert(BanditClan.DesperateCitizen.Melee, "Base.Wrench")

-- available primary weapons
BanditClan.DesperateCitizen.Primary = BanditClan.DesperateCitizen.Primary or BanditWeapons.Primary

-- available secondary weapons
BanditClan.DesperateCitizen.Secondary = BanditClan.DesperateCitizen.Secondary or BanditWeapons.Secondary

-- loot table
BanditClan.DesperateCitizen.Loot = BanditClan.DesperateCitizen.Loot or {}
table.insert(BanditClan.DesperateCitizen.Loot, BanditLoot.MakeItem("Base.WaterBottleFull", 30))
table.insert(BanditClan.DesperateCitizen.Loot, BanditLoot.MakeItem("Base.Gum", 5))
table.insert(BanditClan.DesperateCitizen.Loot, BanditLoot.MakeItem("Base.Peppermint", 2))
table.insert(BanditClan.DesperateCitizen.Loot, BanditLoot.MakeItem("Base.GummyWorms", 1))
table.insert(BanditClan.DesperateCitizen.Loot, BanditLoot.MakeItem("Base.Jujubes", 1))
table.insert(BanditClan.DesperateCitizen.Loot, BanditLoot.MakeItem("Base.HiHis", 1))
table.insert(BanditClan.DesperateCitizen.Loot, BanditLoot.MakeItem("Base.CandyFruitSlices", 1))
table.insert(BanditClan.DesperateCitizen.Loot, BanditLoot.MakeItem("Base.Crisps", 1))
table.insert(BanditClan.DesperateCitizen.Loot, BanditLoot.MakeItem("Base.Crisps2", 1))
table.insert(BanditClan.DesperateCitizen.Loot, BanditLoot.MakeItem("Base.Crisps3", 1))

-- register this clan for spawn system
BanditCreator.ClanMap = BanditCreator.GroupMap or {}
BanditCreator.ClanMap[1] = BanditClan.DesperateCitizen
