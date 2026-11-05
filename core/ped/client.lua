local SPAWN_TIMEOUT <const> = 15000
local DEFAULT_DISTANCE <const> = 50.0

local PedDefinitions = {}
local PedsByZone = {}
local SpawnedPeds = {}
local LastPedId = 0

local function CreateDisplayPed(definition)
    if not Lib.LoadModel(definition.model) then return end

    local coords = definition.coords
    local ped = CreatePed(4, definition.model, coords.x, coords.y, coords.z - 0.97, coords.w or 0.0, false, false)

    local timeout = GetGameTimer() + SPAWN_TIMEOUT
    while not DoesEntityExist(ped) do
        if GetGameTimer() > timeout then return end
        Wait(0)
    end

    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)
    SetPedArmour(ped, 100)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedRelationshipGroupHash(ped, `CIVMALE`)

    local anim = definition.anim
    if anim and Lib.LoadAnimDict(anim[1]) then
        TaskPlayAnim(ped, anim[1], anim[2], 8.0, 0.0, -1, 1, 0, false, false, false)
    end

    return ped
end

local function DeleteSpawnedPed(id)
    local ped = SpawnedPeds[id]
    SpawnedPeds[id] = nil

    if ped and DoesEntityExist(ped) then
        DeleteEntity(ped)
    end
end

local function RemovePedDefinition(id)
    local definition = PedDefinitions[id]
    if not definition then return end

    DeleteSpawnedPed(id)
    PedDefinitions[id] = nil

    local zonePeds = PedsByZone[definition.gridZone]
    zonePeds[id] = nil
end

local function SpawnPed(id)
    local ped = CreateDisplayPed(PedDefinitions[id])
    if not ped then return end

    if not PedDefinitions[id] then return DeleteEntity(ped) end

    SpawnedPeds[id] = ped
end

local function SpawnZonePeds(plyCds)
    local gridZone = Lib.GridZone(plyCds.x, plyCds.y)
    local zonePeds = PedsByZone[gridZone]
    if not zonePeds then return end

    for id in pairs(zonePeds) do
        local definition = PedDefinitions[id]
        local dist = #(plyCds - definition.coords.xyz)

        if not SpawnedPeds[id] and dist <= definition.distance then
            SpawnPed(id)
        end
    end
end

local function ClearDistantPeds(plyCds)
    for id in pairs(SpawnedPeds) do
        local definition = PedDefinitions[id]
        local dist = #(plyCds - definition.coords.xyz)

        if dist > definition.distance then
            DeleteSpawnedPed(id)
        end
    end
end

CreateThread(function()
    while true do
        local plyCds = Lib.PlyCds
        ClearDistantPeds(plyCds)
        SpawnZonePeds(plyCds)
        Wait(1500)
    end
end)

function Lib.AddPed(data)
    local gridZone = Lib.GridZone(data.coords.x, data.coords.y)

    LastPedId += 1
    local id = LastPedId

    PedDefinitions[id] = {
        model = data.model,
        coords = data.coords,
        distance = data.distance or DEFAULT_DISTANCE,
        anim = data.anim,
        gridZone = gridZone,
        resource = GetInvokingResource() or RESOURCE_NAME,
    }

    PedsByZone[gridZone] = PedsByZone[gridZone] or {}
    PedsByZone[gridZone][id] = true
    return id
end

function Lib.RemovePed(id)
    RemovePedDefinition(id)
end

local function OnResourceStop(resourceName)
    for id, definition in pairs(PedDefinitions) do
        if resourceName == RESOURCE_NAME or definition.resource == resourceName then
            RemovePedDefinition(id)
        end
    end
end
AddEventHandler("onResourceStop", OnResourceStop)
