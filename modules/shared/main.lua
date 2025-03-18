SERVER = IsDuplicityVersion()

Lib = {}

Lib.Tools = {}
Lib.Tunnel = {}
Lib.Tunnel.delays = {}

if SERVER then
    TriggerRemoteEvent = TriggerClientEvent
    RegisterLocalEvent = RegisterServerEvent

    exports('GetLibObject', function()
        return Lib
    end)
else
    TriggerRemoteEvent = TriggerServerEvent
    RegisterLocalEvent = RegisterNetEvent

    exports('GetLibObject', function()
        return Lib
    end)
end

table.maxn = function(t)
	local max = 0
	for k,v in pairs(t) do
		local n = tonumber(k)
		if n and n > max then max = n end
	end
	return max
end

local wait = function(self)
	local rets = Citizen.Await(self.p)
	if not rets then rets = self.r end
	return table.unpack(rets,1,table.maxn(rets))
end

local areturn = function(self,...)
	self.r = {...}; self.p:resolve(self.r)
end

async = function(func)
	if func then
		Citizen.CreateThreadNow(func)
	else
		return setmetatable({ wait = wait, p = promise.new() }, { __call = areturn })
	end
end

Lib.Tunnel.setDestDelay = function(dest, delay)
  Lib.Tunnel.delays[dest] = {delay, 0}
end

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

        local delay_data = (dest and Lib.Tunnel.delays[dest]) or {0, 0}
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

Lib.Tunnel.bindInterface = function(name, interface)
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

Lib.Tunnel.getInterface = function(name, identifier)
    if (identifier) then
        local ids = Lib.Tools.newIDGenerator()
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