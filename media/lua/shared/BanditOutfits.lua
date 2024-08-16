-- register modded outfits by adding them to tables below

BanditOutfits = BanditOutfits or {}

-- WAVE 1
BanditOutfits.DesperateCitizen = BanditOutfits.DesperateCitizen or {}
table.insert(BanditOutfits.DesperateCitizen, "Bathrobe")
table.insert(BanditOutfits.DesperateCitizen, "Generic02")
table.insert(BanditOutfits.DesperateCitizen, "Generic01")
table.insert(BanditOutfits.DesperateCitizen, "Punk")
table.insert(BanditOutfits.DesperateCitizen, "Rocker")
table.insert(BanditOutfits.DesperateCitizen, "Tourist")

if getActivatedMods():contains("Authentic Z - Current") then
    table.insert(BanditOutfits.DesperateCitizen, "AuthenticHomeless")
    table.insert(BanditOutfits.DesperateCitizen, "AuthenticPostalDude")
    table.insert(BanditOutfits.DesperateCitizen, "AuthenticSurvivorCovid")
end

-- WAVE 2
BanditOutfits.Psychopath = BanditOutfits.Psychopath or {}
table.insert(BanditOutfits.Psychopath, "Naked")
table.insert(BanditOutfits.Psychopath, "HockeyPsycho")
table.insert(BanditOutfits.Psychopath, "HospitalPatient")
table.insert(BanditOutfits.Psychopath, "Trader")
table.insert(BanditOutfits.Psychopath, "NakedVeil")
table.insert(BanditOutfits.Psychopath, "TinFoilHat")

if getActivatedMods():contains("Authentic Z - Current") then
    table.insert(BanditOutfits.Psychopath, "AuthenticJasonPart3")
    table.insert(BanditOutfits.Psychopath, "AuthenticFat02")
    table.insert(BanditOutfits.Psychopath, "AuthenticFat03")
    table.insert(BanditOutfits.Psychopath, "AuthenticGhostFace")
    table.insert(BanditOutfits.Psychopath, "AuthenticPolitician")
    table.insert(BanditOutfits.Psychopath, "AuthenticShortgunFace")
end

if getActivatedMods():contains("Brita_2") then
    table.insert(BanditOutfits.Psychopath, "Brita_Chain")
end

-- WAVE 3
BanditOutfits.Cannibal = BanditOutfits.Cannibal or {}
table.insert(BanditOutfits.Cannibal, "Woodcut")
table.insert(BanditOutfits.Cannibal, "Waiter_Restaurant")
table.insert(BanditOutfits.Cannibal, "Waiter_Diner")
if getActivatedMods():contains("Authentic Z - Current") then
    table.insert(BanditOutfits.Cannibal, "AuthenticNMRIHButcher")
    table.insert(BanditOutfits.Cannibal, "AuthenticLeatherFace")
end

-- WAVE 4
BanditOutfits.Crimial = BanditOutfits.Crimial or {}
table.insert(BanditOutfits.Crimial, "Thug")
table.insert(BanditOutfits.Crimial, "Redneck")
if getActivatedMods():contains("Authentic Z - Current") then
    table.insert(BanditOutfits.Crimial, "AuthenticBankRobber")
    table.insert(BanditOutfits.Crimial, "AuthenticNMRIHMolotov")
end

if getActivatedMods():contains("Brita_2") then
    table.insert(BanditOutfits.Crimial, "Brita_Killa_2")
end

-- WAVE 5
BanditOutfits.Inmate = BanditOutfits.Inmate or {}
table.insert(BanditOutfits.Inmate, "Inmate")
table.insert(BanditOutfits.Inmate, "InmateEscaped")

-- WAVE 6
BanditOutfits.Police = BanditOutfits.Police or {}
table.insert(BanditOutfits.Police, "Police")
table.insert(BanditOutfits.Police, "PoliceState")
table.insert(BanditOutfits.Police, "PoliceRiot")
table.insert(BanditOutfits.Police, "PrisonGuard")

if getActivatedMods():contains("Authentic Z - Current") then
    table.insert(BanditOutfits.Police, "AuthenticSurvivorPolice")
    table.insert(BanditOutfits.Police, "AuthenticSecretService")
end

if getActivatedMods():contains("zReSWATARMORbykK") then
    table.insert(BanditOutfits.Police, "zReSA_SWAT1")
    table.insert(BanditOutfits.Police, "zReSA_SWAT2")
end

