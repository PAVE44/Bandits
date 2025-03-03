BanditCustom = BanditCustom or {}

BanditCustom.data = {}

BanditCustom.Load = function()
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
            BanditCustom.data[bname][k] = v
            --print ("BanditCustom.data[" .. bname .. "][" .. k .. "] = " .. v)
        end
    end
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

