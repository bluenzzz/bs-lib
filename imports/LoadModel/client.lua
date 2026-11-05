---@param model number | string | (number | string)[]
---@param timeout? number
local function LoadModel(model, timeout)
    if type(model) ~= "table" then return Lib.RequestModel(model, timeout) end

    for i = 1, #model do
        if not Lib.RequestModel(model[i], timeout) then return false end
    end

    return true
end

return LoadModel
