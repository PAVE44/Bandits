BanditCustom = BanditCustom or {}

BanditCustom.banditData = {}
BanditCustom.clanData = {}

-- BanditCustom.filePath = getFileSeparator() .. "media" .. getFileSeparator() .. "bandits" .. getFileSeparator()
BanditCustom.filePath = BanditCompatibility.GetConfigPath()
BanditCustom.clanFile = "clans.txt"
BanditCustom.banditFile = "bandits.txt"

local saveFile = function()
    local mods = BanditCustom.GetMods()
    
    for i=1, #mods do
        local modid = mods[i]
        local banditFileName = BanditCustom.filePath .. BanditCustom.banditFile
        local banditFile = getModFileWriter("\\" .. modid, banditFileName, true, false)
        local clanFileName = BanditCustom.filePath .. BanditCustom.clanFile
        local clanFile = getModFileWriter("\\" .. modid, clanFileName, true, false)
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

    local mods = getActivatedMods()
    for i=0, mods:size()-1 do
        local modid = mods:get(i):gsub("^\\", "")

        local file = getModFileReader("\\" .. modid, fileName, false)
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

BanditCustom.GetSkinTexture = function(female, idx)
    if female then
        return "FemaleBody0" .. tostring(idx)
    else
        return "MaleBody0" .. tostring(idx) .. "a"
        --return "MaleBody0" .. tostring(idx)
    end
end

BanditCustom.GetHairColor = function(idx)
    local desc = SurvivorFactory.CreateSurvivor(SurvivorType.Neutral, false)
    local hairColors = desc:getCommonHairColor()
    local tab = {}
    local info = ColorInfo.new()
    for i=1, hairColors:size() do
        local color = hairColors:get(i-1)
        info:set(color:getRedFloat(), color:getGreenFloat(), color:getBlueFloat(), 1)
        table.insert(tab, { r=info:getR(), g=info:getG(), b=info:getB() })
    end
    return tab[idx]
end

BanditCustom.GetHairStyle = function(female, idx)
    local hairStyles = getAllHairStyles(female)
    local tab = {}
    for i=1, hairStyles:size() do
        local styleId = hairStyles:get(i-1)
        local hairStyle = female and getHairStylesInstance():FindFemaleStyle(styleId) or getHairStylesInstance():FindMaleStyle(styleId)
        if not hairStyle:isNoChoose() then
            table.insert(tab, styleId)
        end
    end
    return tab[idx]
end

BanditCustom.GetBeardStyle = function(female, idx)
    if female then return end
    local tab = {}
    local beardStyles = getAllBeardStyles()
    for i=1, beardStyles:size() do
        local styleId = beardStyles:get(i-1)
        table.insert(tab, styleId)
    end
    return tab[idx]
end
