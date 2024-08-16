-- register modded loot items by adding them to tables below

BanditLoot = BanditLoot or {}

BanditLoot.MakeItem = function(name, chance, quantity) 
    local item = {}
    item.name = name
    item.chance = chance
    return item
end

BanditLoot.FillContainer = function(container, itemTab, itemNo)
    for k, v in pairs(itemTab) do
        local r = ZombRand(101)
        if r <= v.chance then
            for i=0, ZombRand(itemNo) do
                --container:AddItem(v.name)
                -- local item = InventoryItemFactory.CreateItem(v.name)
                -- container:addItem(item)

                local item = container:AddItem(v.name)
                if item then
                    container:addItemOnServer(item)
                end
            end
        end
    end
end

BanditLoot.Items = BanditLoot.Items or {}

-- BANDIT INVENTORY LOOT
-- essentials
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.WaterBottleFull", 80))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.TinOpener", 11))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.Hammer", 20))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.Wrench", 20))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.PipeWrench", 10))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.Scissors", 10))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.Screwdriver", 22))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.Spoon", 40))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.Pencil", 35))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.WeldingMask", 2))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.BlowTorch", 2))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.Needle", 5))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.Soap", 8))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.Molotov", 1))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.PipeBomb", 1))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.Bandage", 21))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.Pills", 9))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.Lighter", 21))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.HolsterSimple", 11))

table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.Cigarettes", 33))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.Cigarettes", 33))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.Cigarettes", 33))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.Cigarettes", 33))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.Cigarettes", 33))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.Cigarettes", 33))

-- food items
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.TinnedBeans", 1))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.CannedCarrots2", 1))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.CannedChili", 1))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.CannedCorn", 1))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.CannedCornedBeef", 1))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.CannedFruitCocktail", 1))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.CannedMushroomSoup", 1))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.CannedPeaches", 1))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.CannedPeas", 1))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.CannedPineapple", 1))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.CannedPotato2", 1))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.CannedSardines", 1))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.TinnedSoup", 1))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.CannedBolognese", 1))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.CannedTomato2", 1))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.TunaTin", 1))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.Salami", 1))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.Apple", 2))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.Pear", 2))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.Cherry", 1))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.Grapes", 1))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.Onion", 1))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.MushroomGeneric1", 1))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.MushroomGeneric2", 1))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("farming.RedRadish", 1))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("farming.Potato", 1))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("farming.Cabbage", 1))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.CannedBroccoli", 1))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.CannedCabbage", 1))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.CannedCarrots", 1))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.CannedPotato", 1))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.CannedTomato", 1))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.CannedEggplant", 1))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.CannedBellPepper", 1))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.BeerCan", 2))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.WhiskeyFull", 3))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.JamFruit", 1))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.Coffee2", 4))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.Teabag2", 4))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.Gum", 2))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.Peppermint", 1))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.GummyWorms", 1))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.Jujubes", 1))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.HiHis", 1))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.CandyFruitSlices", 1))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.Crisps", 1))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.Crisps2", 1))
table.insert(BanditLoot.Items, BanditLoot.MakeItem("Base.Crisps3", 1))

-- valuables

-- BANDIT BASE LOOT
BanditLoot.FridgeItems = BanditLoot.FridgeItems or {}
table.insert(BanditLoot.FridgeItems, BanditLoot.MakeItem("Base.RedRadish", 15))
table.insert(BanditLoot.FridgeItems, BanditLoot.MakeItem("Base.Potato", 45))
table.insert(BanditLoot.FridgeItems, BanditLoot.MakeItem("Base.Leek", 25))
table.insert(BanditLoot.FridgeItems, BanditLoot.MakeItem("Base.Onion", 25))
table.insert(BanditLoot.FridgeItems, BanditLoot.MakeItem("farming.Cabbage", 25))
table.insert(BanditLoot.FridgeItems, BanditLoot.MakeItem("Base.Broccoli", 15))
table.insert(BanditLoot.FridgeItems, BanditLoot.MakeItem("Base.BellPepper", 10))
table.insert(BanditLoot.FridgeItems, BanditLoot.MakeItem("Base.Lettuce", 10))
table.insert(BanditLoot.FridgeItems, BanditLoot.MakeItem("Base.Pumpkin", 8))
table.insert(BanditLoot.FridgeItems, BanditLoot.MakeItem("Base.Tomato", 31))
table.insert(BanditLoot.FridgeItems, BanditLoot.MakeItem("Base.Jalapeno", 10))
table.insert(BanditLoot.FridgeItems, BanditLoot.MakeItem("Base.Eggplant", 5))
table.insert(BanditLoot.FridgeItems, BanditLoot.MakeItem("Base.Avocado", 10))
table.insert(BanditLoot.FridgeItems, BanditLoot.MakeItem("Base.Mango", 7))
table.insert(BanditLoot.FridgeItems, BanditLoot.MakeItem("Base.MushroomGeneric3", 20))
table.insert(BanditLoot.FridgeItems, BanditLoot.MakeItem("Base.Apple", 15))
table.insert(BanditLoot.FridgeItems, BanditLoot.MakeItem("Base.Grapefruit", 15))
table.insert(BanditLoot.FridgeItems, BanditLoot.MakeItem("Base.Grapes", 18))
table.insert(BanditLoot.FridgeItems, BanditLoot.MakeItem("Base.Pear", 21))
table.insert(BanditLoot.FridgeItems, BanditLoot.MakeItem("Base.Banana", 15))
table.insert(BanditLoot.FridgeItems, BanditLoot.MakeItem("Base.Rabbitmeat", 40))
table.insert(BanditLoot.FridgeItems, BanditLoot.MakeItem("Base.FrogMeat", 10))
table.insert(BanditLoot.FridgeItems, BanditLoot.MakeItem("Base.Steak", 5))
table.insert(BanditLoot.FridgeItems, BanditLoot.MakeItem("Base.MeatPatty", 7))
table.insert(BanditLoot.FridgeItems, BanditLoot.MakeItem("Base.MuttonChop", 7))
table.insert(BanditLoot.FridgeItems, BanditLoot.MakeItem("Base.Egg", 20))
table.insert(BanditLoot.FridgeItems, BanditLoot.MakeItem("Base.Milk", 22))
table.insert(BanditLoot.FridgeItems, BanditLoot.MakeItem("Base.Cheese", 75))
table.insert(BanditLoot.FridgeItems, BanditLoot.MakeItem("Base.Yoghurt", 9))
table.insert(BanditLoot.FridgeItems, BanditLoot.MakeItem("Base.Butter", 44))
table.insert(BanditLoot.FridgeItems, BanditLoot.MakeItem("Base.BeerBottle", 66))
table.insert(BanditLoot.FridgeItems, BanditLoot.MakeItem("Base.Wine", 18))



