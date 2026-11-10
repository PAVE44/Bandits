BanditScenes = BanditScenes or {}

function BanditScenes.Cementary (player, square)
    local cell = getCell()

    local sx = square:getX()
    local sy = square:getY()
    local sz = square:getZ()

    local w = 28
    local h = 24

    local items = {}
    local itemsFreeze = {}

    -- ClearSpace(sx-2, sy-2, 0, w+4, h+4)

    BanditProc.Cementary(sx, sy, sz)

    local event = {}
    event.x = sx + 14
    event.y = sy + 12
    event.z = sz
    event.name = "BandittBase"
    event.hostile = true
    event.occured = false
    event.program = "BaseGuard"
    event.bandits = {}

    config = {}
    config.hasRifleChance = 70
    config.hasPistolChance = 90
    config.rifleMagCount = 5
    config.pistolMagCount = 4

    local bandit = BanditCreator.MakeBandits(config)
    table.insert(event.bandits, bandit)
    table.insert(event.bandits, bandit)
    table.insert(event.bandits, bandit)
    table.insert(event.bandits, bandit)
    table.insert(event.bandits, bandit)
    table.insert(event.bandits, bandit)

    sendClientCommand(player, 'Commands', 'SpawnGroup', event)
end