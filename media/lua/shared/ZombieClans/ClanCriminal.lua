ClanCriminal = ClanCriminal or {}

-- The unique id of the clan, ids 1-16 are reserved for waves
ClanCriminal.id = 4

-- Name of the clan
ClanCriminal.name = "Criminal"

-- % chance of a clan member to be a female. Outfit must support it.
ClanCriminal.femaleChance = 0

-- health ranges from 1 - 14. Higher values may produce unexpected results,
ClanCriminal.health = 3

-- if the bandit will eat player's body after death
ClanCriminal.EatBody = false

-- available outfits
ClanCriminal.Outfits = ClanCriminal.Outfits or {}
table.insert(ClanCriminal.Outfits, "Thug")
table.insert(ClanCriminal.Outfits, "Redneck")

if getActivatedMods():contains("Authentic Z - Current") then
    table.insert(ClanCriminal.Outfits, "AuthenticBankRobber")
    table.insert(ClanCriminal.Outfits, "AuthenticNMRIHMolotov")
    table.insert(ClanCriminal.Outfits, "AuthenticPoncho")
end

if getActivatedMods():contains("Brita_2") then
    table.insert(ClanCriminal.Outfits, "Brita_Killa_2")
end

-- available melee weapons
ClanCriminal.Melee = ClanCriminal.Melee or {}
table.insert(ClanCriminal.Melee, "Base.Crowbar")
table.insert(ClanCriminal.Melee, "Base.MetalBar")
table.insert(ClanCriminal.Melee, "Base.BaseballBat")
table.insert(ClanCriminal.Melee, "Base.KitchenKnife")

if getActivatedMods():contains("Authentic Z - Current") then
    table.insert(ClanCriminal.Melee, "AuthenticZClothing.Chainsaw")
end

-- available primary weapons
ClanCriminal.Primary = ClanCriminal.Primary or BanditWeapons.Primary

-- available secondary weapons
ClanCriminal.Secondary = ClanCriminal.Secondary or BanditWeapons.Secondary

-- loot table
ClanCriminal.Loot = ClanCriminal.Loot or {}
table.insert(ClanCriminal.Loot, BanditLoot.MakeItem("Base.WaterBottleFull", 30))
table.insert(ClanCriminal.Loot, BanditLoot.MakeItem("Base.Crowbar", 77))
table.insert(ClanCriminal.Loot, BanditLoot.MakeItem("Base.Hammer", 33))
table.insert(ClanCriminal.Loot, BanditLoot.MakeItem("Base.Saw", 3))
table.insert(ClanCriminal.Loot, BanditLoot.MakeItem("Base.WeldingMask", 4))
table.insert(ClanCriminal.Loot, BanditLoot.MakeItem("Base.BlowTorch", 4))
table.insert(ClanCriminal.Loot, BanditLoot.MakeItem("Base.Jack", 5)) 
table.insert(ClanCriminal.Loot, BanditLoot.MakeItem("Base.LugWrench", 5))
table.insert(ClanCriminal.Loot, BanditLoot.MakeItem("Base.Wrench", 6))
table.insert(ClanCriminal.Loot, BanditLoot.MakeItem("Base.Screwdriver", 6))
table.insert(ClanCriminal.Loot, BanditLoot.MakeItem("Base.IcePick", 13))
table.insert(ClanCriminal.Loot, BanditLoot.MakeItem("Base.HandTorch", 100))
table.insert(ClanCriminal.Loot, BanditLoot.MakeItem("Base.TinOpener", 11))
table.insert(ClanCriminal.Loot, BanditLoot.MakeItem("Base.Wrench", 6))
table.insert(ClanCriminal.Loot, BanditLoot.MakeItem("Base.Screwdriver", 6))

