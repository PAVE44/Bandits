BanditEvents = BanditEvents or {}

local function MakeBandit(outfit, femaleChance, weapons)
    local bandit = {}
    bandit.outfit = outfit
    bandit.weapons = weapons
    bandit.femaleChance = femaleChance
    return bandit
end

local function MakeWeapons(melee, primaryName, primaryMagSize, primaryMagCount, secondaryName, secondaryMagSize, secondaryMagCount)
    local weapons = {}
    weapons.melee = melee
    weapons.primary = {}
    weapons.primary.name = primaryName
    weapons.primary.magSize = primaryMagSize
    weapons.primary.bulletsLeft = primaryMagSize
    weapons.primary.magCount = primaryMagCount
    weapons.secondary = {}
    weapons.secondary.name = secondaryName
    weapons.secondary.magSize = secondaryMagSize
    weapons.secondary.bulletsLeft = secondaryMagSize
    weapons.secondary.magCount = secondaryMagCount
    return weapons
end

local function MakeEvent (name, banditChoices, cnt)
    local event = {}
    event.name = tostring(cnt) .. ": " .. name
    event.occured = false
    event.bandits = {}

    for i=1, cnt do
        table.insert(event.bandits, banditChoices[1+ZombRand(#banditChoices)])
    end
    return event
end



function BanditEvents.Get()

    local event
    local bandit

    local weaponsSets = {}
    -- melee only noob
    weaponsSets.meatCleaver = MakeWeapons("Base.MeatCleaver", false, 0, 0, false, 0, 0)
    weaponsSets.breadKnife = MakeWeapons("Base.BreadKnife", false, 0, 0, false, 0, 0)
    weaponsSets.scalpel = MakeWeapons("Base.Scalpel", false, 0, 0, false, 0, 0)
    weaponsSets.pan = MakeWeapons("Base.Pan", false, 0, 0, false, 0, 0)
    weaponsSets.rollingPin = MakeWeapons("Base.RollingPin", false, 0, 0, false, 0, 0)
    weaponsSets.smashedBottle = MakeWeapons("Base.SmashedBottle", false, 0, 0, false, 0, 0)
    weaponsSets.handScythe = MakeWeapons("Base.HandScythe", false, 0, 0, false, 0, 0)
    weaponsSets.gerdenFork = MakeWeapons("Base.GardenFork", false, 0, 0, false, 0, 0)
    weaponsSets.hammerStone = MakeWeapons("Base.HammerStone", false, 0, 0, false, 0, 0)

    -- melee only professional
    weaponsSets.katana = MakeWeapons("Base.Katana", false, 0, 0, false, 0, 0)
    weaponsSets.woodAxe = MakeWeapons("Base.WoodAxe", false, 0, 0, false, 0, 0)
    weaponsSets.baseball = MakeWeapons("Base.BaseballBat", false, 0, 0, false, 0, 0)
    weaponsSets.baseballNails = MakeWeapons("Base.BaseballBat_Nails", false, 0, 0, false, 0, 0)
    weaponsSets.crowbar = MakeWeapons("Base.Crowbar", false, 0, 0, false, 0, 0)
    weaponsSets.leadPipe = MakeWeapons("Base.LeadPipe", false, 0, 0, false, 0, 0)
    
    -- melee professional + pistol
    weaponsSets.baseballPistol = MakeWeapons("Base.BaseballBat", false, 0, 0, "Base.Pistol3", 15, 4)
    weaponsSets.baseballNailsPistol = MakeWeapons("Base.BaseballBat_Nails", false, 0, 0, "Base.Pistol3", 15, 4)
    weaponsSets.crowbarPistol = MakeWeapons("Base.Crowbar", false, 0, 0, "Base.Pistol3", 15, 4)
    weaponsSets.leadPipePistol = MakeWeapons("Base.LeadPipe", false, 0, 0, "Base.Pistol3", 15, 4)
    weaponsSets.nightstickPistol = MakeWeapons("Base.Nightstick", false, 0, 0, "Base.Pistol", 15, 6)
    
    -- fully armed
    weaponsSets.fullNightstick = MakeWeapons("Base.Nightstick", "Base.AssaultRifle2", 20, 4, "Base.Pistol", 15, 3)
    weaponsSets.fullMachete = MakeWeapons("Base.Machete", "Base.AssaultRifle2", 20, 5, "Base.Pistol", 15, 3)
    weaponsSets.fullKnife = MakeWeapons("Base.HuntingKnife", "Base.AssaultRifle2", 20, 4, "Base.Pistol", 15, 4)
    weaponsSets.fullHandaxe = MakeWeapons("Base.HandAxe", "Base.AssaultRifle2", 20, 4, "Base.Pistol", 15, 3)
    weaponsSets.fullKnifeMax = MakeWeapons("Base.HuntingKnife", "Base.AssaultRifle2", 20, 8, "Base.Pistol2", 15, 5)

    local characterSets = {}
    characterSets.crazyWoman = {MakeBandit("Bathrobe", 100, weaponsSets.breadKnife),
                                MakeBandit("NakedVeil", 100, weaponsSets.pan),
                                MakeBandit("StripperPink", 100, weaponsSets.smashedBottle),
                                MakeBandit("WeddingDress", 100, weaponsSets.rollingPin)}

    characterSets.cook = {MakeBandit("Cook_Generic", 0, weaponsSets.meatCleaver),
                          MakeBandit("Cook_Generic", 0, weaponsSets.breadKnife)}
    
    characterSets.farmer = {MakeBandit("Farmer", 10, weaponsSets.gerdenFork)}

    characterSets.doctor = {MakeBandit("Doctor", 60, weaponsSets.scalpel)}

    characterSets.inmate = {MakeBandit("Inmate", 0, weaponsSets.leadPipe),
                            MakeBandit("InmateEscaped", 0, weaponsSets.crowbar),
                            MakeBandit("Inmate", 0, weaponsSets.leadPipePistol),
                            MakeBandit("InmateEscaped", 0, weaponsSets.nightstickPistol)}
    
    characterSets.ninja = {MakeBandit("Classy", 0, weaponsSets.katana)}

    characterSets.lumberjack = {MakeBandit("Woodcut", 0, weaponsSets.woodAxe),
                                MakeBandit("Woodcut", 0, weaponsSets.hammerStone)}

    characterSets.bandit = {MakeBandit("Bandit", 20, weaponsSets.baseball),
                            MakeBandit("Bandit", 20, weaponsSets.baseballNails),
                            MakeBandit("Bandit", 20, weaponsSets.crowbar),
                            MakeBandit("Bandit", 20, weaponsSets.leadPipe)}

    characterSets.banditPistol = {MakeBandit("Bandit", 20, weaponsSets.baseball),
                                  MakeBandit("Bandit", 20, weaponsSets.baseballNails),
                                  MakeBandit("Bandit", 20, weaponsSets.crowbar),
                                  MakeBandit("Bandit", 20, weaponsSets.leadPipe),
                                  MakeBandit("Bandit", 20, weaponsSets.baseballPistol),
                                  MakeBandit("Bandit", 20, weaponsSets.baseballNailsPistol),
                                  MakeBandit("Bandit", 20, weaponsSets.crowbarPistol),
                                  MakeBandit("Bandit", 20, weaponsSets.leadPipePistol)}

    characterSets.privateSecurity = {MakeBandit("MallSecurity", 0, weaponsSets.nightstickPistol)}

    characterSets.police = {MakeBandit("Police", 10, weaponsSets.nightstickPistol)}

    characterSets.ranger = {MakeBandit("Ranger", 10, weaponsSets.nightstickPistol)}

    characterSets.policeState = {MakeBandit("PoliceState", 10, weaponsSets.nightstickPistol)}

    characterSets.policeSecurity = {MakeBandit("PoliceState", 0, weaponsSets.nightstickPistol)}

    characterSets.policeRiot = {MakeBandit("PoliceRiot", 10, weaponsSets.fullNightstick)}

    characterSets.militia = {MakeBandit("PrivateMilitia", 10, weaponsSets.fullMachete),
                             MakeBandit("PrivateMilitia", 10, weaponsSets.fullKnife),
                             MakeBandit("PrivateMilitia", 10, weaponsSets.fullHandaxe)}

    characterSets.veteran = {MakeBandit("Veteran", 10, weaponsSets.fullKnife)}

    characterSets.armyGreen = {MakeBandit("ArmyCamoGreen", 20, weaponsSets.fullKnifeMax)}

    characterSets.armyDesert = {MakeBandit("ArmyCamoDesert", 20, weaponsSets.fullKnifeMax)}

    local events = {}

    -- fibonacci style
    --single (1)
    table.insert(events, MakeEvent("Crazy Woman", characterSets.crazyWoman, 1))
    table.insert(events, MakeEvent("Redneck Farmer", characterSets.farmer, 1))
    table.insert(events, MakeEvent("Crazy Woman", characterSets.crazyWoman, 1))
    table.insert(events, MakeEvent("Doc", characterSets.doctor, 1))
    table.insert(events, MakeEvent("Ninja", characterSets.ninja, 1))
    table.insert(events, MakeEvent("Veteran", characterSets.veteran, 1))
    
    --double (2)
    table.insert(events, MakeEvent("Cook Friends", characterSets.cook, 2))
    table.insert(events, MakeEvent("Police Patrol", characterSets.police, 2))
    table.insert(events, MakeEvent("Bandit Friends", characterSets.bandit, 2))
    table.insert(events, MakeEvent("Ranger Patrol", characterSets.ranger, 2))
    table.insert(events, MakeEvent("Bandit Friends", characterSets.bandit, 2))
    table.insert(events, MakeEvent("Police Patrol", characterSets.police, 2))

    -- small groups (3)
    table.insert(events, MakeEvent("Lumberjacks Small", characterSets.lumberjack, 3))
    table.insert(events, MakeEvent("Ninja Small", characterSets.ninja, 3))
    table.insert(events, MakeEvent("Bandit Small", characterSets.bandit, 3))
    table.insert(events, MakeEvent("Inmates Small", characterSets.inmate, 3))
    table.insert(events, MakeEvent("Private Security Small", characterSets.privateSecurity, 3))
    table.insert(events, MakeEvent("Police Two Patrols", characterSets.police, 4))

    -- medium groups (5)
    table.insert(events, MakeEvent("Lumberjacks Medium", characterSets.lumberjack, 5))
    table.insert(events, MakeEvent("Bandit Medium", characterSets.bandit, 5))
    table.insert(events, MakeEvent("Inmates Medium", characterSets.inmate, 5))
    table.insert(events, MakeEvent("Private Security Medium", characterSets.privateSecurity, 5))
    table.insert(events, MakeEvent("Bandit Pistol Medium", characterSets.banditPistol, 5))
    table.insert(events, MakeEvent("State Police Medium", characterSets.police, 5))
    table.insert(events, MakeEvent("Bandit Pistol Medium", characterSets.banditPistol, 5))
    table.insert(events, MakeEvent("Police SWAT Medium", characterSets.policeSecurity, 6))
    table.insert(events, MakeEvent("Milita Medium", characterSets.militia, 4))
    table.insert(events, MakeEvent("Police Riot Medium", characterSets.policeRiot, 5))


    -- big groups (8)
    table.insert(events, MakeEvent("Lumberjack Big", characterSets.lumberjack, 8))
    table.insert(events, MakeEvent("Bandit Pistol Big", characterSets.banditPistol, 8))
    table.insert(events, MakeEvent("Milita Big", characterSets.militia, 7))
    table.insert(events, MakeEvent("Police Riot Big", characterSets.militia, 8))
    table.insert(events, MakeEvent("Army Green Big", characterSets.armyGreen, 8))
    table.insert(events, MakeEvent("Army Green Big", characterSets.armyGreen, 9))
    table.insert(events, MakeEvent("Army Desert Big", characterSets.armyDesert, 9))

    -- huge groups (13)
    table.insert(events, MakeEvent("Army Desert Green Huge", characterSets.armyDesert, 13))
    table.insert(events, MakeEvent("Milita Huge", characterSets.militia, 13))

    --[[
    -- 1
    event = {}
    event.name = "Lumberjacks"
    event.occured = false
    event.bandits = {lumberjack, lumberjack, lumberjack}
    table.insert(events, event)
    
    -- 2
    event = {}
    event.name = "Lumberjacks Medium"
    event.occured = false
    event.bandits = {lumberjack, lumberjack, lumberjack, lumberjack, lumberjack}
    table.insert(events, event)

    -- 3
    event = {}
    event.name = "Ninjas"
    event.occured = false
    event.bandits = {ninja, ninja, ninja}
    table.insert(events, event)

    -- 4
    event = {}
    event.name = "Ninjas Medium"
    event.occured = false
    event.bandits = {ninja, ninja, ninja, ninja, ninja, ninja, ninja}
    table.insert(events, event)

    -- 5
    event = {}
    event.name = "Bandits"
    event.occured = false
    event.bandits = {banditPistol, banditBaseball, banditBaseball}
    table.insert(events, event)

    -- 6
    event = {}
    event.name = "Police Patrol"
    event.occured = false
    event.bandits = {police, police}
    table.insert(events, event)

    -- 7
    event = {}
    event.name = "Lonely Veteran"
    event.occured = false
    event.bandits = {veteran}
    table.insert(events, event)

    -- 8
    event = {}
    event.name = "Militia Small"
    event.occured = false
    event.bandits = {militia, militia, militia}
    table.insert(events, event)

    -- 9
    event = {}
    event.name = "Bandits Medium"
    event.occured = false
    event.bandits = {banditPistol, banditPistol, banditBaseball, banditBaseball, banditBaseball}
    table.insert(events, event)

    -- 10
    event = {}
    event.name = "Police Group"
    event.occured = false
    event.bandits = {police, police, police, police}
    table.insert(events, event)

    -- 11
    event = {}
    event.name = "Police Riot Small"
    event.occured = false
    event.bandits = {police, policeRiot, policeRiot, policeRiot}
    table.insert(events, event)

    -- 12
    event = {}
    event.name = "Police Riot Big"
    event.occured = false
    event.bandits = {police, policeRiot, policeRiot, policeRiot, policeRiot, policeRiot}
    table.insert(events, event)

    -- 13
    event = {}
    event.name = "Militia Big"
    event.occured = false
    event.bandits = {militia, militia, militia, militia, militia}
    table.insert(events, event)

    -- 14
    event = {}
    event.name = "Army Squad"
    event.occured = false
    event.bandits = {armyCamoGreen, armyCamoGreen, armyCamoGreen}
    table.insert(events, event)

    -- 15
    event = {}
    event.name = "Militia Huge"
    event.occured = false
    event.bandits = {militia, militia, militia, militia, militia, militia, militia, militia, militia, militia}
    table.insert(events, event)

    -- 16
    event = {}
    event.name = "Police Riot Huge"
    event.occured = false
    event.bandits = {police, policeRiot, policeRiot, policeRiot, policeRiot, policeRiot, policeRiot, policeRiot, policeRiot, policeRiot}
    table.insert(events, event)

    -- 17
    event = {}
    event.name = "Army Two Squads"
    event.occured = false
    event.bandits = {armyCamoGreen, armyCamoGreen, armyCamoGreen, armyCamoGreen, armyCamoGreen, armyCamoGreen}
    table.insert(events, event)

    -- 18
    event = {}
    event.name = "Army Platoon"
    event.occured = false
    event.bandits = {armyCamoGreen, armyCamoGreen, armyCamoGreen, armyCamoGreen, armyCamoGreen, armyCamoGreen, armyCamoGreen, armyCamoGreen, armyCamoGreen}
    table.insert(events, event)

    -- 19
    event = {}
    event.name = "Militia Horde"
    event.occured = false
    event.bandits = {militia, militia, militia, militia, militia, militia, militia, militia, militia, militia, militia, militia, militia, militia, militia}
    table.insert(events, event)

    -- 20
    event = {}
    event.name = "Army Company"
    event.occured = false
    event.bandits = {armyCamoGreen, armyCamoGreen, armyCamoGreen, armyCamoGreen, armyCamoGreen, armyCamoGreen, armyCamoGreen, armyCamoGreen, armyCamoGreen, armyCamoGreen, armyCamoGreen, armyCamoGreen, armyCamoGreen, armyCamoGreen, armyCamoGreen, armyCamoGreen, armyCamoGreen, armyCamoGreen, armyCamoGreen, armyCamoGreen, armyCamoGreen, armyCamoGreen, armyCamoGreen, armyCamoGreen, armyCamoGreen, armyCamoGreen, armyCamoGreen}
    table.insert(events, event)

    ]]

    return events
end