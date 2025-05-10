Lib.Callback = {}

local waitingCallbacks = {}

local GenerateString = function(length)
    local id = ''
    for _ = 1, length or 7 do
        local char = math.random(1, 2) == 1 and string.char(math.random(97, 122)) or tostring(math.random(0, 9))
        if math.random(1, 2) == 1 then
            char = string.upper(char)
        end
        id = id .. char
    end
    return id
end

local GenerateUniqueKey = function(t, length)
    local id = GenerateString(length)
    if not t[id] then
        return id
    else
        return GenerateUniqueKey(t, length)
    end
end

Lib.Callback.Trigger = function(callback, cb, ...)
    local requestId = GenerateUniqueKey(waitingCallbacks)
    waitingCallbacks[requestId] = cb
    TriggerServerEvent('bs-lib:trigger_callback', callback, requestId, ...)
end

Lib.Callback.TriggerSync = function(callback, ...)
    local requestId = GenerateUniqueKey(waitingCallbacks)
    local toreturn

    local promise = promise.new()
    waitingCallbacks[requestId] = function(...)
        toreturn = { ... }
        promise:resolve()
    end
    TriggerServerEvent('bs-lib:trigger_callback', callback, requestId, ...)
    Citizen.Await(promise)

    return table.unpack(toreturn)
end

RegisterNetEvent('bs-lib:callback_result', function(requestId, ...)
    if waitingCallbacks[requestId] then
        waitingCallbacks[requestId](...)
        waitingCallbacks[requestId] = nil
    end
end)