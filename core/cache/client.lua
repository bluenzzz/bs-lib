local Cache = {}

local function SetCache(key, value)
    if Cache[key] == value then return end

    Cache[key] = value
    rawset(Lib, key, value)
    TriggerEvent("bs-lib:client:cache", key, value)
    TriggerEvent(("%s:cache:%s"):format(RESOURCE_NAME, key), value)
end

local function UpdateCache()
    local ply = PlayerPedId()
    SetCache("Ply", ply)
    SetCache("PlyCds", GetEntityCoords(ply))
end

UpdateCache()

CreateThread(function()
    while true do
        UpdateCache()
        Wait(500)
    end
end)

function Lib.Cache(key)
    if not key then return Cache end

    return Cache[key]
end
