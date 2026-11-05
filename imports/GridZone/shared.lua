local GRID_OFFSET <const> = 8192
local GRID_SIZE <const> = 128

---@param axis number
local function GetGridChunk(axis)
    return math.floor((axis + GRID_OFFSET) / GRID_SIZE)
end

---@param x number
---@param y number
local function GridZone(x, y)
    return (GetGridChunk(x) << 8) | GetGridChunk(y)
end

return GridZone
