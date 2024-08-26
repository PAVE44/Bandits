BanditClan = BanditClan or {}

BanditClan.Criminal = BanditClan.Criminal or {}

-- The unique id of the clan, ids 1-16 are reserved for waves
BanditClan.Criminal.id = 4

-- Name of the clan
BanditClan.Criminal.name = "Criminal"

-- % chance of a clan member to be a female. Outfit must support it.
BanditClan.Criminal.femaleChance = 0

-- health ranges from 1 - 14. Higher values may produce unexpected results,
BanditClan.Criminal.health = 3

-- if the bandit will eat player's body after death
BanditClan.Criminal.eatBody = false

-- available outfits
BanditClan.Criminal.Outfits = BanditClan.Criminal.Outfits or {}
table.insert(BanditClan.Criminal.Outfits, "Thug")
table.insert(BanditClan.Criminal.Outfits, "Redneck")

if getActivatedMods():contains("Authentic Z - Current") then
    table.insert(BanditClan.Criminal.Outfits, "AuthenticBankRobber")
    table.insert(BanditClan.Criminal.Outfits, "AuthenticNMRIHMolotov")
    table.insert(BanditClan.Criminal.Outfits, "AuthenticPoncho")
end

if getActivatedMods():contains("Brita_2") then
    table.insert(BanditClan.Criminal.Outfits, "Brita_Killa_2")
end

-- available melee weapons
BanditClan.Criminal.Melee = BanditClan.Criminal.Melee or {}
table.insert(BanditClan.Criminal.Melee, "Base.Crowbar")
table.insert(BanditClan.Criminal.Melee, "Base.MetalBar")
table.insert(BanditClan.Criminal.Melee, "Base.BaseballBat")
table.insert(BanditClan.Criminal.Melee, "Base.KitchenKnife")

if getActivatedMods():contains("Authentic Z - Current") then
    table.insert(BanditClan.Criminal.Melee, "AuthenticZClothing.Chainsaw")
end

-- available primary weapons
BanditClan.Criminal.Primary = BanditClan.Criminal.Primary or BanditWeapons.Primary

-- available secondary weapons
BanditClan.Criminal.Secondary = BanditClan.Criminal.Secondary or BanditWeapons.Secondary

-- loot table
BanditClan.Criminal.Loot = BanditClan.Criminal.Loot or {}
table.insert(BanditClan.Criminal.Loot, BanditLoot.MakeItem("Base.WaterBottleFull", 30))
table.insert(BanditClan.Criminal.Loot, BanditLoot.MakeItem("Base.Crowbar", 77))
table.insert(BanditClan.Criminal.Loot, BanditLoot.MakeItem("Base.Hammer", 33))
table.insert(BanditClan.Criminal.Loot, BanditLoot.MakeItem("Base.Saw", 3))
table.insert(BanditClan.Criminal.Loot, BanditLoot.MakeItem("Base.WeldingMask", 4))
table.insert(BanditClan.Criminal.Loot, BanditLoot.MakeItem("Base.BlowTorch", 4))
table.insert(BanditClan.Criminal.Loot, BanditLoot.MakeItem("Base.Jack", 5)) 
table.insert(BanditClan.Criminal.Loot, BanditLoot.MakeItem("Base.LugWrench", 5))
table.insert(BanditClan.Criminal.Loot, BanditLoot.MakeItem("Base.Wrench", 6))
table.insert(BanditClan.Criminal.Loot, BanditLoot.MakeItem("Base.Screwdriver", 6))
table.insert(BanditClan.Criminal.Loot, BanditLoot.MakeItem("Base.IcePick", 13))
table.insert(BanditClan.Criminal.Loot, BanditLoot.MakeItem("Base.HandTorch", 100))
table.insert(BanditClan.Criminal.Loot, BanditLoot.MakeItem("Base.TinOpener", 11))
table.insert(BanditClan.Criminal.Loot, BanditLoot.MakeItem("Base.Wrench", 6))
table.insert(BanditClan.Criminal.Loot, BanditLoot.MakeItem("Base.Screwdriver", 6))

