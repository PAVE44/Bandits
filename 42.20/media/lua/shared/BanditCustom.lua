require "BanditCompatibility"
BanditCustom = BanditCustom or {}

BanditCustom.banditData = {}
BanditCustom.clanData = {}

-- BanditCustom.filePath = getFileSeparator() .. "media" .. getFileSeparator() .. "bandits" .. getFileSeparator()
BanditCustom.filePath = BanditCompatibility.GetConfigPath()
BanditCustom.clanFile = "clans.txt"
BanditCustom.banditFile = "bandits.txt"

BanditCustom.clanAdjectives =
{
    "Ruthless",
    "Savage",
    "Vicious",
    "Feral",
    "Brutal",
    "Merciless",
    "Bloodthirsty",
    "Relentless",
    "Fierce",
    "Deadly",
    "Broken",
    "Black",
    "Red",
    "Grey",
    "Dead",
    "Silent",
    "Wild",
    "Lost",
    "Burned",
    "Cold",
    "Dark",
    "Bleeding",
    "Hungry",
    "Fallen",
    "Forsaken",
    "Savage",
    "Brutal",
    "Ruthless",
    "Restless",
    "Desperate",
    "Vicious",
    "Feral",
    "Cruel",
    "Angry",
    "Mad",
    "Scarred",
    "Wounded",
    "Bitter",
    "Lonely",
    "Dying",
    "Rotten",
    "Ashen",
    "Dusty",
    "Iron",
    "Bloody",
    "Grim",
    "Hollow",
    "Shattered",
    "Forgotten",
    "Wandering",
}

BanditCustom.clanNouns =
{
    "Bandits",
    "Raiders",
    "Outlaws",
    "Marauders",
    "Scavengers",
    "Wanderers",
    "Vagabonds",
    "Nomads",
    "Rogues",
    "Thieves",
    "Brigands",
    "Reavers",
    "Prowlers",
    "Lurkers",
    "Predators",
    "Assassins",
    "Hunters",
    "Stalkers",
    "Vultures",
    "Wolves",
    "Hounds",
    "Crows",
    "Ravens",
    "Vultures",
    "Rats",
    "Snakes",
    "Jackals",
    "Dogs",
    "Bears",
    "Boars",
    "Hawks",
    "Rangers",
    "Raiders",
    "Hunters",
    "Killers",
    "Butchers",
    "Thieves",
    "Scavengers",
    "Marauders",
    "Outcasts",
    "Drifters",
    "Wanderers",
    "Strays",
    "Nomads",
    "Survivors",
    "Holdouts",
    "Runaways",
    "Exiles",
    "Rebels",
    "Deserters",
    "Renegades",
    "Vagabonds",
    "Highwaymen",
    "Outlaws",
    "Bandits",
    "Robbers",
    "Looters",
    "Rogues",
    "Misfits",
    "Fugitives",
    "Strangers",
    "Ghosts",
    "Shadows",
    "Deadmen",
    "Ashwalkers",
    "Bloodhands",
    "Roadmen",
    "Wastrels",
}

