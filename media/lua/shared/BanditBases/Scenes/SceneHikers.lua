BanditScenes = BanditScenes or {}

function BanditScenes.Hikers (player, square)
    local cell = getCell()

    local sx = square:getX()
    local sy = square:getY()
    local sz = square:getZ()

    local w = 6
    local h = 6

    local items = {}
    local itemsFreeze = {}

    BanditBaseGroupPlacements.ClearSpace(sx-2, sy-2, 0, w+4, h+4)

    BanditProc.CampTentSmall(sx, sy, sz)

    -- BanditBasePlacements.Fireplace("camping_01_6", sx+4, sy+4, sz)
    BanditBasePlacements.Item ("Base.Pot", sx+4, sy+4, sz, 1)

    local container
    container = BanditBasePlacements.Container ("furniture_storage_02_28", sx + 1, sy + 2, sz + 0)
    BanditLoot.FillContainer(container, BanditLoot.Items, 10)

    container = BanditBasePlacements.Container ("trashcontainers_01_27", sx + 7, sy + 1, sz + 0)
    BanditLoot.FillContainer(container, BanditLoot.Items, 14)

	container = BanditBasePlacements.Container ("trashcontainers_01_26", sx + 7, sy + 2, sz + 0)
    BanditLoot.FillContainer(container, BanditLoot.Items, 14)

    -- BanditBasePlacements.IsoLightSwitch ("lighting_outdoor_01_48", sx + 1, sy + 6, sz + 0)

    local event = {}
    event.name = "HikersBase"
    event.hostile = true
    event.occured = false
    event.program = {}
    event.program.name = "BaseGuard"

    local gameTime = getGameTime()
    local hour = gameTime:getHour() 
    if gameTime:getHour() >= 0 and gameTime:getHour() < 7 then
        event.program.stage = "Sleep"
    else
        event.program.stage = "Wait"
    end

    event.bandits = {}

    config = {}
    config.hasRifleChance = 80
    config.hasPistolChance = 80
    config.rifleMagCount = 3
    config.pistolMagCount = 4

    local bandit = BanditCreator.MakeSurvivalist(config)
    event.bandits = {bandit}
    event.x = sx+5 
    event.y = sy+4
    event.z = sz
    sendClientCommand(player, 'Commands', 'SpawnGroup', event)

    local bandit = BanditCreator.MakeSurvivalist(config)
    event.bandits = {bandit}
    event.x = sx+3
    event.y = sy+5
    event.z = sz
    sendClientCommand(player, 'Commands', 'SpawnGroup', event)

    local bandit = BanditCreator.MakeSurvivalist(config)
    event.bandits = {bandit}
    event.x = sx+3
    event.y = sy+2
    event.z = sz
    sendClientCommand(player, 'Commands', 'SpawnGroup', event)

end