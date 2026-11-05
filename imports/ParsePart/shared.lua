---@param key string | number
local function ParsePart(key)
    if type(key) == "string" and key:sub(1, 1) == "p" then
        return true, tonumber(key:sub(2))
    end

    return false, tonumber(key)
end

return ParsePart
