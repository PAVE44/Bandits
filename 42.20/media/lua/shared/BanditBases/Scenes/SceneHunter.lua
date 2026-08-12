BanditScenes = BanditScenes or {}

function BanditScenes.Hunter (player, square)
    local cell = getCell()

    local sx = square:getX()
    local sy = square:getY()
    local sz = square:getZ()

    local w = 8
    local h = 7

    local items = {}
    local itemsFreeze = {}

    BanditBaseGroupPlacements.ClearSpace(sx-2, sy-2, 0, w+4, h+4)

    BanditProc.Cabin(sx, sy, sz)

    BanditBasePlacements.IsoGenerator("", sx + 5, sy + 1, sz + 0)
    BanditBasePlacements.Item("Base.PetrolCan", sx+ 6, sy + 1, sz, ZombRand(4))
    BanditBasePlacements.Item("Base.EmptyPetrolCan", sx + 6, sy + 1, sz, ZombRand(6))

    items = {"4xBase.DehydratedMeatStick", "1xBase.Salami", "2xBase.Wine2"}
    BanditBasePlacements.Container ("fixtures_counters_01_9", sx + 1, sy + 6, sz + 0, items)
    BanditBasePlacements.Container ("fixtures_counters_01_9", sx + 2, sy + 6, sz + 0, {})
    BanditBasePlacements.Container ("fixtures_counters_01_9", sx + 3, sy + 6, sz + 0, {})
	BanditBasePlacements.IsoObject ("fixtures_sinks_01_19", sx + 3, sy + 6, sz + 0)
    
    items = {"1xBase.VarmintRifle", "1xBase.x2Scope", "1xBase.x4Scope", "1xBase.x8Scope", "8xBase.223Box"}
    BanditBasePlacements.Container ("carpentry_01_16", sx + 2, sy + 1, sz + 0, items)
    items = {"2xBase.TrapCage", "2xBase.TrapSnare", "2xBase.TrapStick"}
    BanditBasePlacements.Container ("carpentry_01_16", sx + 2, sy + 2, sz + 0, items)
    items = {"1xBase.BookTrapping1", "1xBase.BookTrapping2", "1xBase.BookTrapping3", "1xBase.BookTrapping4", "1xBase.BookTrapping5", "1xBase.HuntingMag1", "1xBase.HuntingMag2", "1xBase.HuntingMag3"}
    BanditBasePlacements.Container ("carpentry_01_16", sx + 5, sy + 3, sz + 0, items)
    items = {"2xBase.HuntingKnife", "2xBase.SpearHuntingKnife", "5xBase.SpearCrafted"}
    BanditBasePlacements.Container ("carpentry_01_16", sx + 5, sy + 4, sz + 0, items)

    BanditBasePlacements.Container ("furniture_storage_01_49", sx + 1, sy + 7, sz + 0, {})
    BanditBasePlacements.IsoLightSwitch ("lighting_indoor_01_11", sx + 1, sy + 7, sz + 0)

    BanditBasePlacements.IsoObject ("camping_01_16", sx + 8, sy + 8, sz + 0)

    local event = {}
    event.x = sx + 5
    event.y = sy + 1
    event.z = sz
    event.name = "HikersBase"
    event.hostile = true
    event.occured = false
    event.program = "BaseGuard"
    event.bandits = {}

    config = {}
    config.hasRifleChance = 100
    config.hasPistolChance = 100
    config.rifleMagCount = 6
    config.pistolMagCount = 5

    local bandit = BanditCreator.MakeSurvivalist(config)
    table.insert(event.bandits, bandit)
    table.insert(event.bandits, bandit)

    sendClientCommand(player, 'Commands', 'SpawnGroup', event)
end