BanditScenes = BanditScenes or {}

function BanditScenes.Cannibal (player, square)
    local cell = getCell()

    local sx = square:getX()
    local sy = square:getY()
    local sz = square:getZ()

    local w = 16
    local h = 16

    local items = {}
    local itemsFreeze = {}

    BanditBaseGroupPlacements.ClearSpace(sx-2, sy-2, 0, w+4, h+4)

    BanditBasePlacements.IsoGenerator ("", sx + 4, sy + 2, sz + 0)
    BanditBasePlacements.WaterContainer ("carpentry_02_52", sx + 5, sy + 2, sz)

    BanditBaseGroupPlacements.Junk (sx-4, sy-4, 0, w+8, h+8, 6)

    BanditProc.Toilet(sx, sy, sz)

    items = {"12xBase.ToiletPaper"}
    BanditBasePlacements.Container ("fixtures_counters_01_13", sx + 2, sy + 1, sz + 0, items)

    BanditProc.HouseMedium(sx+6, sy, sz)
    BanditBasePlacements.IsoObject("industry_02_152", sx+7, sy+1, sz)
    BanditBasePlacements.IsoObject("industry_02_154", sx+7, sy+2, sz)
    BanditBasePlacements.Container ("fixtures_counters_01_35", sx + 7, sy + 3, sz + 0, {})
    
    BanditBasePlacements.Container ("fixtures_counters_01_35", sx + 7, sy + 4, sz + 0, {})
    BanditBasePlacements.IsoObject("fixtures_sinks_01_16", sx+7, sy+4, sz)
    BanditBasePlacements.Container ("fixtures_counters_01_35", sx + 7, sy + 5, sz + 0, {})
    items = {"2xBase.Steak", "2xBase.Bacon"}
    itemsFreeze = {"25xBase.Steak", "14xBase.MeatPatty", "18xBase.Bacon"}
    BanditBasePlacements.Fridge("appliances_refrigeration_01_40", sx+8, sy+1, sz, items, itemsFreeze)

    items = {"1xBase.Ham", "2xBase.Pepperoni"}
    itemsFreeze = {"16xBase.Ham", "8xBase.Salami", "12xBase.Baloney", "16xBase.Pepperoni"}
    BanditBasePlacements.Fridge("appliances_refrigeration_01_40", sx+9, sy+1, sz, items, itemsFreeze)

    BanditBasePlacements.IsoObject("location_community_medical_01_76", sx + 9, sy + 5, sz)
    BanditBasePlacements.IsoObject("location_community_medical_01_77", sx + 10, sy + 5, sz)

    BanditBaseGroupPlacements.Blood(sx+6, sy+1, sz, 4, 5, 90)

    BanditBaseGroupPlacements.Item("Base.KitchenKnife", sx+6, sy + 2, sz, 1, 3, 100)
    BanditBaseGroupPlacements.Item("Base.MeatCleaver", sx+6, sy + 2, sz, 1, 3, 100)
    BanditBasePlacements.Item("Base.Saw", sx + 7, sy + 3, sz, 1)
    BanditBasePlacements.Item("Base.MeatCleaver", sx+ 7, sy + 3, sz, 2)
    BanditBasePlacements.Item("Base.Steak", sx+ 7, sy + 3, sz, 1)

    items = {"1xBase.Fork", "2xBase.Plate", "7xBase.WildGarlic2", "1xBase.Spoon"}
    BanditBasePlacements.Container ("fixtures_counters_01_13", sx + 12, sy + 1, sz + 0, items)

    BanditBasePlacements.Item("Base.Pot", sx + 13, sy + 3, sz, 1)
    BanditBasePlacements.Item("Base.Spoon", sx + 13, sy + 3, sz, 1)
    BanditBasePlacements.Item("Base.Fork", sx + 12, sy + 3, sz, 1)
    BanditBasePlacements.Item("Base.KitchenKnife", sx + 12, sy + 3, sz, 1)
    BanditBasePlacements.Item("Base.Plate", sx + 12, sy + 3, sz, 1)
    BanditBasePlacements.Item("Base.Salt", sx + 12, sy + 3, sz, 1)
    BanditBasePlacements.Item("Base.Steak", sx+ 12, sy + 3, sz, 2)

    items = {}
    BanditBasePlacements.Container ("furniture_shelving_01_23", sx + 11, sy + 5, sz + 0, items)

    BanditBasePlacements.Body (sx+8, sy+4, 0, 3)
    
    BanditBasePlacements.Body (sx+8, sy+11, 0, 2)
    BanditBasePlacements.Body (sx+8, sy+12, 0, 4)
    BanditBasePlacements.Body (sx+8, sy+13, 0, 2)
    BanditBasePlacements.Body (sx+7, sy+12, 0, 2)
    BanditBasePlacements.Body (sx+9, sy+12, 0, 2)

    local event = {}
    event.x = sx
    event.y = sy
    event.z = sz
    event.name = "CannibalBase"
    event.hostile = true
    event.occured = false
    event.program = "BaseGuard"
    event.bandits = {}

    config = {}
    config.hasRifleChance = 0
    config.hasPistolChance = 0
    config.rifleMagCount = 0
    config.pistolMagCount = 0

    local bandit = BanditCreator.MakeHockey(config)
    table.insert(event.bandits, bandit)
    table.insert(event.bandits, bandit)
    table.insert(event.bandits, bandit)
    table.insert(event.bandits, bandit)

    sendClientCommand(player, 'Commands', 'SpawnGroup', event)
    
end
