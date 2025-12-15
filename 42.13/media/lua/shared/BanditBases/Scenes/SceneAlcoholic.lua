BanditScenes = BanditScenes or {}

function BanditScenes.Alcoholic (player, square)
    local cell = getCell()

    local sx = square:getX()
    local sy = square:getY()
    local sz = square:getZ()

    local w = 6
    local h = 6

    local items = {}

    BanditBaseGroupPlacements.ClearSpace(sx-2, sy-2, 0, w+4, h+4)
    BanditBaseGroupPlacements.Junk (sx-4, sy-4, 0, w+8, h+8, 12)
    BanditBaseGroupPlacements.Junk (sx, sy, 0, w, h, 40)

    BanditProc.HouseSmall(sx, sy, sz)

    items = {"5xBase.WhiskeyFull","22xBase.WineEmpty", "1xBase.Wine", "2xBase.Wine2"}
    BanditBasePlacements.Container ("fixtures_counters_01_10", sx + 1, sy + 5, sz + 0, items)

    items = {"29xBase.WineEmpty", "1xBase.Wine"}
    BanditBasePlacements.Container ("fixtures_counters_01_9", sx + 2, sy + 5, sz + 0, items)
	BanditBasePlacements.IsoObject ("fixtures_sinks_01_19", sx + 2, sy + 5, sz + 0)

    BanditBaseGroupPlacements.Item("Base.WineEmpty", sx, sy, 0, 4, 4, 60)
    BanditBaseGroupPlacements.Item("Base.BeerCanEmpty", sx, sy, 0, 4, 4, 80)

    BanditBasePlacements.WaterContainer ("carpentry_02_52", sx + 6, sy + 5, sz + 0)
    BanditBasePlacements.IsoGenerator ("", sx + 5, sy + 6, sz + 0)

    BanditBasePlacements.IsoLightSwitch("lighting_indoor_01_34", sx+1, sy+3, sz)
   
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
    config.hasPistolChance = 20
    config.rifleMagCount = 0
    config.pistolMagCount = 0

    local bandit = BanditCreator.MakeHockey(config)
    table.insert(event.bandits, bandit)
    table.insert(event.bandits, bandit)

    sendClientCommand(player, 'Commands', 'SpawnGroup', event)

end