BanditConfig = BanditConfig or {}

function BanditConfig.GetWaveDataAll()
    local waveCnt = 16
    local waveData = {}
    for i=1, waveCnt do
        local wave = {}


        wave.enabled = SandboxVars.Bandits["Wave_" .. tostring(i) .. "_WaveEnabled"]
        wave.firstDay = SandboxVars.Bandits["Wave_" .. tostring(i) .. "_FirstDay"]
        wave.lastDay = SandboxVars.Bandits["Wave_" .. tostring(i) .. "_LastDay"]
        wave.spawnDistance = SandboxVars.Bandits["Wave_" .. tostring(i) .. "_SpawnDistance"]
        wave.spawnHourlyChance = SandboxVars.Bandits["Wave_" .. tostring(i) .. "_SpawnHourlyChance"]
        wave.groupSize = SandboxVars.Bandits["Wave_" .. tostring(i) .. "_GroupSize"]
        wave.isFriendly = SandboxVars.Bandits["Wave_" .. tostring(i) .. "_IsFriendly"]
        wave.groupName = SandboxVars.Bandits["Wave_" .. tostring(i) .. "_GroupName"]
        wave.hasPistolChance = SandboxVars.Bandits["Wave_" .. tostring(i) .. "_HasPistolChance"]
        wave.pistolMagCount = SandboxVars.Bandits["Wave_" .. tostring(i) .. "_PistolMagCount"]
        wave.hasRifleChance = SandboxVars.Bandits["Wave_" .. tostring(i) .. "_HasRifleChance"]
        wave.rifleMagCount = SandboxVars.Bandits["Wave_" .. tostring(i) .. "_RifleMagCount"]

        table.insert(waveData, wave)
    end
    return waveData
end

function BanditConfig.GetWaveDataForDay(day)
    local waveData = BanditConfig.GetWaveDataAll()
    local waveDataForDay = {}

    for k, wave in pairs(waveData) do
        if wave.enabled and day >= wave.firstDay and day <= wave.lastDay then
            table.insert(waveDataForDay, wave)
        end
    end
    return waveDataForDay
end
