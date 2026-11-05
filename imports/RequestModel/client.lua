local DEFAULT_TIMEOUT <const> = 15000
local RELEASE_DELAY <const> = 60000

---@param model number | string
---@param timeout? number
local function LoadModelAsset(model, timeout)
    local modelHash = type(model) == "number" and model or GetHashKey(model)
    if HasModelLoaded(modelHash) then return true end

    if not IsModelValid(modelHash) and not IsModelInCdimage(modelHash) then
        error(("invalid model \"%s\""):format(model))
    end

    RequestModel(modelHash)

    return Lib.Await(function()
        if not HasModelLoaded(modelHash) then return end

        SetTimeout(RELEASE_DELAY, function() SetModelAsNoLongerNeeded(modelHash) end)
        return true
    end, timeout or DEFAULT_TIMEOUT, ("timed out while loading model \"%s\""):format(model))
end

return LoadModelAsset
