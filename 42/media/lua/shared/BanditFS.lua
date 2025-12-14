BanditFS = BanditFS or {}

local function deserialize(str)
    local chunk, err = loadstring("return " .. str)
    if not chunk then
        error(err)
    end

    -- sandbox for safety
    setfenv(chunk, {})
    return chunk()
end

local function serialize(value, indent)
    indent = indent or ""
    local t = type(value)

    if t == "number" or t == "boolean" then
        return tostring(value)

    elseif t == "string" then
        return string.format("%q", value)

    elseif t == "table" then
        local nextIndent = indent .. "  "
        local lines = {"{"}

        for k, v in pairs(value) do
            local key
            if type(k) == "string" and k:match("^[_%a][_%w]*$") then
                key = k
            else
                key = "[" .. serialize(k, nextIndent) .. "]"
            end

            table.insert(
                lines,
                nextIndent .. key .. " = " .. serialize(v, nextIndent) .. ","
            )
        end

        table.insert(lines, indent .. "}")
        return table.concat(lines, "\n")

    else
        error("Cannot serialize type: " .. t)
    end
end

local function deserialize(str)
    local chunk, err = loadstring("return " .. str)
    if not chunk then
        error(err)
    end

    -- sandbox for safety
    setfenv(chunk, {})
    return chunk()
end

BanditFS.Write = function(resourceId, data)
    local filePath = BanditCompatibility.GetConfigPath()
    local fileName = resourceId .. ".bfs"
    local fileFull = filePath .. fileName
    local writer = getFileWriter(fileFull, true, false)

    local dataSerialized = serialize(data)
    writer:write(banditOutput)
    writer:close()
end

BanditFS.Read = function(resourceId)
    local filePath = BanditCompatibility.GetConfigPath()
    local fileName = resourceId .. ".bfs"
    local fileFull = filePath .. fileName
    local reader = getFileReader(fileName, false)

    local dataSerialized = ""
    while true do
        line = reader:readLine()
        if line == nil then
            break
        end
        dataSerialized = dataSerialized .. line .. "\n"
    end
    reader:close()
    local data = deserialize(dataSerialized)
    return data
end
