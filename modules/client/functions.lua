Lib.Functions = {}

local cache = { anim = {}, model = {} }

--==========================================================

Lib.Functions.loadModel = function(mhash)
    if (IsModelValid(mhash)) then
        local function Request(model)
            while (not HasModelLoaded(model)) do
                RequestModel(model)
                Citizen.Wait(100)
            end
        end

        if (type(mhash) == 'table') then
            for i = 1, #mhash do
                local model = mhash[i]
                Request(model)
            end
        else
            Request(mhash)
        end
        return true
    end
    return false
end

Lib.Functions.unloadModel = function(mhash)
    if mhash then
        if IsModelValid(mhash) then
            SetModelAsNoLongerNeeded(mhash)
        end
    else
        local invokingResource = GetInvokingResource()

        local models = cache.model[invokingResource]
        if models then
            for i = 1, #models do
                local model = models[i]
                if IsModelValid(model) then
                    SetModelAsNoLongerNeeded(model)
                end
            end
        end
    end
end

--==========================================================

Lib.Functions.loadAnim = function(anim)
    local invokingResource = GetInvokingResource()
    if not cache.anim[invokingResource] then
        cache.anim[invokingResource] = {}
    end

    local function Request(dict)
        while (not HasAnimDictLoaded(dict)) do
            RequestAnimDict(dict)
            Citizen.Wait(100)
        end

        table.insert(cache.anim[invokingResource], dict)
        return true
    end

    if (type(anim) == 'table') then
        for i = 1, #anim do
            local dict = anim[i]
            Request(dict)
        end
    else
        return Request(anim)
    end
end

Lib.Functions.unloadAnim = function(dict)
    if (dict) then
        RemoveAnimDict(dict)
    else
        local invokingResource = GetInvokingResource()

        local anims = cache.anim[invokingResource]
        if anims then
            for i = 1, #anims do
                local dict = anims[i]
                RemoveAnimDict(dict)
            end
        end
    end
end

--==========================================================

Lib.Functions.getGridZone = function(x, y)
    local function gridChunk(x)
	    return math.floor((x + 8192) / 128)
    end
    
    local function toChannel(v)
	    return (v['x'] << 8) | v['y']
    end

	return toChannel( vector2(gridChunk(x), gridChunk(y)) )
end