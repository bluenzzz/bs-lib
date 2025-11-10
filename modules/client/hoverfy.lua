Lib.Hoverfy = {}

local Locates = {}
local Show = {}

--==========================================================

Citizen.CreateThread(function()
    while (not uiReady) do Citizen.Wait(100); end;

    while (true) do
        local ply = PlayerPedId()
        local plyCoords = GetEntityCoords(ply)

        if (not Show.coords) then
            local gridZone = Lib.Functions.getGridZone(plyCoords.x, plyCoords.y)

            local locate = Locates[gridZone]
            if locate then
                for i = 1, #locate do
                    local data <const> = locate[i]

                    local dist = #(plyCoords - data.coords)
                    if (dist <= data.distance) then
                        Show = { coords = data.coords, distance = data.distance }

                        SendNUIMessage({ action = 'hoverfy', 
                            data = { 
                                show = true, 
                                key = data.key, 
                                text = data.text 
                            }
                        })
                        break;
                    end
                end
            end
        else
            local dist = #(plyCoords - Show.coords)
            if (dist > Show.distance) then
                Show = {}

                SendNUIMessage({ action = 'hoverfy', 
                    data = { 
                        show = false 
                    } 
                })
            end
        end
        Citizen.Wait(1000)
    end
end)

--==========================================================

Lib.Hoverfy.Insert = function(data)
    local gridZone = Lib.Functions.getGridZone(data.coords.x, data.coords.y)

    if not Locates[gridZone] then
        Locates[gridZone] = {}
    end

    local index = #Locates[gridZone]+1
    Locates[gridZone][index] = {
        key = data.key,
        text = data.text,
        coords = data.coords,
        distance = data.distance,
        resource = ( GetInvokingResource() or GetCurrentResourceName() )
    }
end

--==========================================================

AddEventHandler('onClientResourceStop', function(resourceName)
    local oldLocates = Locates
    for key, table in pairs(oldLocates) do
        for i = 1, #table do
            local data <const> = table[i]
            if (data) and data.resource == resourceName then
                Locates[key][i] = nil
            end
        end
	end
end)