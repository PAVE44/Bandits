BanditCustom = BanditCustom or {}

BanditCustom.banditData = {}
BanditCustom.clanData = {}

-- BanditCustom.filePath = getFileSeparator() .. "media" .. getFileSeparator() .. "bandits" .. getFileSeparator()
BanditCustom.filePath = BanditCompatibility.GetConfigPath()
BanditCustom.clanFile = "clans.txt"
BanditCustom.banditFile = "bandits.txt"

local saveFile = function()
    local mods = BanditCustom.GetMods()
    table.insert(mods, "LOCAL")

    for i=1, #mods do
        local modid = mods[i]
        local banditFileName
        local banditFile
        local clanFileName
        local clanFile
        if modid == "LOCAL" then
            banditFileName = BanditCustom.filePath .. BanditCustom.banditFile
            banditFile = getFileWriter(banditFileName, true, false)
            clanFileName = BanditCustom.filePath .. BanditCustom.clanFile
            clanFile = getFileWriter(clanFileName, true, false)
        else
            banditFileName = BanditCustom.filePath .. BanditCustom.banditFile
            banditFile = getModFileWriter("\\" .. modid, banditFileName, true, false)
            clanFileName = BanditCustom.filePath .. BanditCustom.clanFile
            clanFile = getModFileWriter("\\" .. modid, clanFileName, true, false)
        end

        if banditFile and clanFile then
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
                        clanOutput = clanOutput .. "[" .. cid .. "]\n"
                        for sname, tab in pairs(clanData) do
                            for k, v in pairs(tab) do
                                clanOutput = clanOutput .. "\t" .. sname .. ": " .. k .. " = " .. tostring(v) .. "\n"
                            end
                        end
                        clanOutput = clanOutput .. "\n"
                        cids[cid] = true
                    end
                end
            end
            banditFile:write(banditOutput)
            clanFile:write(clanOutput)
            banditFile:close()
            clanFile:close()
        end
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

    local types = {} -- {clothing="array", hairstyles="array"}

    local modList = {}
    local mods = getActivatedMods()
    for i=0, mods:size()-1 do
        local modid = mods:get(i):gsub("^\\", "")
        table.insert(modList, modid)
    end
    table.insert(modList, "LOCAL")

    for i=1, #modList do
        local modid = modList[i]

        local file
        if modid == "LOCAL" then
            file  = getFileReader(fileName, false)
        else
            file  = getModFileReader("\\" .. modid, fileName, false)
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
        local file = getModFileReader("\\" .. modid, fileName, false)
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
    data.general.name = "Untitled"

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
    data.general.female = false
    data.general.skin = 1
    data.general.hairType = 1
    data.general.beardType = 1
    data.general.hairColor = 1
    data.clothing = {}
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

BanditCustom.Get = function(bid)
    return BanditCustom.banditData[bid]
end


