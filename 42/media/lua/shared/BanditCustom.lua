BanditCustom = BanditCustom or {}

BanditCustom.banditData = {}
BanditCustom.clanData = {}

BanditCustom.clanFile = "b_custom_clans.txt"
BanditCustom.banditFile = "b_custom_bandits.txt"

local load = function(dataKey, file)

    local function splitString(input, separator)
        local result = {}
        for match in (input .. separator):gmatch("(.-)" .. separator) do
            table.insert(result, match:match("^%s*(.-)%s*$")) -- Trim spaces
        end
        return result
    end

    local types = {} -- {clothing="array", hairstyles="array"}

    local file = getFileReader(file, false)
    if not file then 
        save(data, file)
        file = getFileReader(file, false)
    end

    local line
    local id
    while true do
        line = file:readLine()
        if line == nil then
            file:close()
            break
        end

        if line:match("%[([%w]+)%]") then
            id = line:match("%[([%w]+)%]")
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

local save = function(dataKey, file)
    local file = getFileWriter(file, true, false)
    local output = ""

    local data = BanditCustom[dataKey]
    for id, sections in pairs(data) do
        output = output .. "[" .. id .. "]\n"
        for sname, tab in pairs(sections) do
            for k, v in pairs(tab) do
                output = output .. "\t" .. sname .. ": " .. k .. " = " .. tostring(v) .. "\n"
            end
        end
        output = output .. "\n"
    end

    file:write(output)
    file:close()
end

BanditCustom.Load = function()
    load("banditData", BanditCustom.banditFile)
    load("clanData", BanditCustom.clanFile)
end

BanditCustom.Save = function()
    save("banditData", BanditCustom.banditFile)
    save("clanData", BanditCustom.clanFile)
end

-- clan methods
BanditCustom.ClanGetAll = function()
    return BanditCustom.clanData
end

BanditCustom.ClanGet = function(cid)
    return BanditCustom.clanData[cid]
end

-- bandit methods
BanditCustom.GetAll = function()
    return BanditCustom.banditData
end

BanditCustom.Get = function(bid)
    return BanditCustom.banditData[bid]
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
