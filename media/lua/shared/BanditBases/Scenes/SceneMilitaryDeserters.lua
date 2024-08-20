BanditScenes = BanditScenes or {}

function BanditScenes.MilitaryDeserters (player, square)
    local cell = getCell()

    local sx = square:getX()
    local sy = square:getY()
    local sz = square:getZ()

    local w = 16
    local h = 16
    
    local items = {}
    
    BanditBaseGroupPlacements.ClearSpace(sx-1, sy-1, 0, w+2, h+2)
    BanditProc.MilitaryTent(sx, sy, sz)
    BanditProc.MilitaryTent(sx, sy + 10, sz)
    BanditProc.MilitaryField(sx + 8, sy, sz)

    BanditBasePlacements.IsoGenerator("", sx+1, sy+7, sz)
    BanditBasePlacements.IsoLightSwitch("lighting_outdoor_01_48", sx+4, sy+8, sz)
    BanditBasePlacements.IsoLightSwitch("lighting_outdoor_01_48", sx+4, sy+18, sz)
    
    BanditBasePlacements.WaterContainer("carpentry_02_52", sx+11, sy+14, sz)
    -- BanditBasePlacements.Fireplace("camping_01_6", sx+13, sy+11, sz)
    BanditBasePlacements.Item ("Base.Pot", sx+13, sy+11, sz, sz)

    local container
    container = BanditBasePlacements.Container("furniture_storage_02_29", sx+3, sy+1, sz)
    BanditLoot.FillContainer(container, BanditLoot.Items, 12)

    container = BanditBasePlacements.Container("furniture_storage_02_29", sx+3, sy+11, sz)
    BanditLoot.FillContainer(container, BanditLoot.Items, 12)

    container = BanditBasePlacements.Container("location_military_generic_01_1", sx+10, sy+12, sz)
    BanditLoot.FillContainer(container, BanditLoot.Items, 12)

    container = BanditBasePlacements.Container("location_military_generic_01_1", sx+11, sy+12, sz)
    BanditLoot.FillContainer(container, BanditLoot.Items, 12)

    local event = {}
    event.x = sx + 10
    event.y = sy + 10
    event.z = sz
    event.name = "MilitaryBase"
    event.hostile = true
    event.occured = false
    event.program = "BaseGuard"
    event.bandits = {}

    config = {}
    config.hasRifleChance = 100
    config.hasPistolChance = 100
    config.rifleMagCount = 6
    config.pistolMagCount = 4

    local bandit = BanditCreator.MakeVeteran(config)
    table.insert(event.bandits, bandit)
    table.insert(event.bandits, bandit)
    table.insert(event.bandits, bandit)
    table.insert(event.bandits, bandit)
    table.insert(event.bandits, bandit)
    table.insert(event.bandits, bandit)

    sendClientCommand(player, 'Commands', 'SpawnGroup', event)

end