table.insert(ClanCriminal.Loot, BanditLoot.MakeItem("Base.TinnedBeans", 2))
table.insert(ClanCriminal.Loot, BanditLoot.MakeItem("Base.CannedCarrots2", 2))
table.insert(ClanCriminal.Loot, BanditLoot.MakeItem("Base.CannedChili", 2))
table.insert(ClanCriminal.Loot, BanditLoot.MakeItem("Base.CannedCorn", 2))
table.insert(ClanCriminal.Loot, BanditLoot.MakeItem("Base.CannedCornedBeef", 2))
table.insert(ClanCriminal.Loot, BanditLoot.MakeItem("Base.CannedFruitCocktail", 2))
table.insert(ClanCriminal.Loot, BanditLoot.MakeItem("Base.CannedMushroomSoup", 2))
table.insert(ClanCriminal.Loot, BanditLoot.MakeItem("Base.CannedPeaches", 2))
table.insert(ClanCriminal.Loot, BanditLoot.MakeItem("Base.CannedPeas", 2))
table.insert(ClanCriminal.Loot, BanditLoot.MakeItem("Base.CannedPineapple", 2))
table.insert(ClanCriminal.Loot, BanditLoot.MakeItem("Base.CannedPotato2", 2))
table.insert(ClanCriminal.Loot, BanditLoot.MakeItem("Base.CannedSardines", 2))
table.insert(ClanCriminal.Loot, BanditLoot.MakeItem("Base.TinnedSoup", 2))
table.insert(ClanCriminal.Loot, BanditLoot.MakeItem("Base.CannedBolognese", 2))
table.insert(ClanCriminal.Loot, BanditLoot.MakeItem("Base.CannedTomato2", 2))
table.insert(ClanCriminal.Loot, BanditLoot.MakeItem("Base.CannedBroccoli", 1))
table.insert(ClanCriminal.Loot, BanditLoot.MakeItem("Base.CannedCabbage", 1))
table.insert(ClanCriminal.Loot, BanditLoot.MakeItem("Base.CannedCarrots", 1))
table.insert(ClanCriminal.Loot, BanditLoot.MakeItem("Base.CannedPotato", 1))
table.insert(ClanCriminal.Loot, BanditLoot.MakeItem("Base.CannedTomato", 1))
table.insert(ClanCriminal.Loot, BanditLoot.MakeItem("Base.CannedEggplant", 1))
table.insert(ClanCriminal.Loot, BanditLoot.MakeItem("Base.CannedBellPepper", 1))

for i=1, 27 do
    table.insert(ClanCriminal.Loot, BanditLoot.MakeItem("Base.Money", 66))
end

table.insert(ClanCriminal.Loot, BanditLoot.MakeItem("Base.Ring_Right_MiddleFinger_GoldDiamond", 77))
table.insert(ClanCriminal.Loot, BanditLoot.MakeItem("Base.Ring_Left_MiddleFinger_GoldDiamond", 77))
table.insert(ClanCriminal.Loot, BanditLoot.MakeItem("Base.Ring_Right_RingFinger_GoldDiamond", 77))
table.insert(ClanCriminal.Loot, BanditLoot.MakeItem("Base.Ring_Left_RingFinger_GoldDiamond", 77))
table.insert(ClanCriminal.Loot, BanditLoot.MakeItem("Base.Ring_Right_MiddleFinger_Gold", 77))
table.insert(ClanCriminal.Loot, BanditLoot.MakeItem("Base.Ring_Left_MiddleFinger_Gold", 77))
table.insert(ClanCriminal.Loot, BanditLoot.MakeItem("Base.Ring_Right_RingFinger_Gold", 77))
table.insert(ClanCriminal.Loot, BanditLoot.MakeItem("Base.Ring_Left_RingFinger_Gold", 77))
table.insert(ClanCriminal.Loot, BanditLoot.MakeItem("Base.Necklace_Gold", 77))
table.insert(ClanCriminal.Loot, BanditLoot.MakeItem("Base.Necklace_GoldRuby", 77))
table.insert(ClanCriminal.Loot, BanditLoot.MakeItem("Base.Necklace_GoldDiamond", 77))
table.insert(ClanCriminal.Loot, BanditLoot.MakeItem("Base.NecklaceLong_GoldDiamond", 77))
table.insert(ClanCriminal.Loot, BanditLoot.MakeItem("Base.Bracelet_ChainRightGold", 77))
table.insert(ClanCriminal.Loot, BanditLoot.MakeItem("Base.Bracelet_ChainLeftGold", 77))
table.insert(ClanCriminal.Loot, BanditLoot.MakeItem("Base.Bracelet_BangleRightGold", 7))
table.insert(ClanCriminal.Loot, BanditLoot.MakeItem("Base.Bracelet_BangleLeftGold ", 77))
table.insert(ClanCriminal.Loot, BanditLoot.MakeItem("Base.WristWatch_Left_ClassicGold", 99))
table.insert(ClanCriminal.Loot, BanditLoot.MakeItem("Base.WristWatch_Left_ClassicGold", 88))
table.insert(ClanCriminal.Loot, BanditLoot.MakeItem("Base.WristWatch_Left_ClassicGold", 77))
