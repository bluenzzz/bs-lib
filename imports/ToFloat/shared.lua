---@param value any
local function ToFloat(value)
    return (tonumber(value) or 0) + 0.0
end

return ToFloat