local saveFile = function()
    local mods = BanditCustom.GetMods()
    table.insert(mods, "LOCAL")

    local globalClanFileName = BanditCustom.filePath .. BanditCustom.clanFile
    local globalClanFile = getFileWriter(globalClanFileName, true, false)
    local globalClanOutput = ""

    for i=1, #mods do
        local modid = mods[i]
        local banditFileName
        local banditFile
        local clanFileName
        local clanFile
        if modid == "LOCAL" then
            banditFileName = BanditCustom.filePath .. BanditCustom.banditFile
            banditFile = getFileWriter(banditFileName, true, false)
        else
            banditFileName = BanditCustom.filePath .. BanditCustom.banditFile
            banditFile = getModFileWriter(modid, banditFileName, true, false)
            clanFileName = BanditCustom.filePath .. BanditCustom.clanFile
            clanFile = getModFileWriter(modid, clanFileName, true, false)
        end

        if banditFile then
            local data = BanditCustom.banditData
            local banditOutput = ""
            local clanOutput = ""
            local cids = {}
            for id, sections in pairs(data) do
                if sections.general.modid == modid then

                    banditOutput = banditOutput .. "[" .. id .. "]\n"
                    for sname, tab in pairs(sections) do
                        for k, v in pairs(tab) do
                            banditOutput = banditOutput .. "\t" .. sname .. ": " .. k .. " = " .. tostring(v) .. "\n"
                        end
                    end
                    banditOutput = banditOutput .. "\n"

                    local cid = sections.general.cid
                    if not cids[cid] then
                        local clanData = BanditCustom.clanData[cid]
                        if not clanData then
                            clanData = BanditCustom.ClanCreate(cid)
                        end
                        local o = ""
                        o = o .. "[" .. cid .. "]\n"
                        for sname, tab in pairs(clanData) do
                            for k, v in pairs(tab) do
                                o = o .. "\t" .. sname .. ": " .. k .. " = " .. tostring(v) .. "\n"
                            end
                        end
                        o = o .. "\n"

                        clanOutput = clanOutput .. o
                        globalClanOutput = globalClanOutput .. o
                        cids[cid] = true
                    end
                end
            end
            banditFile:write(banditOutput)
            banditFile:close()

            if clanFile then
                clanFile:write(clanOutput)
                clanFile:close()
            end
        end
    end

    if globalClanFile then
        globalClanFile:write(globalClanOutput)
        globalClanFile:close()
    end
end

local loadFile = function(dataKey, fileName)

    local function splitString(input, separator)
        local result = {}
        for match in (input .. separator):gmatch("(.-)" .. separator) do
            table.insert(result, match:match("^%s*(.-)%s*$")) -- Trim spaces
        end
        return result
    end

    local types = {}

    local modList = {}
    local mods = getActivatedMods()
    for i=0, mods:size()-1 do
        local modid = mods:get(i):gsub("^\\", "")

        if modid == "Bandits2" and isIngameState() then
            if SandboxVars.Bandits.General_OriginalBandits then
                table.insert(modList, modid)
            end
        else
            table.insert(modList, modid)
        end

    end

    -- LOCAL needs to load last so it remains untouched by other mods!
    table.insert(modList, "LOCAL")

    for i=1, #modList do
        local modid = modList[i]

        local file
        if modid == "LOCAL" then
            file  = getFileReader(fileName, false)
        else
            file  = getModFileReader(modid, fileName, false)
        end

        if file then 
            local line
            local id
            while true do
                line = file:readLine()
                if line == nil then
                    file:close()
                    break
                end

                -- guid match
                if line:match("%[(%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x)%]") then
                    id = line:match("%[(%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x)%]")
                end

                -- format:
                -- section: key=value
                local s, k, v = line:match("([%w_]+)%s*:%s*([%w_]+)%s*=%s*([^ \n]*)")
                if id and k and v then
                    if v == "true" then 
                        v = true 
                    elseif v == "false" then
                        v = false 
                    elseif v:match("^%-?%d+%.?%d*$") then 
                        v = tonumber(v) 
                    end

                    if not BanditCustom[dataKey][id] then
                        BanditCustom[dataKey][id] = {}
                    end

                    if not BanditCustom[dataKey][id][s] then
                        BanditCustom[dataKey][id][s] = {}
                    end

                    if types[k] == "array" then
                        BanditCustom[dataKey][id][s][k] = splitString(v, ",")
                    else
                        BanditCustom[dataKey][id][s][k] = v
                    end
                    --print ("BanditCustom.banditData[" .. id .. "][" .. k .. "] = " .. v)
                end
            end
        end
    end
end

BanditCustom.GetMods = function()
    local ret = {}
    local mods = getActivatedMods()
    local fileName = BanditCustom.filePath .. BanditCustom.banditFile
    for i=0, mods:size()-1 do
        local modid = mods:get(i):gsub("^\\", "")
        local file = getModFileReader(modid, fileName, false)
        if file then
            table.insert(ret, modid)
            file:close()
        end
    end
    return ret
end

BanditCustom.Load = function()
    BanditCustom.banditData = {}
    BanditCustom.clanData = {}
    loadFile("banditData", BanditCustom.filePath .. BanditCustom.banditFile)
    loadFile("clanData", BanditCustom.filePath .. BanditCustom.clanFile)
