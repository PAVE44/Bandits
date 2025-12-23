function string:embodies(sub)
    return self:find(sub, 1, true) ~= nil
end

function string:startsWith(start)
    return self:sub(1, #start) == start
end

function string:endsWith(ending)
    return ending == "" or self:sub(-#ending) == ending
end

function string:replace(old, new)
    local s = self
    local search_start_idx = 1

    while true do
        local start_idx, end_idx = s:find(old, search_start_idx, true)
        if (not start_idx) then
            break
        end

        local postfix = s:sub(end_idx + 1)
        s = s:sub(1, (start_idx - 1)) .. new .. postfix

        search_start_idx = -1 * postfix:len()
    end

    return s
end

function string:insert(pos, text)
    return self:sub(1, pos - 1) .. text .. self:sub(pos)
end

function string:hasword(needle)
    -- Escape any special characters in the needle
    local escaped_needle = needle:gsub("([^%w])", "%%%1")
    -- Use pattern matching to find the word as a separate word
    local pattern = "%f[%w]" .. escaped_needle .. "%f[%W]"
    return self:find(pattern) ~= nil
end
