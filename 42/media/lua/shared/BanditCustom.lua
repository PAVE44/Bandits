BanditCustom = BanditCustom or {}

BanditCustom.data = {}

BanditCustom.Load = function()

    function splitString(input, separator)
        local result = {}
        for match in (input .. separator):gmatch("(.-)" .. separator) do
            table.insert(result, match:match("^%s*(.-)%s*$")) -- Trim spaces
        end
        return result
    end

    local types = {} -- {clothing="array", hairstyles="array"}

    local file = getFileReader("bandit_custom.txt", false)
    if not file then return end

    local line
    local bid
    while true do
        line = file:readLine()
        if line == nil then
            file:close()
            break
        end

        if line:match("%[([%w]+)%]") then
            bid = line:match("%[([%w]+)%]")
        end

        -- format:
        -- section: key=value
        local s, k, v = line:match("([%w_]+)%s*:%s*([%w_]+)%s*=%s*([^ \n]*)")
        if bid and k and v then
            if v == "true" then 
                v = true 
            elseif v == "false" then
                 v = false 
            elseif v:match("^%-?%d+%.?%d*$") then 
                v = tonumber(v) 
            end

            if not BanditCustom.data[bid] then
                BanditCustom.data[bid] = {}
            end

            if not BanditCustom.data[bid][s] then
                BanditCustom.data[bid][s] = {}
            end

            if types[k] == "array" then
                BanditCustom.data[bid][s][k] = splitString(v, ",")
            else
                BanditCustom.data[bid][s][k] = v
            end
            --print ("BanditCustom.data[" .. bid .. "][" .. k .. "] = " .. v)
        end
    end
    local test = BanditCustom
end

BanditCustom.Save = function()
    local file = getFileWriter("bandit_custom.txt", true, false)
    local output = ""

    local data = BanditCustom.data
    for bid, sections in pairs(data) do
        output = output .. "[" .. bid .. "]\n"
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

BanditCustom.GetAll = function()
    return BanditCustom.data
end

BanditCustom.Get = function(bid)
    return BanditCustom.data[bid]
end

BanditCustom.Set = function(bid, sections)
    if not BanditCustom.data[bid] then
        BanditCustom.data[bid] = {}
    end
    BanditCustom.data[bid] = sections
end

BanditCustom.Reset = function()
    BanditCustom.data = BanditCustom.dataDefault
    BanditCustom.Save()
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