Lib.Ped = {}

local Peds = {}
Peds.Created = {}
Peds.Cache = {}

--==========================================================

Citizen.CreateThread(function()
    while (true) do
        local ply <const> = PlayerPedId()
        local plyCoords <const> = GetEntityCoords(ply)

        for i = 1, #Peds.Cache do
            local pedData <const> = Peds.Cache[i]
            if pedData then
                local dist = #(plyCoords - pedData.coords.xyz)
                if (dist <= 50.0) then
                    if not Peds.Created[i] then
                        if Lib.Functions.loadModel( pedData.model ) then
                            Lib.Ped.Create(i, pedData)
                        end
                    end
                else
                    if Peds.Created[i] then
                        Lib.Ped.Delete(i)
                    end
                end
            end
        end
        Citizen.Wait(1000)
    end
end)

--==========================================================

Lib.Ped.Insert = function(data)
    local invokingResource = GetInvokingResource()

    local index = #Peds.Cache+1
    Peds.Cache[index] = {
        model = data.model,
        coords = data.coords,
        anim = data.anim and { data.anim, data.dict },
        customization = data.customization,
        clothes = data.clothes,
        rsc = invokingResource
    }
end

Lib.Ped.Create = function(index, data)
    Peds.Created[index] = CreatePed(4, data.model, data.coords.x, data.coords.y, data.coords.z, data.coords.w)

    local ped <const> = Peds.Created[index]

    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetModelAsNoLongerNeeded(data.model)

    if (data.anim) and Lib.Functions.loadAnim(data.anim[1]) then
        TaskPlayAnim(ped, data.anim[1], data.anim[2], 8.0, 0.0, -1, 1, 0, 0, 0, 0)
    end

    if (data.customization) then
        SetPedHeadBlendData(ped, data.customization.fatherId, data.customization.motherId, 0, data.customization.colorMother, data.customization.colorFather, 0, Lib.Utils.toFloat(data.customization.shapeMix), Lib.Utils.toFloat(data.customization.skinMix), 0, false)
        SetPedHeadOverlay(ped, 12, data.customization.addBodyBlemishes, Lib.Utils.toFloat(data.customization.bodyBlemishesOpacity))
        SetPedHeadOverlay(ped, 11, data.customization.bodyBlemishes, Lib.Utils.toFloat(data.customization.bodyBlemishesOpacity))
        SetPedEyeColor(ped, data.customization.eyesColor)
        SetPedFaceFeature(ped, 11, Lib.Utils.toFloat(data.customization.eyesOpening))
        SetPedFaceFeature(ped, 6, Lib.Utils.toFloat(data.customization.eyebrowsHeight))
        SetPedFaceFeature(ped, 7, Lib.Utils.toFloat(data.customization.eyebrowsWidth))
        SetPedHeadOverlay(ped, 2, data.customization.eyebrowsModel, Lib.Utils.toFloat(data.customization.eyebrowsOpacity))
        SetPedHeadOverlayColor(ped, 2, 1, data.customization.eyebrowsColor, data.customization.eyebrowsColor)
        SetPedFaceFeature(ped, 0, Lib.Utils.toFloat(data.customization.noseWidth))
        SetPedFaceFeature(ped, 1, Lib.Utils.toFloat(data.customization.noseHeight))
        SetPedFaceFeature(ped, 2, Lib.Utils.toFloat(data.customization.noseLength))
        SetPedFaceFeature(ped, 3, Lib.Utils.toFloat(data.customization.noseBridge))
        SetPedFaceFeature(ped, 4, Lib.Utils.toFloat(data.customization.noseTip))
        SetPedFaceFeature(ped, 5, Lib.Utils.toFloat(data.customization.noseShift))
        SetPedFaceFeature(ped, 15, Lib.Utils.toFloat(data.customization.chinLength))
        SetPedFaceFeature(ped, 16, Lib.Utils.toFloat(data.customization.chinPosition))
        SetPedFaceFeature(ped, 17, Lib.Utils.toFloat(data.customization.chinWidth))
        SetPedFaceFeature(ped, 18, Lib.Utils.toFloat(data.customization.chinShape))     
        SetPedFaceFeature(ped, 13, Lib.Utils.toFloat(data.customization.jawWidth))
        SetPedFaceFeature(ped, 14, Lib.Utils.toFloat(data.customization.jawHeight))
        SetPedFaceFeature(ped, 8, Lib.Utils.toFloat(data.customization.cheekboneHeight))
        SetPedFaceFeature(ped, 9, Lib.Utils.toFloat(data.customization.cheekboneWidth))
        SetPedFaceFeature(ped, 10, Lib.Utils.toFloat(data.customization.cheeksWidth))
        SetPedFaceFeature(ped, 12, Lib.Utils.toFloat(data.customization.lips))
        SetPedFaceFeature(ped, 19, Lib.Utils.toFloat(data.customization.neckWidth))
        SetPedHeadOverlay(ped, 6, data.customization.complexionModel, Lib.Utils.toFloat(data.customization.complexionOpacity))
        SetPedHeadOverlayColor(ped, 6, 0, 0, 0)
        SetPedHeadOverlay(ped, 7, data.customization.sundamageModel, Lib.Utils.toFloat(data.customization.sundamageOpacity))
        SetPedHeadOverlayColor(ped, 7, 0, 0, 0)
        SetPedHeadOverlay(ped, 9, data.customization.frecklesModel, Lib.Utils.toFloat(data.customization.frecklesOpacity))
        SetPedHeadOverlayColor(ped, 9, 0, 0, 0)
        SetPedHeadOverlay(ped, 3, data.customization.ageingModel, Lib.Utils.toFloat(data.customization.ageingOpacity))
        SetPedHeadOverlayColor(ped, 3, 0, 0, 0)
        SetPedHeadOverlay(ped, 0, data.customization.blemishesModel, Lib.Utils.toFloat(data.customization.blemishesOpacity))
        SetPedHeadOverlayColor(ped, 0, 0, 0, 0)
        SetPedComponentVariation(ped, 2, data.customization.hairModel, 0, 0)
        SetPedHairColor(ped, data.customization.firstHairColor, data.customization.secondHairColor)
        SetPedHeadOverlay(ped, 1, data.customization.beardModel, Lib.Utils.toFloat(data.customization.beardOpacity))
        SetPedHeadOverlayColor(ped, 1, 1, data.customization.beardColor, data.customization.beardColor)
        SetPedHeadOverlay(ped, 10, data.customization.chestModel, Lib.Utils.toFloat(data.customization.chestOpacity))
        SetPedHeadOverlayColor(ped, 10, 1, data.customization.chestColor, data.customization.chestColor)
        SetPedHeadOverlay(ped, 5, data.customization.blushModel, Lib.Utils.toFloat(data.customization.blushOpacity))
        SetPedHeadOverlayColor(ped, 5, 2, data.customization.blushColor, data.customization.blushColor)
        SetPedHeadOverlay(ped, 8, data.customization.lipstickModel, Lib.Utils.toFloat(data.customization.lipstickOpacity))
        SetPedHeadOverlayColor(ped, 8, 2, data.customization.lipstickColor, data.customization.lipstickColor)
        SetPedHeadOverlay(ped, 4, data.customization.makeupModel, Lib.Utils.toFloat(data.customization.makeupOpacity))
        SetPedHeadOverlayColor(ped, 4, data.customization.makeupColorType, data.customization.makeupColor, data.customization.makeupColor)
    end

    if (data.clothes) then
        for i = 1, #data.clothes do
            local clothesData <const> = data.clothes[i]

            local isProp, index = Lib.Utils.parsePart(i)
            if isProp then
                SetPedPropIndex(ped, index, clothesData.model, clothesData.var, (clothesData.palette or 0))
            else
                if index <= 11 then
                    SetPedComponentVariation(ped, index, clothesData.model, clothesData.var, (clothesData.palette or 0))
                end
            end
        end
    end
end

Lib.Ped.Delete = function(index)
    if index then
        local ped <const> = Peds.Created[index]
        if ped then
            SetEntityAsMissionEntity(ped, false, false)
            DeleteEntity(ped)

            Peds.Created[index] = nil
        end
    else
        for i = 1, #Peds.Created do
            local ped <const> = Peds.Created[i]
            if ped then
                SetEntityAsMissionEntity(ped, false, false)
                DeleteEntity(ped)

                Peds.Created[index] = nil
            end
        end
    end
end

--==========================================================

AddEventHandler('onResourceStop', function(rsc)
    if (GetCurrentResourceName() == rsc) then
        Lib.Ped.Delete()
    else
        for i = 1, #Peds.Cache do
            local pedData <const> = Peds.Cache[i]
            if pedData then
                if (pedData.rsc == rsc) then
                    Peds.Cache[i] = nil

                    Lib.Ped.Delete(i)
                end
            end
        end
    end
end)