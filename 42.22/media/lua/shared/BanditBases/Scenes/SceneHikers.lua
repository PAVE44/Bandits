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

    local lootAmount = SandboxVars.Bandits.General_DefenderLootAmount - 1
    local container
    container = BanditBasePlacements.Container ("furniture_storage_02_28", sx + 1, sy + 2, sz + 0)
    BanditLoot.FillContainer(container, BanditLoot.Ammo, lootAmount)

    container = BanditBasePlacements.Container ("trashcontainers_01_27", sx + 7, sy + 1, sz + 0)
    BanditLoot.FillContainer(container, BanditLoot.CannedFoodItems, lootAmount)

	container = BanditBasePlacements.Container ("trashcontainers_01_26", sx + 7, sy + 2, sz + 0)
    BanditLoot.FillContainer(container, BanditLoot.Ammo, lootAmount)

    -- BanditBasePlacements.IsoLightSwitch ("lighting_outdoor_01_48", sx + 1, sy + 6, sz + 0)

    local event = {}
    event.hostile = true
    event.occured = false
    event.program = {}
    event.program.name = "BaseGuard"
    event.program.stage = "Prepare"
    event.bandits = {}

    config = {}
    config.clanId = 13
    config.hasRifleChance = 90
    config.hasPistolChance = 100
    config.rifleMagCount = 3
    config.pistolMagCount = 4

    local bandit = BanditCreator.MakeFromWave(config)
    event.bandits = {bandit}
    event.x = sx+5 
    event.y = sy+4
    event.z = sz
    sendClientCommand(player, 'Commands', 'SpawnGroup', event)

    local bandit = BanditCreator.MakeFromWave(config)
    event.bandits = {bandit}
    event.x = sx+3
    event.y = sy+5
    event.z = sz
    sendClientCommand(player, 'Commands', 'SpawnGroup', event)

    local bandit = BanditCreator.MakeFromWave(config)
    event.bandits = {bandit}
    event.x = sx+3
    event.y = sy+2
    event.z = sz
    sendClientCommand(player, 'Commands', 'SpawnGroup', event)

end