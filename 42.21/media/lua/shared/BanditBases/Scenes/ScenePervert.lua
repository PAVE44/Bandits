BanditScenes = BanditScenes or {}

function BanditScenes.Pervert (player, square)
    local cell = getCell()

    local sx = square:getX()
    local sy = square:getY()
    local sz = square:getZ()

    local w = 24
    local h = 14 

    local items = {}
    local itemsFreeze = {}

    BanditBaseGroupPlacements.ClearSpace(sx-2, sy-2, 0, w+4, h+4)

    BanditBasePlacements.IsoGenerator("", sx+2, sy+2, sz)
    BanditProc.Dungeon(sx, sy, sz)

    local event = {}
    event.x = sx + 7
    event.y = sy + 6
    event.z = sz
    event.name = "DungeonBase"
    event.hostile = true
    event.occured = false
    event.program = "BaseGuard"
    event.bandits = {}

    config = {}
    config.hasRifleChance = 100
    config.hasPistolChance = 100
    config.rifleMagCount = 8
    config.pistolMagCount = 8

    local bandit = BanditCreator.MakeHazardSuit(config)
    table.insert(event.bandits, bandit)
    table.insert(event.bandits, bandit)
    table.insert(event.bandits, bandit)
    table.insert(event.bandits, bandit)

    sendClientCommand(player, 'Commands', 'SpawnGroup', event)
    
end