end

BanditCustom.Save = function()
    saveFile()
end

-- clan methods
BanditCustom.ClanCreate = function(cid)
    local data = {}
    data.general = {}
    data.general.name = BanditUtils.Choice(BanditCustom.clanAdjectives) .. "_" .. BanditUtils.Choice(BanditCustom.clanNouns)
	data.spawn = {}
	data.spawn.friendly = false
	data.spawn.companion = false
	data.spawn.defenders = false
	data.spawn.campers = false
	data.spawn.assault = true
	data.spawn.wanderer = false
	data.spawn.roadblock = false
	data.spawn.dayStart = 0
	data.spawn.dayEnd = 10000
	data.spawn.spawnChance = 1
	data.spawn.groupMin = 1
	data.spawn.groupMax = 10
	data.spawn.zone = 0
    BanditCustom.clanData[cid] = data
    return BanditCustom.clanData[cid]
end

BanditCustom.Delete = function(cid)
    BanditCustom.clanData[cid] = nil
end

BanditCustom.ClanGetAll = function()
    return BanditCustom.clanData
end

BanditCustom.ClanGetAllSorted = function()
    local allData = BanditCustom.clanData
    local keys = {}
    for key in pairs(allData) do
        table.insert(keys, key)
    end

    table.sort(keys, function(k1, k2)
        return allData[k1].general.name < allData[k2].general.name
    end)

    local allDataSorted = {}
    for _, key in ipairs(keys) do
        allDataSorted[key] = allData[key]
    end
    return allDataSorted
end

BanditCustom.ClanGet = function(cid)
    return BanditCustom.clanData[cid]
end

-- bandit methods
BanditCustom.Create = function(bid)
    local data = {}
    data.general = {}
    data.general.name = "Bandit_" .. ZombRand(1000000)
    data.general.female = false
    data.general.skin = 1
    data.general.hairType = 1
    data.general.beardType = 1
    data.general.hairColor = 1
    data.clothing = {}
    data.tint = {}
    data.weapons = {}
    data.ammo = {}
    data.bag = {}

    BanditCustom.banditData[bid] = data
    return BanditCustom.banditData[bid]
end

BanditCustom.Delete = function(bid)
    BanditCustom.banditData[bid] = nil
end

BanditCustom.GetNextId = function(bid)
    --[[
    local newid = 0
    for id, _ in pairs(BanditCustom.banditData) do
        if id > newid then
            newid = id
        end
    end
    return newid + 1
    ]]
    return getRandomUUID()
end

BanditCustom.GetAll = function()
    return BanditCustom.banditData
end

BanditCustom.GetFromClan = function(cid)
    local ret = {}
    for bid, data in pairs(BanditCustom.banditData) do
        if data.general.cid == cid then
            ret[bid] = data
        end
    end
    return ret
end

BanditCustom.GetById = function(bid)
    return BanditCustom.banditData[bid]
end

BanditCustom.GetFromClanSorted = function(cid)
    local allData = {}
    for bid, data in pairs(BanditCustom.banditData) do
        if data.general.cid == cid then
            allData[bid] = data
        end
    end

    local keys = {}
    for key in pairs(allData) do
        table.insert(keys, key)
    end

    table.sort(keys, function(k1, k2)
        return allData[k1].general.name < allData[k2].general.name
    end)

    local allDataSorted = {}
    for _, key in ipairs(keys) do
        allDataSorted[key] = allData[key]
    end
    return allDataSorted
   
end

BanditCustom.Get = function(bid)
    return BanditCustom.banditData[bid]
end

BanditCustom.GetStats = function()
    local clanData = BanditCustom.clanData
    local clanCount = 0
    for cid, clan in pairs(clanData) do
        clanCount = clanCount + 1
    end

    local banditData = BanditCustom.banditData
    local banditCount = 0
    for bid, bandit in pairs(banditData) do
        banditCount = banditCount + 1
    end

    local stats = {}
    stats.clanCount = clanCount
    stats.banditCount = banditCount
    return stats
end

local function onGameStart()
    BanditCustom.Load()
end

Events.OnGameStart.Add(onGameStart)