-- WAVE 7
BanditOutfits.Prepper = BanditOutfits.Prepper or {}
table.insert(BanditOutfits.Prepper, "Survivalist03")
if getActivatedMods():contains("HNDLBR_Preppers") then
    table.insert(BanditOutfits.Prepper, "HNDLBR_Prepper")
    table.insert(BanditOutfits.Prepper, "HNDLBR_DoomsDayPrepper")
end

-- WAVE 8
BanditOutfits.Veteran = BanditOutfits.Veteran or {}
table.insert(BanditOutfits.Veteran, "Veteran")

-- WAVE 9
BanditOutfits.Biker = BanditOutfits.Biker or {}
table.insert(BanditOutfits.Biker, "Biker")

if getActivatedMods():contains("Authentic Z - Current") then
    table.insert(BanditOutfits.Biker, "AuthenticBiker")
    table.insert(BanditOutfits.Biker, "AuthenticBillMurray")
end

-- WAVE 10
BanditOutfits.Hunter = BanditOutfits.Hunter or {}
table.insert(BanditOutfits.Hunter, "Hunter")

-- WAVE 11
BanditOutfits.Reclaimer = BanditOutfits.Reclaimer or {}
table.insert(BanditOutfits.Reclaimer, "Priest")

if getActivatedMods():contains("Authentic Z - Current") then
    table.insert(BanditOutfits.Reclaimer, "AuthenticFuneralCoat")
    table.insert(BanditOutfits.Reclaimer, "AuthenticCultist")
end

-- WAVE 12
BanditOutfits.Scientist = BanditOutfits.Scientist or {}
table.insert(BanditOutfits.Scientist, "HazardSuit")

if getActivatedMods():contains("Authentic Z - Current") then
    table.insert(BanditOutfits.Scientist, "AuthenticHazardSuit")
    table.insert(BanditOutfits.Scientist, "AuthenticCEDAHazmatBlue")
    table.insert(BanditOutfits.Scientist, "AuthenticCEDAHazmatGreen")
    table.insert(BanditOutfits.Scientist, "AuthenticNBHHazmat")
    table.insert(BanditOutfits.Scientist, "AuthenticSurvivorHazardSuit")
end

-- WAVE 13
BanditOutfits.DoomRider = BanditOutfits.DoomRider or {}
table.insert(BanditOutfits.DoomRider, "Bandit")
table.insert(BanditOutfits.DoomRider, "Survivalist")

if getActivatedMods():contains("Brita_2") then
    table.insert(BanditOutfits.DoomRider, "Brita_Bandit")
    table.insert(BanditOutfits.DoomRider, "Brita_Bandit_2")
end

-- WAVE 14
BanditOutfits.PrivateMilitia = BanditOutfits.PrivateMilitia or {}
table.insert(BanditOutfits.PrivateMilitia, "PrivateMilitia")
table.insert(BanditOutfits.PrivateMilitia, "Camper")

if getActivatedMods():contains("Brita_2") then
    table.insert(BanditOutfits.PrivateMilitia, "Brita_Gorka")
    table.insert(BanditOutfits.PrivateMilitia, "Brita_Hunter_2")
end

-- WAVE 15
BanditOutfits.DeathLegion = BanditOutfits.DeathLegion or {}

if getActivatedMods():contains("Insurgent") then
    table.insert(BanditOutfits.DeathLegion, "InsurgentRifleman")
    table.insert(BanditOutfits.DeathLegion, "InsurgentAssault")
    table.insert(BanditOutfits.DeathLegion, "InsurgentOfficer")
else
    table.insert(BanditOutfits.DeathLegion, "ArmyCamoDesert")
end

-- WAVE 16
BanditOutfits.NewOrder = BanditOutfits.NewOrder or {}
table.insert(BanditOutfits.NewOrder, "ArmyCamoGreen")
table.insert(BanditOutfits.NewOrder, "Ghillie")

if getActivatedMods():contains("KATTAJ1_Military") then
    table.insert(BanditOutfits.NewOrder, "KATTAJ1_Army_Black_Patriot")
    table.insert(BanditOutfits.NewOrder, "KATTAJ1_Army_Black_Defender")
    table.insert(BanditOutfits.NewOrder, "KATTAJ1_Army_Black_Vanguard")
    table.insert(BanditOutfits.NewOrder, "KATTAJ1_Army_Green_Patriot")
    table.insert(BanditOutfits.NewOrder, "KATTAJ1_Army_Green_Defender")
    table.insert(BanditOutfits.NewOrder, "KATTAJ1_Army_Green_Vanguard")
end

