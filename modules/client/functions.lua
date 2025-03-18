Lib.Functions = {}

local cache = { anim = {} }

--==========================================================

Lib.Functions.loadModel = function(mhash)
    if (IsModelValid(mhash)) then
        local function Request(model)
            while (not HasAnimDictLoaded(model)) do
                RequestAnimDict(model)
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
    end

    if (type(anim) == 'table') then
        for i = 1, #anim do
            local dict = anim[i]
            Request(dict)
        end
    else
        Request(anim)
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