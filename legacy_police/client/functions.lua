local IsSearching = false

VORPcore = {}
TriggerEvent("getCore", function(core)
    VORPcore = core
end)

VORPutils = {}
TriggerEvent("getUtils", function(utils)
    VORPutils = utils
end)

function HandcuffPlayer()
    MenuData.CloseAll()
    Inmenu = false
    local closestPlayer, closestDistance = GetClosestPlayer()
    local targetplayerid = GetPlayerServerId(closestPlayer)
    local isDead = IsEntityDead(PlayerPedId())

    if closestDistance <= 3.0 then
        if not isDead then
            TriggerServerEvent('lawmen:handcuff', targetplayerid)
            if not IsSearching then
                IsSearching = true
                CuffPlayer(closestPlayer)
            elseif IsSearching then
                IsSearching = false
            end
        end
    end
end

function GetClosestPlayer()
    local players, closestDistance, closestPlayer = GetActivePlayers(), -1, -1
    local playerPed, playerId = PlayerPedId(), PlayerId()
    local coords, usePlayerPed = coords, false

    if coords then
        coords = vector3(coords.x, coords.y, coords.z)
    else
        usePlayerPed = true
        coords = GetEntityCoords(playerPed)
    end

    for i = 1, #players, 1 do
        local tgt = GetPlayerPed(players[i])

        if not usePlayerPed or (usePlayerPed and players[i] ~= playerId) then
            local targetCoords = GetEntityCoords(tgt)
            local distance = #(coords - targetCoords)

            if closestDistance == -1 or closestDistance > distance then
                closestPlayer = players[i]
                closestDistance = distance
            end
        end
    end
    return closestPlayer, closestDistance
end

Citizen.CreateThread(function()
    local showingSearch = false

    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local targetPed = GetPlayerPed(closestPlayer)
        local targetCoords = GetEntityCoords(targetPed)
        local distance = #(playerCoords - targetCoords)
        local nearTarget = false

        if distance <= 1.5 then
            nearTarget = true

            if not showingSearch and not IsEntityDead(playerPed) and IsSearching and not Inmenu and not InWagon and IsCuffed then
                SendNUIMessage({
                    type = "showSearch",
                    text = ConfigMain.Text.searchplayer
                })
                showingSearch = true
            end

            if IsControlJustReleased(0, 0x760A9C6F) and IsCuffed then
                TriggerServerEvent('lawmen:grabdata', GetPlayerServerId(closestPlayer))
                Citizen.Wait(200)

                if Takenmoney then
                    SearchMenu(Takenmoney)
                end
            end
        end

        if (not nearTarget or not IsCuffed) and showingSearch then
            SendNUIMessage({ type = "hideSearch" })
            showingSearch = false
        end

        Citizen.Wait(nearTarget and IsCuffed and 0 or 500)
    end
end)

function CheckTable(table, element)
    for k, v in pairs(table) do
        if v == element then
            return true
        end
    end
    return false
end

function GetPlayers()
    local players = {}
    for i = 0, 256 do
        if NetworkIsPlayerActive(i) then
            table.insert(players, GetPlayerServerId(i))
        end
    end
    return players
end

function PutInOutVehicle()
    local closestPlayer, closestDistance = GetClosestPlayer()
    local iscuffed = Citizen.InvokeNative(0x74E559B3BC910685, closestPlayer)
    print(iscuffed)
    if closestPlayer ~= -1 and closestDistance <= 3.0 then
        TriggerServerEvent('lawmen:GetPlayerWagonID', GetPlayerServerId(closestPlayer))
    else
        TriggerEvent("vorp:NotifyLeft", ConfigMain.Text.Notify.wagon, ConfigMain.Text.Notify.notcloseenough, "menu_textures", "cross", 2000, "COLOR_RED")
        return
    end
end

function GetClosestVehicle(coords)
    local ped = PlayerPedId()
    local objects = GetGamePool('CVehicle')
    local closestDistance = -1
    local closestObject = -1
    if coords then
    else
        coords = GetEntityCoords(ped)
    end
    for i = 1, #objects, 1 do
        local objectCoords = GetEntityCoords(objects[i])
        local distance = #(objectCoords - coords)
        if closestDistance == -1 or closestDistance > distance then
            closestObject = objects[i]
            closestDistance = distance
        end
    end
    return closestObject, closestDistance
end