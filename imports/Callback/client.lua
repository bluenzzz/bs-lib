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
local timers = {}
local eventName = '__bs_cb_%s'

RegisterNetEvent(eventName:format(RESOURCE_NAME), function(key, ...)
    local cb = pendingCallbacks[key]
    if not cb then return end
    pendingCallbacks[key] = nil
    cb(...)
end)

---@param event string
---@param delay? number | false
local function eventTimer(event, delay)
    if delay and type(delay) == 'number' and delay > 0 then
        local time = GetGameTimer()

        if (timers[event] or 0) > time then
            return false
        end

        timers[event] = time + delay
    end

    return true
end

---@param _ any
---@param event string
---@param delay number | false | nil
---@param cb function | false
---@param ... any
---@return ...
local function triggerServerCallback(_, event, delay, cb, ...)
    if not eventTimer(event, delay) then return end

    local key, attempts = nil, 0
    repeat
        attempts += 1
        key = ('%s:%s'):format(event, math.random(0, 999999))

        if attempts > 100 then
            error(("callback '%s': falha ao gerar key única após 100 tentativas"):format(event))
        end
    until not pendingCallbacks[key]

    TriggerServerEvent('bs-lib:validateCallback', event, RESOURCE_NAME, key)
    TriggerServerEvent(eventName:format(event), RESOURCE_NAME, key, ...)

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

---@overload fun(event: string, delay: number | false, cb: function, ...)
callback = setmetatable({}, {
    __call = function(_, event, delay, cb, ...)
        if not cb then
            warn(("callback event '%s' does not have a function to callback to and will instead await\nuse callback.Await or a regular event to remove this warning")
                :format(event))
        else
            local cbType = type(cb)

            if cbType == 'table' and getmetatable(cb)?.__call then
                cbType = 'function'
            end

            assert(cbType == 'function', ("expected argument 3 to have type 'function' (received %s)"):format(cbType))
        end

        return triggerServerCallback(_, event, delay, cb, ...)
    end
})

---@param event string
---@param delay? number | false
---@diagnostic disable-next-line: duplicate-set-field
function callback.Await(event, delay, ...)
    return triggerServerCallback(nil, event, delay, false, ...)
end

---@param name string
---@param cb function
---@diagnostic disable-next-line: duplicate-set-field
function callback.Register(name, cb)
    local event = eventName:format(name)
    Lib.SetValidCallback(name, true)
    RegisterNetEvent(event, function(resource, key, ...)
        TriggerServerEvent(eventName:format(resource), key, cb(...))
    end)
end

return callback