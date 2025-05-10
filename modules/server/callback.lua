Lib.Callback = {}

local callbacks = {}

Lib.Callback.Register = function(callback, cb)
    callbacks[callback] = cb
end

RegisterNetEvent('bs-lib:trigger_callback', function(callback, requestId, ...)
    local src = source
    if callbacks[callback] then
        callbacks[callback](src, function(...)
            TriggerClientEvent('bs-lib:callback_result', src, requestId, ...)
        end, ...)
    end
end)