table.insert(BanditClan.Criminal.Loot, BanditLoot.MakeItem("Base.TinnedBeans", 2))
table.insert(BanditClan.Criminal.Loot, BanditLoot.MakeItem("Base.CannedCarrots2", 2))
table.insert(BanditClan.Criminal.Loot, BanditLoot.MakeItem("Base.CannedChili", 2))
table.insert(BanditClan.Criminal.Loot, BanditLoot.MakeItem("Base.CannedCorn", 2))
table.insert(BanditClan.Criminal.Loot, BanditLoot.MakeItem("Base.CannedCornedBeef", 2))
table.insert(BanditClan.Criminal.Loot, BanditLoot.MakeItem("Base.CannedFruitCocktail", 2))
table.insert(BanditClan.Criminal.Loot, BanditLoot.MakeItem("Base.CannedMushroomSoup", 2))
table.insert(BanditClan.Criminal.Loot, BanditLoot.MakeItem("Base.CannedPeaches", 2))
table.insert(BanditClan.Criminal.Loot, BanditLoot.MakeItem("Base.CannedPeas", 2))
table.insert(BanditClan.Criminal.Loot, BanditLoot.MakeItem("Base.CannedPineapple", 2))
table.insert(BanditClan.Criminal.Loot, BanditLoot.MakeItem("Base.CannedPotato2", 2))
table.insert(BanditClan.Criminal.Loot, BanditLoot.MakeItem("Base.CannedSardines", 2))
table.insert(BanditClan.Criminal.Loot, BanditLoot.MakeItem("Base.TinnedSoup", 2))
table.insert(BanditClan.Criminal.Loot, BanditLoot.MakeItem("Base.CannedBolognese", 2))
table.insert(BanditClan.Criminal.Loot, BanditLoot.MakeItem("Base.CannedTomato2", 2))
table.insert(BanditClan.Criminal.Loot, BanditLoot.MakeItem("Base.CannedBroccoli", 1))
table.insert(BanditClan.Criminal.Loot, BanditLoot.MakeItem("Base.CannedCabbage", 1))
table.insert(BanditClan.Criminal.Loot, BanditLoot.MakeItem("Base.CannedCarrots", 1))
table.insert(BanditClan.Criminal.Loot, BanditLoot.MakeItem("Base.CannedPotato", 1))
table.insert(BanditClan.Criminal.Loot, BanditLoot.MakeItem("Base.CannedTomato", 1))
table.insert(BanditClan.Criminal.Loot, BanditLoot.MakeItem("Base.CannedEggplant", 1))
table.insert(BanditClan.Criminal.Loot, BanditLoot.MakeItem("Base.CannedBellPepper", 1))

for i=1, 37 do
    table.insert(BanditClan.Criminal.Loot, BanditLoot.MakeItem("Base.Money", 66))
end

for i=1, 4  do
    table.insert(BanditClan.Criminal.Loot, BanditLoot.MakeItem("Base.Ring_Right_MiddleFinger_GoldDiamond", 77))
    table.insert(BanditClan.Criminal.Loot, BanditLoot.MakeItem("Base.Ring_Left_MiddleFinger_GoldDiamond", 66))
    table.insert(BanditClan.Criminal.Loot, BanditLoot.MakeItem("Base.Ring_Right_RingFinger_GoldDiamond", 77))
    table.insert(BanditClan.Criminal.Loot, BanditLoot.MakeItem("Base.Ring_Left_RingFinger_GoldDiamond", 72))
    table.insert(BanditClan.Criminal.Loot, BanditLoot.MakeItem("Base.Ring_Right_MiddleFinger_Gold", 91))
    table.insert(BanditClan.Criminal.Loot, BanditLoot.MakeItem("Base.Ring_Left_MiddleFinger_Gold", 55))
    table.insert(BanditClan.Criminal.Loot, BanditLoot.MakeItem("Base.Ring_Right_RingFinger_Gold", 65))
    table.insert(BanditClan.Criminal.Loot, BanditLoot.MakeItem("Base.Ring_Left_RingFinger_Gold", 73))
    table.insert(BanditClan.Criminal.Loot, BanditLoot.MakeItem("Base.Necklace_Gold", 69))
    table.insert(BanditClan.Criminal.Loot, BanditLoot.MakeItem("Base.Necklace_GoldRuby", 87))
    table.insert(BanditClan.Criminal.Loot, BanditLoot.MakeItem("Base.Necklace_GoldDiamond", 65))
    table.insert(BanditClan.Criminal.Loot, BanditLoot.MakeItem("Base.NecklaceLong_GoldDiamond", 47))
    table.insert(BanditClan.Criminal.Loot, BanditLoot.MakeItem("Base.Bracelet_ChainRightGold", 66))
    table.insert(BanditClan.Criminal.Loot, BanditLoot.MakeItem("Base.Bracelet_ChainLeftGold", 55))
    table.insert(BanditClan.Criminal.Loot, BanditLoot.MakeItem("Base.Bracelet_BangleRightGold", 37))
    table.insert(BanditClan.Criminal.Loot, BanditLoot.MakeItem("Base.Bracelet_BangleLeftGold", 39))
    table.insert(BanditClan.Criminal.Loot, BanditLoot.MakeItem("Base.WristWatch_Left_ClassicGold", 99))
    table.insert(BanditClan.Criminal.Loot, BanditLoot.MakeItem("Base.WristWatch_Left_ClassicGold", 88))
    table.insert(BanditClan.Criminal.Loot, BanditLoot.MakeItem("Base.WristWatch_Left_ClassicGold", 77))
end

-- register this clan for spawn system
BanditCreator.ClanMap = BanditCreator.GroupMap or {}
BanditCreator.ClanMap[4] = BanditClan.Criminal
