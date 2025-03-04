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

    local types = {clothing="array", hairstyles="array"}

    local file = getFileReader("bandit_custom.txt", false)
    if not file then return end

    local line
    local bname
    while true do
        line = file:readLine()
        if line == nil then
            file:close()
            break
        end

        if line:match("%[([%w]+)%]") then
            bname = line:match("%[([%w]+)%]")
        end

        local k, v = line:match("([%w_]+)%s*=%s*([^ \n]*)")
        if bname and k and v then
            if v == "true" then v = true end
            if v == "false" then v = false end
            if v == tonumber(v) then v = tonumber(v) end
            -- todo: add arrays

            if not BanditCustom.data[bname] then
                BanditCustom.data[bname] = {}
            end

            if types[k] == "array" then
                BanditCustom.data[bname][k] = splitString(v, ",")
            else
                BanditCustom.data[bname][k] = v
            end
            --print ("BanditCustom.data[" .. bname .. "][" .. k .. "] = " .. v)
        end
    end
    local test = BanditCustom
end

BanditCustom.Save = function()
    local file = getFileWriter("bandit_custom.txt", true, true)
    local output = ""

    local data = BanditCustom.data
    for bname, tab in pairs(data) do
        output = output .. "[" .. bname .. "]\n"
        for k, v in pairs(tab) do
            output = output .. "\t" .. k .. " = " .. tostring(v) .. "\n"
        end
        output = output .. "\n"
    end

    file:write(output)
    file:close()
end

BanditCustom.Reset = function()
    BanditCustom.data = BanditCustom.dataDefault
    BanditCustom.Save()
end

BanditCustom.GetClothing = function(bname)
    local data = BanditCustom.data[bname]
    if not data then return end

    return BanditCustom.data[bname].clothing
end

BanditCustom.GetHairstyles = function(bname)
    local data = BanditCustom.data[bname]
    if not data then return end

    return BanditCustom.data[bname].hairstyles
end