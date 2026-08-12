BanditScenes = BanditScenes or {}

function BanditScenes.Carpenter (player, square)
    local cell = getCell()

    local sx = square:getX()
    local sy = square:getY()
    local sz = square:getZ()

    local w = 13
    local h = 13

    local items = {}
    local itemsFreeze = {}

    BanditBaseGroupPlacements.ClearSpace(sx-2, sy-2, 0, w+4, h+4)

    BanditProc.HouseBigUnfinished(sx, sy, sz)

    items = {"6xBase.PlasterPowder"}
    BanditBasePlacements.Container ("carpentry_01_16", sx + 2, sy + 9, sz + 0, items)

    items = {"5xBase.NailsBox", "1xBase.BallPeenHammer"}
    BanditBasePlacements.Container ("carpentry_01_16", sx + 3, sy + 7, sz + 0, items)

    items = {"12xBase.Plank", "1xBase.Saw"}
    BanditBasePlacements.Container ("carpentry_01_16", sx + 3, sy + 8, sz + 0, items)

    items = {"13xBase.Plank"}
    BanditBasePlacements.Container ("carpentry_01_16", sx + 3, sy + 9, sz + 0, items)
    
    BanditBasePlacements.Container ("trashcontainers_01_16", sx + 3, sy + 12, sz + 0, {})

    items = {"1xBase.Sledgehammer", "1xBase.Hammer"}
    BanditBasePlacements.Container ("carpentry_01_16", sx + 6, sy + 1, sz + 0, items)

    items = {"10xBase.CannedBolognese", "6xBase.BeerBottle"}
    BanditBasePlacements.Container ("carpentry_01_16", sx + 5, sy + 11, sz + 1, items)

    items = {"1xBase.Crowbar"}
    BanditBasePlacements.Container ("carpentry_01_16", sx + 4, sy + 11, sz + 1, items)

    BanditBasePlacements.IsoObject("carpentry_02_76", sx + 4, sy + 8, sz + 1)
    BanditBasePlacements.IsoObject("carpentry_02_77", sx + 5, sy + 8, sz + 1)

    BanditBaseGroupPlacements.Item("Base.Sandbag", sx, sy, 0, w, h, 4)
    BanditBaseGroupPlacements.Item("Base.BucketEmpty", sx, sy, 0, w, h, 4)
    BanditBaseGroupPlacements.Item("Base.Nails", sx, sy, 0, w, h, 14)
    BanditBaseGroupPlacements.Item("Base.Plank", sx, sy, 0, w, h, 13)
    BanditBaseGroupPlacements.Item("Base.Plank", sx+2, sy+2, 1, w-4, h-2, 16)
    BanditBaseGroupPlacements.Item("Base.Nails", sx+2, sy+2, 1, w-4, h-2, 17)
    
    local event = {}
    event.x = sx + 1
    event.y = sy + 1
    event.z = sz
    event.name = "CarpenterBase"
    event.hostile = true
    event.occured = false
    event.program = "BaseGuard"
    event.bandits = {}

    config = {}
    config.hasRifleChance = 1
    config.hasPistolChance = 10
    config.rifleMagCount = 2
    config.pistolMagCount = 2

    local bandit = BanditCreator.MakeCarpenterClan(config)
    table.insert(event.bandits, bandit)
    table.insert(event.bandits, bandit)
    table.insert(event.bandits, bandit)
    table.insert(event.bandits, bandit)
    table.insert(event.bandits, bandit)
    table.insert(event.bandits, bandit)

    sendClientCommand(player, 'Commands', 'SpawnGroup', event)

end