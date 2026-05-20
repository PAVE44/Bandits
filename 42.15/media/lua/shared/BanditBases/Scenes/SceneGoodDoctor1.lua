BanditScenes = BanditScenes or {}

function BanditScenes.GoodDoctor1 (player, square)
    local cell = getCell()

    local sx = square:getX()
    local sy = square:getY()
    local sz = square:getZ()

    local w = 32
    local h = 32
    
    local items = {}
    
    BanditBaseGroupPlacements.ClearSpace(sx-2, sy-2, 0, w+4, h+4)

    BanditBasePlacements.IsoGenerator("", sx + 15, sy + 1, sz + 0)
    BanditBasePlacements.Item("Base.PetrolCan", sx+ 6, sy + 1, sz, ZombRand(4))
    BanditBasePlacements.Item("Base.EmptyPetrolCan", sx + 6, sy + 1, sz, ZombRand(6))

    BanditProc.MedicalTent(sx, sy+6, sz)
    BanditBasePlacements.Container ("furniture_shelving_01_26", sx + 5, sy + 6, sz + 0, {})
    BanditBasePlacements.Container ("furniture_shelving_01_27", sx + 6, sy + 6, sz + 0, {})
    BanditBasePlacements.Container ("furniture_storage_02_2", sx + 7, sy + 6, sz + 0, {})
    BanditBasePlacements.IsoLightSwitch ("lighting_outdoor_01_48", sx + 1, sy + 4, sz + 0)
    BanditBaseGroupPlacements.Blood(sx, sy+6, sz, 14, 6, 70)
    BanditBaseGroupPlacements.Junk (sx, sy+7, 0, 14, 6, 10)
    BanditBaseGroupPlacements.Item("Base.BandageDirty", sx, sy+7, 0, 10, 6, 10)
    BanditBaseGroupPlacements.Item("Base.Disinfectant", sx, sy+7, 0, 10, 6, 7)
    BanditBaseGroupPlacements.Item("Base.RippedSheetsDirty", sx, sy+7, 0, 10, 6, 12)
    BanditBaseGroupPlacements.Item("Base.SheetPaper2", sx, sy+7, 0, 10, 6, 12)
    BanditBaseGroupPlacements.Item("Base.Splint", sx, sy+7, 0, 12, 6, 2)

    BanditProc.Toilet(sx+10, sy, sz)

    BanditProc.HouseMedium(sx+18, sy, sz)

    local event = {}
    event.x = sx + 15
    event.y = sy + 1
    event.z = sz
    event.name = "BandittBase"
    event.hostile = true
    event.occured = false
    event.program = "BaseGuard"
    event.bandits = {}

    config = {}
    config.hasRifleChance = 50
    config.hasPistolChance = 80
    config.rifleMagCount = 5
    config.pistolMagCount = 4

    local bandit = BanditCreator.MakeMadDoctors(config)
    table.insert(event.bandits, bandit)
    table.insert(event.bandits, bandit)
    table.insert(event.bandits, bandit)
    table.insert(event.bandits, bandit)
    table.insert(event.bandits, bandit)
    table.insert(event.bandits, bandit)
    table.insert(event.bandits, bandit)
    table.insert(event.bandits, bandit)

    sendClientCommand(player, 'Commands', 'SpawnGroup', event)
end