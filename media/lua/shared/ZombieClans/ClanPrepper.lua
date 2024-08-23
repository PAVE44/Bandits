ClanPrepper = ClanPrepper or {}

-- The unique id of the clan, ids 1-16 are reserved for waves
ClanPrepper.id = 6

-- Name of the clan
ClanPrepper.name = "Prepper"

-- % chance of a clan member to be a female. Outfit must support it.
ClanPrepper.femaleChance = 0

-- health ranges from 1 - 14. Higher values may produce unexpected results,
ClanPrepper.health = 4

-- if the bandit will eat player's body after death
ClanPrepper.EatBody = false

-- available outfits
ClanPrepper.Outfits = ClanPrepper.Outfits or {}
table.insert(ClanPrepper.Outfits, "Survivalist03")

if getActivatedMods():contains("HNDLBR_Preppers") then
    table.insert(ClanPrepper.Outfits, "HNDLBR_Prepper")
    table.insert(ClanPrepper.Outfits, "HNDLBR_DoomsDayPrepper")
end

-- available melee weapons
ClanPrepper.Melee = ClanPrepper.Melee or {}
table.insert(ClanPrepper.Melee, "Base.SpearHuntingKnife")
table.insert(ClanPrepper.Melee, "Base.WoodenLance")
table.insert(ClanPrepper.Melee, "Base.HuntingKnife")
table.insert(ClanPrepper.Melee, "Base.Machete")
table.insert(ClanPrepper.Melee, "Base.Axe")
table.insert(ClanPrepper.Melee, "Base.HandAxe")

-- available primary weapons
ClanPrepper.Primary = ClanPrepper.Primary or BanditWeapons.Primary

-- available secondary weapons
ClanPrepper.Secondary = ClanPrepper.Secondary or BanditWeapons.Secondary

-- loot table
ClanPrepper.Loot = ClanPrepper.Loot or {}
table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("Base.HandTorch", 100))
table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("Base.Battery", 88))
table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("Base.Battery", 77))
table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("Base.HandTorch", 66))
table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("camping.CampfireKit", 33))
table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("Base.Matches", 99))
table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("Base.CampingTentKit", 88))
table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("Base.HuntingKnife", 80))
table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("Radio.WalkieTalkieMakeShift", 23))
table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("Base.AlcoholBandage", 33))
table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("Base.AlcoholBandage", 33))
table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("Base.Disinfectant", 55))
table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("Base.Antibiotics", 2))
table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("Base.Pills", 2))
table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("Base.TinOpener", 11))
table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("Base.Spoon", 40))
table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("Base.Pencil", 35))
table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("Base.Saucepan", 21))
table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("Base.Scissors", 17))
table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("Base.HandAxe", 17))
table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("farming.HandShovel", 7))
table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("Base.Toothbrush", 77))
table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("Base.Toothpaste", 77))
table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("Base.Soap", 66))

table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("farming.BroccoliSeed", 2))
table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("farming.CabbageSeed", 2))
table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("farming.CarrotSeed", 2))
table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("farming.PotatoSeed", 2))
table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("farming.RedRadishSeed", 2))
table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("farming.StrewberrieSeed", 2))
table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("farming.TomatoSeed", 2))

if getActivatedMods():contains("MCM") then
    table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("MCM.AvocadoBagSeed", 2))
    table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("MCM.PepperBagSeed", 2))
    table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("MCM.CornBagSeed", 2))
    table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("MCM.EggplantBagSeed", 2))
    table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("MCM.LeekBagSeed", 2))
    table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("MCM.LettuceBagSeed", 2))
    table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("MCM.OnionBagSeed", 2))
    table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("MCM.WatermelonBagSeed", 2)) 
    table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("MCM.ZucchiniBagSeed", 2))
end

if getActivatedMods():contains("WildFruitFarming") then
    table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("FarmingBerries.BlueberryCutting", 2))
    table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("FarmingBerries.BlackberryCutting", 2))
    table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("FarmingBerries.GrapeCutting", 2))
end
if getActivatedMods():contains("FarmingTime") then
    table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("filcher.BeetBagSeed", 2))
    table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("filcher.CoffeeBagSeed", 2))
    table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("filcher.CornBagSeed", 2))
    table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("filcher.CauliflowerBagSeed", 2))
    table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("filcher.SFLemonGrassBagSeed", 2))
    table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("filcher.LettuceBagSeed", 2))
    table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("filcher.TeaBagSeed", 2))
    table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("filcher.SFWheatBagSeed", 2))
    table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("filcher.Beetroot", 5))
    table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("filcher.Cauliflower", 4))
end

table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("Base.WaterBottleFull", 99))
table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("Base.WhiskeyFull", 22))
table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("Base.DehydratedMeatStick", 7))
table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("Base.Chocolate", 5))
table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("Base.PeanutButter", 4))

table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("Base.TinnedBeans", 1))
table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("Base.CannedCarrots2", 1))
table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("Base.CannedChili", 1))
table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("Base.CannedCorn", 1))
table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("Base.CannedCornedBeef", 1))
table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("Base.CannedFruitCocktail", 1))
table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("Base.CannedMushroomSoup", 1))
table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("Base.CannedPeaches", 1))
table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("Base.CannedPeas", 1))
table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("Base.CannedPineapple", 1))
table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("Base.CannedPotato2", 1))
table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("Base.CannedSardines", 1))
table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("Base.TinnedSoup", 1))
table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("Base.CannedBolognese", 1))
table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("Base.CannedTomato2", 1))

table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("Base.TunaTin", 1))
table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("Base.Salami", 1))
table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("Base.Apple", 4))
table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("Base.Pear", 2))
table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("Base.Cherry", 2))
table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("Base.Lettuce", 1))
table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("Base.Grapes", 9))
table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("Base.Onion", 5))
table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("Base.Apple", 4))
table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("Base.MushroomGeneric1", 19))
table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("Base.MushroomGeneric2", 19))
table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("Base.BerryBlack", 5))
table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("Base.BerryBlue", 4))
table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("Base.WildEggs", 19))
table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("Base.WildGarlic", 19))
table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("Base.Frog", 19))

table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("Base.FarmingMag1", 4))
table.insert(ClanPrepper.Loot, BanditLoot.MakeItem("Base.HerbalistMag", 4))
