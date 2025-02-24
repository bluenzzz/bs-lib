if SERVER then
    TriggerRemoteEvent = TriggerClientEvent
    RegisterLocalEvent = RegisterServerEvent
else
    TriggerRemoteEvent = TriggerServerEvent
    RegisterLocalEvent = RegisterNetEvent
end

Tunnel = {}

local tunnelResolve = function(itable, key)
    local mtable = getmetatable(itable)
    local iname, ids, callbacks, identifier = mtable.name, mtable.tunnel_ids, mtable.tunnel_callbacks, mtable.identifier

    local fname, no_wait = key, false
    if (key:sub(1, 1) == "_") then
        fname, no_wait = key:sub(2), true
    end

    local fcall = function(...)
        local r
        local args, dest = {...}, nil

        if SERVER then
            dest, args = args[1], {table.unpack(args, 2, #args)}
            if dest >= 0 and not no_wait then r = async() end
        elseif not no_wait then
            r = async()
        end

        local delay_data = (dest and Tunnel.delays[dest]) or {0, 0}
        local add_delay = delay_data[1]
        delay_data[2] = delay_data[2] + add_delay

        local send_request = function()
            delay_data[2] = delay_data[2] - add_delay
            local rid = r and ids:gen() or -1
            if rid ~= -1 then callbacks[rid] = r end
            
            local event_name = iname .. ":tunnel_req"
            if SERVER then
                TriggerRemoteEvent(event_name, dest, fname, args, identifier, rid)
            else
                TriggerRemoteEvent(event_name, fname, args, identifier, rid)
            end
        end

        if delay_data[2] > 0 then
            SetTimeout(delay_data[2], send_request)
        else
            send_request()
        end
        
        if r then
            local rets = {r:wait()}
            return table.unpack(rets, 1, #rets)
        end
    end

    itable[key] = fcall
    return fcall
end

Tunnel.bindInterface = function(name, interface)
    RegisterLocalEvent(name..':tunnel_req')
    AddEventHandler(name..':tunnel_req', function(member, args, identifier, rid)
        local source = source

        local f = interface[member]

        local rets = {}
        if type(f) == "function" then 
            rets = {f(table.unpack(args, 1, table.maxn(args)))}
        end

        if rid >= 0 then
            if SERVER then
                TriggerRemoteEvent(name..':'..identifier..':tunnel_res',source,rid,rets)
            else
                TriggerRemoteEvent(name..':'..identifier..':tunnel_res',rid,rets)
            end
        end
    end)
end

Tunnel.getInterface = function(name, identifier)
    if (identifier) then
        local ids = newIDGenerator()
        local callbacks = {}

        local r = setmetatable({}, { 
            __index = tunnelResolve, 
            name = name, 
            tunnel_ids = ids, 
            tunnel_callbacks = callbacks, 
            identifier = identifier 
        })

        RegisterLocalEvent(name..':'..identifier..':tunnel_res')
        AddEventHandler(name..':'..identifier..':tunnel_res',function(rid,args)
            local callback = callbacks[rid]
            if callback then
                ids:free(rid)
                callbacks[rid] = nil

                callback(table.unpack(args, 1, table.maxn(args)))
            end
        end)
        return r
    end
end

exports('Tunnel', function() return Tunnel; end)