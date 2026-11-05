local DEFAULT_TIMEOUT <const> = 15000
local RELEASE_DELAY <const> = 60000

---@param dict string
---@param timeout? number
local function LoadAnimDictAsset(dict, timeout)
    if type(dict) ~= "string" then return false end
    if HasAnimDictLoaded(dict) then return true end

    if not DoesAnimDictExist(dict) then
        error(("invalid anim dict \"%s\""):format(dict))
    end

    RequestAnimDict(dict)

    return Lib.Await(function()
        if not HasAnimDictLoaded(dict) then return end

        SetTimeout(RELEASE_DELAY, function() RemoveAnimDict(dict) end)
        return true
    end, timeout or DEFAULT_TIMEOUT, ("timed out while loading anim dict \"%s\""):format(dict))
end

return LoadAnimDictAsset
