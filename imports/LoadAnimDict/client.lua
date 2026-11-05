---@param dict string | string[]
---@param timeout? number
local function LoadAnimDict(dict, timeout)
    if type(dict) ~= "table" then return Lib.RequestAnimDict(dict, timeout) end

    for i = 1, #dict do
        if not Lib.RequestAnimDict(dict[i], timeout) then return false end
    end

    return true
end

return LoadAnimDict
