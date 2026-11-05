local DEFAULT_COLOR <const> = "#0093ff"

local Locates = {}
local LocatesByZone = {}
local LastLocateId = 0
local ShownLocateId

local function ShowHoverfy(id)
    local locate = Locates[id]
    ShownLocateId = id

    SendNUIMessage({
        action = "Hoverfy",
        data = {
            show = true,
            key = locate.key,
            text = locate.text,
            color = locate.color,
        },
    })
end

local function HideHoverfy()
    ShownLocateId = nil

    SendNUIMessage({
        action = "Hoverfy",
        data = { show = false },
    })
end

local function FindNearbyLocate(plyCds)
    local gridZone = Lib.GridZone(plyCds.x, plyCds.y)
    local zoneLocates = LocatesByZone[gridZone]
    if not zoneLocates then return end

    for id in pairs(zoneLocates) do
        local locate = Locates[id]
        local dist = #(plyCds - locate.coords.xyz)
        if dist <= locate.distance then return id end
    end
end

local function RemoveLocate(id)
    local locate = Locates[id]
    if not locate then return end

    if ShownLocateId == id then HideHoverfy() end

    Locates[id] = nil

    local zoneLocates = LocatesByZone[locate.gridZone]
    zoneLocates[id] = nil
end

CreateThread(function()
    Citizen.Await(Lib.UiReady)

    while true do
        local plyCds = Lib.PlyCds

        if ShownLocateId then
            local locate = Locates[ShownLocateId]
            local dist = #(plyCds - locate.coords.xyz)
            if dist > locate.distance then HideHoverfy() end
        else
            local id = FindNearbyLocate(plyCds)
            if id then ShowHoverfy(id) end
        end

        Wait(1000)
    end
end)

function Lib.Hoverfy(data)
    local gridZone = Lib.GridZone(data.coords.x, data.coords.y)

    LastLocateId += 1
    local id = LastLocateId

    Locates[id] = {
        key = data.key,
        text = data.text,
        coords = data.coords,
        distance = data.distance,
        color = data.color or DEFAULT_COLOR,
        gridZone = gridZone,
        resource = GetInvokingResource() or RESOURCE_NAME,
    }

    LocatesByZone[gridZone] = LocatesByZone[gridZone] or {}
    LocatesByZone[gridZone][id] = true
    return id
end

function Lib.RemoveHoverfy(id)
    RemoveLocate(id)
end

local function OnResourceStop(resourceName)
    for id, locate in pairs(Locates) do
        if locate.resource == resourceName then
            RemoveLocate(id)
        end
    end
end
AddEventHandler("onResourceStop", OnResourceStop)
