--[[
    Based on ox_lib's callback system (https://github.com/overextended/ox_lib)
    Original license: LGPL-3.0 (https://www.gnu.org/licenses/lgpl-3.0.en.html)
    Copyright © 2025 Linden (https://github.com/thelindat)
    Changes: bug fixes and stability improvements
]]

local RESOURCE_NAME <const> = GetCurrentResourceName()
local TIMEOUT <const> = 30000

local callback = {}
local pendingCallbacks = {}
local eventName = '__bs_cb_%s'

AddEventHandler('playerDropped', function()
    local src = source
    for key, cb in pairs(pendingCallbacks) do
        if key:match(':(%d+)$') == tostring(src) then
            pendingCallbacks[key] = nil
        end
    end
end)

RegisterNetEvent(eventName:format(RESOURCE_NAME), function(key, ...)
    local cb = pendingCallbacks[key]
    if not cb then return end
    pendingCallbacks[key] = nil
    cb(...)
end)

---@param _ any
---@param event string
---@param playerId number
---@param cb function|false
---@param ... any
---@return ...
local function triggerClientCallback(_, event, playerId, cb, ...)
    assert(DoesPlayerExist(playerId), ("target playerId '%s' does not exist"):format(playerId))

    local key, attempts = nil, 0
    repeat
        attempts += 1
        key = ('%s:%s:%s'):format(event, math.random(0, 999999), playerId)
        if attempts > 100 then
            error(("callback '%s': falha ao gerar key única após 100 tentativas"):format(event))
        end
    until not pendingCallbacks[key]

    TriggerClientEvent('bs-lib:validateCallback', playerId, event, RESOURCE_NAME, key)
    TriggerClientEvent(eventName:format(event), playerId, RESOURCE_NAME, key, ...)

    ---@type promise | false
    local promise = not cb and promise.new()

    pendingCallbacks[key] = function(response, ...)
        if response == 'cb_invalid' then
            response = ("callback '%s' does not exist"):format(event)
            pendingCallbacks[key] = nil
            return promise and promise:reject(response) or error(response)
        end

        response = { response, ... }

        if promise then
            return promise:resolve(response)
        end

        if cb then
            cb(table.unpack(response))
        end
    end

    SetTimeout(TIMEOUT, function()
        if not pendingCallbacks[key] then return end

        pendingCallbacks[key] = nil

        local message = ("callback event '%s' timed out"):format(key)
        if promise then return promise:reject(message) end

        print(("^3%s^0"):format(message))
    end)

    if promise then
        return table.unpack(Citizen.Await(promise))
    end
end

---@overload fun(event: string, playerId: number, cb: function, ...)
callback = setmetatable({}, {
    __call = function(_, event, playerId, cb, ...)
        if not cb then
            warn(("callback event '%s' does not have a function to callback to and will instead await\nuse callback.await or a regular event to remove this warning")
                :format(event))
        else
            local cbType = type(cb)

            if cbType == 'table' and getmetatable(cb)?.__call then
                cbType = 'function'
            end

            assert(cbType == 'function', ("expected argument 3 to have type 'function' (received %s)"):format(cbType))
        end

        return triggerClientCallback(_, event, playerId, cb, ...)
    end
})

---@param event string
---@param playerId number
---Sends an event to a client and halts the current thread until a response is returned.
---@diagnostic disable-next-line: duplicate-set-field
function callback.Await(event, playerId, ...)
    return triggerClientCallback(nil, event, playerId, false, ...)
end

---@param name string
---@param cb function
---Registers an event handler and callback function to respond to client requests.
---@diagnostic disable-next-line: duplicate-set-field
function callback.Register(name, cb)
    local event = eventName:format(name)
    Lib.SetValidCallback(name, true)
    RegisterNetEvent(event, function(resource, key, ...)
        local src = source
        if not DoesPlayerExist(src) then return end
        TriggerClientEvent(eventName:format(resource), src, key, cb(src, ...))
    end)
end

return callback