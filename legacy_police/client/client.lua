local IsHandcuffed = false
local display = false
local badgeactive = false
local Jailed = false
local Serviced = false
local Autotele = true
local playerJob
local JailID
local jaillocation
local searchid
local JailEntranceCoords = nil
local Takenmoney = nil
local PoliceOnDuty = nil
local Search = nil
local InWagon = nil
local spawn_wagon = nil
local Jail_time = 0
local Jail_maxDistance = ConfigJail.EscapeConfig.EscapeDistance
local Jail_penalty = ConfigJail.EscapeConfig.EscapePenaltyTime
local dragStatus = {}
dragStatus.isDragged = false

Citizen.CreateThread(function()
    local showingCabinet = false

    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local nearCabinet = false

        for _, cabinetCoords in ipairs(ConfigCabinets.Guncabinets) do
            if #(playerCoords - vector3(cabinetCoords.x, cabinetCoords.y, cabinetCoords.z)) < 1.5 then
                nearCabinet = true

                if not showingCabinet then
                    SendNUIMessage({
                        type = "showCabinet",
                        text = ConfigMain.Text.cabinetnui
                    })
                    showingCabinet = true
                end

                if IsControlJustReleased(0, 0x760A9C6F) then
                    TriggerServerEvent("lawmen:checkcabinetjob")
                end
                break
            end
        end

        if not nearCabinet and showingCabinet then
            SendNUIMessage({ type = "hideCabinet" })
            showingCabinet = false
        end

        Citizen.Wait(nearCabinet and 0 or 500)
    end
end)

CreateThread(function()
    while true do
        Wait(5)
        if InWagon then
            SetRelationshipBetweenGroups(1, `PLAYER`, `PLAYER`)
        else
            Wait(500)
        end
    end
end)

RegisterNetEvent('lawmen:PlayerInWagon')
AddEventHandler('lawmen:PlayerInWagon', function()
    if not IsHandcuffed then
        return
    end

    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local closestWagon = GetClosestVehicle(coords)

    if DoesEntityExist(ped) and DoesEntityExist(closestWagon) then
        local vehicle = IsPedInVehicle(ped, closestWagon, false)

        if not vehicle then
            local rearSeats = {1, 2, 3, 4, 5, 6}
            for i = 1, #rearSeats do
                if IsVehicleSeatFree(closestWagon, rearSeats[i]) then
                    SetPedIntoVehicle(ped, closestWagon, rearSeats[i])
                    InWagon = true
                    break
                end
            end
        else
            TaskLeaveVehicle(ped, closestWagon, 16)
            Wait(5000)
            InWagon = false
        end
    end
end)

RegisterNetEvent('lawmen:StartSearch', function()
    local closestPlayer, closestDistance = GetClosestPlayer()
    searchid = GetPlayerServerId(closestPlayer)
    if closestPlayer ~= -1 and closestDistance <= 3.0 then
        TriggerServerEvent("lawmen:ReloadInventory", searchid)
        TriggerEvent("vorp_inventory:OpenstealInventory", ConfigMain.Text.inventorytitle, searchid)
    end
end)

RegisterNetEvent('lawmen:GetSearch')
AddEventHandler('lawmen:GetSearch', function(obj)
    TriggerServerEvent('lawmen:TakeFrom', obj, searchid)
end)

RegisterNetEvent("lawmen:PlayerJob")
AddEventHandler("lawmen:PlayerJob", function(Job)
    playerJob = Job
end)

RegisterNetEvent("lawmen:senddata")
AddEventHandler("lawmen:senddata", function(playermoney)
    Takenmoney = playermoney
end)

RegisterNetEvent("vorp:SelectedCharacter")
AddEventHandler("vorp:SelectedCharacter", function(charid)
    Citizen.Wait(15000)
    TriggerServerEvent("lawmen:check_jail")
    TriggerServerEvent("lawmen:gooffdutysv")
end)

RegisterNetEvent("lawmen:onduty")
AddEventHandler("lawmen:onduty", function(duty)
    if not duty then
        PoliceOnDuty = false
    else
        PoliceOnDuty = true
    end
end)

Badge = nil
Badgex, Badgey, Badgez = 0.17, -0.19, -0.25
BadgeCoords = nil
MaleboneIndex = 458
FemaleboneIndex = 500
Rotationz = 30.0

RegisterNetEvent("legacy_police:badgeon")
AddEventHandler("legacy_police:badgeon", function(playerjob, jobgrade)
    Wait(60)
    local ped = PlayerPedId()

    if not badgeactive then
        badgeactive = true
        Wait(5)
        if playerjob == "police" and jobgrade <= 2 then
            if IsPedMale(ped) then
                Badge = CreateObject(GetHashKey("s_badgedeputy01x"), Badgex, Badgey, Badgez + 0.2, true, false, false)
                AttachEntityToEntity(Badge, ped, MaleboneIndex, Badgex, Badgey, Badgez, -15.0, 0.0, Rotationz, true, true, false, true, 1, true)
                BadgeCoords = GetEntityCoords(Badge)
            else
                Badge = CreateObject(GetHashKey("s_badgedeputy01x"), Badgex, Badgey, Badgez + 0.2, true, false, false)
                AttachEntityToEntity(Badge, ped, FemaleboneIndex, Badgex, Badgey, Badgez, -15.0, 0.0, 30.0, false, true, false, true, 1, true)
                BadgeCoords = GetEntityCoords(Badge)
            end
        elseif playerjob == "police" and jobgrade >= 3 and jobgrade <= 5 then
            if IsPedMale(ped) then
                Badge = CreateObject(GetHashKey("s_badgesherif01x"), Badgex, Badgey, Badgez + 0.2, true, false, false)
                AttachEntityToEntity(Badge, ped, MaleboneIndex, 0.17, -0.19, -0.25, -12.5, 0.0, 30.0, false, true, false, true, 1, true)
                BadgeCoords = GetEntityCoords(Badge)
            else
                Badge = CreateObject(GetHashKey("s_badgesherif01x"), Badgex, Badgey, Badgez + 0.2, true, false, false)
                AttachEntityToEntity(Badge, ped, FemaleboneIndex, 0.17, -0.19, -0.25, -12.5, 0.0, 30.0, false, true, false, true, 1, true)
                BadgeCoords = GetEntityCoords(Badge)
            end
        elseif playerjob == "marshal" and jobgrade ~= nil then
            if IsPedMale(ped) then
                Badge = CreateObject(GetHashKey("s_badgeusmarshal01x"), Badgex, Badgey, Badgez + 0.2, true, false, false)
                AttachEntityToEntity(Badge, ped, MaleboneIndex, 0.17, -0.19, -0.25, -12.5, 0.0, 30.0, false, true, false, true, 1, true)
                BadgeCoords = GetEntityCoords(Badge)
            else
                Badge = CreateObject(GetHashKey("s_badgeusmarshal01x"), Badgex, Badgey, Badgez + 0.2, true, false, false)
                AttachEntityToEntity(Badge, ped, FemaleboneIndex, 0.17, -0.19, -0.25, -12.5, 0.0, 30.0, false, true, false, true, 1, true)
                BadgeCoords = GetEntityCoords(Badge)
            end
        end
        TriggerEvent("vorp:NotifyLeft", ConfigMain.Text.Notify.titlebadge, ConfigMain.Text.Notify.badgeon, "generic_textures", "tick", 2000, "COLOR_GREEN")
    else
        DeleteObject(Badge)
        badgeactive = false
        TriggerEvent("vorp:NotifyLeft", ConfigMain.Text.Notify.titlebadge, ConfigMain.Text.Notify.badgeoff, "generic_textures", "tick", 2000, "COLOR_GREEN")
    end
end)

RegisterNetEvent("lawmen:goonduty")
AddEventHandler("lawmen:goonduty", function()
    if PoliceOnDuty then
        TriggerEvent("vorp:NotifyLeft", ConfigMain.Text.Notify.service, ConfigMain.Text.Notify.onduty, "generic_textures", "tick", 2000, "COLOR_GREEN")
    else
        TriggerServerEvent('lawmen:goondutysv', GetPlayers())
    end
end)

RegisterCommand(ConfigMain.ondutycommand, function()
    TriggerEvent('lawmen:goonduty')
end)

function StartBadgeAdjustment()
    local ped = PlayerPedId()

    if PoliceOnDuty and badgeactive then
        if not display then
            display = true

            SendNUIMessage({
                action = "showpanel",
                title = ConfigMain.ControlsPanel.title,
                controls = ConfigMain.ControlsPanel.controls
            })

            Citizen.CreateThread(function()
                local lastX, lastY, lastZ = nil, nil, nil
                local lastRotZ = nil

                while display and badgeactive do
                    Wait(0)

                    for _, keyCode in pairs(ConfigMain.Keys) do
                        DisableControlAction(0, keyCode, true)
                    end

                    if IsDisabledControlJustPressed(0, ConfigMain.Keys.finistadjust) then
                        display = false
                        SendNUIMessage({ action = "hidepanel" })
                        break
                    end

                    if IsDisabledControlJustPressed(0, ConfigMain.Keys.up) then Badgez = Badgez + 0.01 end
                    if IsDisabledControlJustPressed(0, ConfigMain.Keys.down) then Badgez = Badgez - 0.01 end
                    if IsDisabledControlJustPressed(0, ConfigMain.Keys.left) then Badgex = Badgex + 0.01 end
                    if IsDisabledControlJustPressed(0, ConfigMain.Keys.right) then Badgex = Badgex - 0.01 end
                    if IsDisabledControlJustPressed(0, ConfigMain.Keys.int) then Badgey = Badgey + 0.01 end
                    if IsDisabledControlJustPressed(0, ConfigMain.Keys.out) then Badgey = Badgey - 0.01 end
                    if IsDisabledControlJustPressed(0, ConfigMain.Keys.rotateleft) then Rotationz = Rotationz + 2.0 end
                    if IsDisabledControlJustPressed(0, ConfigMain.Keys.rotateright) then Rotationz = Rotationz - 2.0 end

                    if Badgex ~= lastX or Badgey ~= lastY or Badgez ~= lastZ or Rotationz ~= lastRotZ then
                        local boneIndex = IsPedMale(ped) and MaleboneIndex or FemaleboneIndex
                        AttachEntityToEntity(Badge, ped, boneIndex, Badgex, Badgey, Badgez, -15.0, 0.0, Rotationz, true, true, false, true, 1, true)
                        lastX, lastY, lastZ = Badgex, Badgey, Badgez
                        lastRotZ = Rotationz
                    end
                end
            end)
        else
            display = false
            SendNUIMessage({ action = "hidepanel" })
        end
    end
end

RegisterNetEvent("lawmen:gooffduty")
AddEventHandler("lawmen:gooffduty", function()
    TriggerServerEvent("lawmen:gooffdutysv")
end)

RegisterCommand(ConfigMain.offdutycommand, function()
    TriggerEvent('lawmen:gooffduty')
end)

RegisterCommand(ConfigMain.openpolicemenu, function()
    if not IsEntityDead(PlayerPedId()) then
        TriggerServerEvent("CheckPoliceMenuPermission")
    end
end)

RegisterNetEvent("OpenPoliceMenuClient")
AddEventHandler("OpenPoliceMenuClient", function()
    OpenPoliceMenu()
end)

CreateThread(function()
    while true do
        Citizen.Wait(5)
        if IsHandcuffed then
            DisableControlAction(0, 0xB2F377E8, true)
            DisableControlAction(0, 0xC1989F95, true)
            DisableControlAction(0, 0x07CE1E61, true)
            DisableControlAction(0, 0xF84FA74F, true)
            DisableControlAction(0, 0xCEE12B50, true)
            DisableControlAction(0, 0x8FFC75D6, true)
            DisableControlAction(0, 0xD9D0E1C0, true)
            DisableControlAction(0, 0xF3830D8E, true)
            DisableControlAction(0, 0x80F28E95, true)
            DisableControlAction(0, 0xDB096B85, true)
            DisableControlAction(0, 0xE30CD707, true)
        elseif IsHandcuffed and IsPedDeadOrDying(PlayerPedId()) then
            ClearPedSecondaryTask(PlayerPedId())
            SetEnableHandcuffs(PlayerPedId(), false)
            DisablePlayerFiring(PlayerPedId(), false)
            SetPedCanPlayGestureAnims(PlayerPedId(), true)
            Wait(500)
        else
            Wait(500)
        end
    end
end)

CreateThread(function()
    local wasDragged
    while true do
        Citizen.Wait(5)
        local playerPed = PlayerPedId()
        if IsHandcuffed and dragStatus.isDragged then
            local targetPed = GetPlayerPed(GetPlayerFromServerId(dragStatus.CopId))
            if DoesEntityExist(targetPed) and IsPedOnFoot(targetPed) and not IsPedDeadOrDying(targetPed, true) then
                if not wasDragged then
                    AttachEntityToEntity(playerPed, targetPed, 11816, 0.54, 0.54, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
                    wasDragged = true
                else
                    Citizen.Wait(1000)
                end
            else
                wasDragged = false
                dragStatus.isDragged = false
                DetachEntity(playerPed, true, false)
            end
        elseif wasDragged then
            wasDragged = false
            DetachEntity(playerPed, true, false)
        else
            Wait(500)
        end
    end
end)

RegisterNetEvent('lawmen:drag')
AddEventHandler('lawmen:drag', function(copId)
    if IsHandcuffed then
        dragStatus.isDragged = not dragStatus.isDragged
        dragStatus.CopId = copId
    end
end)

RegisterNetEvent("lawmen:JailPlayer")
AddEventHandler('lawmen:JailPlayer', function(time, Location)
    local ped = PlayerPedId()
    local time_minutes = math.floor(time / 60)

    local JailAlias = {
        sk = "sisika", bw = "blackwater", st = "strawberry", val = "valentine",
        ar = "armadillo", tu = "tumbleweed", rh = "rhodes", sd = "stdenis", an = "annesburg"
    }

    JailID = JailAlias[Location] or Location
    Serviced = false
    EscapeActive = false

    local jailData = ConfigJail.Jails[JailID]
    if jailData then
        JailEntranceCoords = vector3(jailData.entrance.x, jailData.entrance.y, jailData.entrance.z)
    end

    Jail_time = time
    Jailed = true

    if Autotele and JailEntranceCoords then
        DoScreenFadeOut(1000)
        Wait(4000)
        SetEntityCoords(ped, JailEntranceCoords.x, JailEntranceCoords.y, JailEntranceCoords.z)
        DoScreenFadeIn(1000)
        EscapeActive = true
    end
    TriggerEvent("vorp:NotifyLeft", ConfigMain.Text.Notify.prison, ConfigMain.Text.Notify.jailed .. time_minutes .. ConfigMain.Text.Notify.minutes, "generic_textures", "tick", 2000, "COLOR_GREEN")
    TriggerEvent("lawmen:wear_prison", ped)
end)

RegisterNetEvent("lawmen:wear_prison")
AddEventHandler("lawmen:wear_prison", function()
    local ped = PlayerPedId()
    local components = {
        0x9925C067, 0x485EE834, 0x18729F39, 0x3107499B, 0x3C1A74CD, 0x3F1F01E5,
        0x3F7F3587, 0x49C89D9B, 0x4A73515C, 0x514ADCEA, 0x5FC29285, 0x79D7DF96,
        0x7A96FACA, 0x877A2CF7, 0x9B2C8B89, 0xA6D134C6, 0xE06D30CE, 0x662AC34,
        0xAF14310B, 0x72E6EF74, 0xEABE0032, 0x2026C46D
    }

    for _, comp in ipairs(components) do
        Citizen.InvokeNative(0xDF631E4BCE1B1FC4, ped, comp, true, true, true)
    end

    if IsPedMale(ped) then
        Citizen.InvokeNative(0xD3A7B003ED343FD9, ped, 0x5BA76CCF, true, true, true)
        Citizen.InvokeNative(0xD3A7B003ED343FD9, ped, 0x216612F0, true, true, true)
        Citizen.InvokeNative(0xD3A7B003ED343FD9, ped, 0x1CCEE58D, true, true, true)
    else
        Citizen.InvokeNative(0xD3A7B003ED343FD9, ped, 0x6AB27695, true, true, true)
        Citizen.InvokeNative(0xD3A7B003ED343FD9, ped, 0x75BC0CF5, true, true, true)
        Citizen.InvokeNative(0xD3A7B003ED343FD9, ped, 0x14683CDF, true, true, true)
    end

end)

RegisterNetEvent("lawmen:UnjailPlayer")
AddEventHandler("lawmen:UnjailPlayer", function(jaillocation)
    local ped = PlayerPedId()
    local player = PlayerId()

    local JailAlias = {
        sk = "sisika", bw = "blackwater", st = "strawberry", val = "valentine",
        ar = "armadillo", tu = "tumbleweed", rh = "rhodes", sd = "stdenis", an = "annesburg"
    }

    JailID = JailAlias[jaillocation] or jaillocation

    ExecuteCommand('rc')
    TriggerEvent("vorp:NotifyLeft", ConfigMain.Text.Notify.prison, ConfigMain.Text.Notify.leave, "generic_textures", "tick", 2000, "COLOR_GREEN")
    Jailed = false
    Jail_time = 0

    if Autotele then
        local jailData = ConfigJail.Jails[JailID]
        if jailData and jailData.exit then
            SetEntityCoords(ped, jailData.exit.x, jailData.exit.y, jailData.exit.z)
        end
    end

    SetPlayerInvincible(player, false)
    SendNUIMessage({ type = "hideJailTime" })
end)

CreateThread(function()
    while true do
        Wait(1000)

        if Jailed then
            local ped = PlayerPedId()
            local player = PlayerId()

            if Jail_time > 0 then
                Jail_time = Jail_time - 1
                SendNUIMessage({
                    type = "updateJailTime",
                    time = Jail_time,
                    text = ConfigMain.Text.jailTimerLabel
                })
            else
                local server_id = GetPlayerServerId(player)
                TriggerServerEvent("lawmen:finishedjail", server_id)
                SendNUIMessage({ type = "hideJailTime" })
                Jailed = false
                JailEntranceCoords = nil
                EscapeActive = false
                SetPlayerInvincible(player, false)
            end

            if ConfigJail.EscapeConfig.EnableEscapePenalty and JailEntranceCoords and EscapeActive then
                local playerPos = GetEntityCoords(ped)
                local dist = #(playerPos - JailEntranceCoords)

                if dist > Jail_maxDistance then
                    TriggerEvent("vorp:NotifyLeft", ConfigMain.Text.Notify.prison, ConfigMain.Text.Notify.leaveprison, "generic_textures", "tick", 2000, "COLOR_GREEN")
                    SetEntityCoords(ped, JailEntranceCoords.x, JailEntranceCoords.y, JailEntranceCoords.z)
                    Jail_time = Jail_time + Jail_penalty
                    TriggerServerEvent("lawmen:updatejailtime", Jail_time)
                end
            end
        else
            Wait(1000)
        end
    end
end)

CreateThread(function()
    local doingchore = false
    local currentChore = nil
    local choreBlip = nil
    local showingTask = false

    local function AssignRandomChore()
        local chores = ConfigJail.jailchores
        currentChore = chores[math.random(#chores)]

        if choreBlip then RemoveBlip(choreBlip) end
        choreBlip = N_0x554d9d53f696d002(1664425300, currentChore.x, currentChore.y, currentChore.z)
        SetBlipSprite(choreBlip, 28148096, 1)
        Citizen.InvokeNative(0x9CB1A1623062F402, choreBlip, ConfigMain.Text.jailchoreblip)
    end

    while true do
        Wait(5)
        if Jailed then
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)

            if not currentChore then AssignRandomChore() end

            local dist = #(coords - vector3(currentChore.x, currentChore.y, currentChore.z))
            if dist < 5 then
                if not showingTask then
                    SendNUIMessage({
                        type = 'showTask',
                        text = ConfigMain.Text.taskMessage
                    })
                    showingTask = true
                end

                if IsControlJustReleased(0, 0x760A9C6F) and not doingchore then
                    doingchore = true
                    SendNUIMessage({ type = 'hideTask' })
                    showingTask = false

                    TaskStartScenarioInPlace(ped, GetHashKey('WORLD_HUMAN_BROOM_WORKING'), 20000, true, false, false, false)
                    Wait(20000)

                    ClearPedTasksImmediately(ped)
                    ClearPedSecondaryTask(ped)
                    SetCurrentPedWeapon(ped, GetHashKey('WEAPON_UNARMED'), true)

                    local broom = GetClosestObjectOfType(GetEntityCoords(ped), 2.0, GetHashKey("prop_broom"), false, false, false)
                    if broom ~= 0 then
                        local netId = NetworkGetNetworkIdFromEntity(broom)
                        TriggerServerEvent("lawmen:deleteBroom", netId)
                    end

                    TriggerServerEvent("lawmen:clearChoreProp", GetPlayerServerId(PlayerId()))

                    Jail_time = Jail_time - (currentChore.timeReduction or 10)
                    if Jail_time < 0 then Jail_time = 0 end

                    TriggerServerEvent("lawmen:updatejailtime", Jail_time)

                    AssignRandomChore()
                    Wait(1000)
                    doingchore = false
                end
            else
                if showingTask then
                    SendNUIMessage({ type = 'hideTask' })
                    showingTask = false
                end
            end
        else
            if choreBlip then
                RemoveBlip(choreBlip)
                choreBlip = nil
                currentChore = nil
            end

            if showingTask then
                SendNUIMessage({ type = 'hideTask' })
                showingTask = false
            end

            Wait(500)
        end
    end
end)

RegisterNetEvent("lawmen:tryHandcuff")
AddEventHandler("lawmen:tryHandcuff", function()
    local closestPlayer, closestDistance = GetClosestPlayer()
    if closestPlayer ~= -1 and closestDistance <= 3.0 then
        HandcuffPlayer(closestPlayer)
    else
        TriggerEvent("vorp:NotifyLeft", ConfigMain.Text.Notify.handcuff, ConfigMain.Text.Notify.notcloseenough, "menu_textures", "cross", 2000, "COLOR_RED")
    end
end)

RegisterNetEvent("lawmen:lockpick")
AddEventHandler("lawmen:lockpick", function()
    local closestPlayer, closestDistance = GetClosestPlayer()
    local isDead = IsEntityDead(PlayerPedId())

    if closestPlayer ~= -1 and closestDistance <= 3.0 then
        local chance = math.random(1, 100)
        if not isDead then
            if chance < 85 then
                local anim = "mini_games@story@mud5@cracksafe_look_at_dial@med_r@ped"
                local idle = "base_idle"
                local lr = "left_to_right"
                local rl = "right_to_left"
                RequestAnimDict(anim)
                while not HasAnimDictLoaded(anim) do
                    Wait(50)
                end

                TaskPlayAnim(PlayerPedId(), anim, idle, 8.0, -8.0, -1, 32, 0, false, false, false)
                Wait(1250)
                TaskPlayAnim(PlayerPedId(), anim, lr, 8.0, -8.0, -1, 32, 0, false, false, false)
                Wait(325)
                TaskPlayAnim(PlayerPedId(), anim, idle, 8.0, -8.0, -1, 32, 0, false, false, false)
                Wait(1250)
                TaskPlayAnim(PlayerPedId(), anim, rl, 8.0, -8.0, -1, 32, 0, false, false, false)
                Wait(325)
                repeat
                    TriggerEvent("lawmen:lockpick")
                until (chance)
            end
            if chance >= 85 then
                local breakChance = math.random(1, 10)
                if breakChance < 3 then
                    TriggerServerEvent("lawmen:lockpick:break")
                else
                    local anim = "mini_games@story@mud5@cracksafe_look_at_dial@small_r@ped"
                    local open = "open"
                    RequestAnimDict(anim)
                    while not HasAnimDictLoaded(anim) do
                        Wait(50)
                    end
                    TaskPlayAnim(PlayerPedId(), anim, open, 8.0, -8.0, -1, 32, 0, false, false, false)
                    Citizen.Wait(1250)
                    TriggerServerEvent('lawmen:lockpicksv', GetPlayerServerId(closestPlayer))
                end
            end
        end
    else
        TriggerEvent("vorp:NotifyLeft", ConfigMain.Text.Notify.lockpick, ConfigMain.Text.Notify.notcloseenough, "menu_textures", "cross", 2000, "COLOR_RED")
        return
    end
end)

RegisterNetEvent('lawmen:handcuff', function()
    local playerPed = PlayerPedId()
    if not IsHandcuffed then
        IsHandcuffed = true
        SetEnableHandcuffs(playerPed, true)
        Citizen.InvokeNative(0x7981037A96E7D174, playerPed)
        DisablePlayerFiring(playerPed, true)
        SetCurrentPedWeapon(playerPed, GetHashKey('WEAPON_UNARMED'), true)
        SetPedCanPlayGestureAnims(playerPed, false)
    else
        IsHandcuffed = false
        ClearPedSecondaryTask(playerPed)
        SetEnableHandcuffs(playerPed, false)
        Citizen.InvokeNative(0x67406F2C8F87FC4F, playerPed)
        DisablePlayerFiring(playerPed, false)
        SetPedCanPlayGestureAnims(playerPed, true)
    end
end)

RegisterNetEvent('lawmen:lockpicked')
AddEventHandler('lawmen:lockpicked', function()
    local playerPed = PlayerPedId()
    ClearPedSecondaryTask(playerPed)
    SetEnableHandcuffs(playerPed, false)
    DisablePlayerFiring(playerPed, false)
    SetPedCanPlayGestureAnims(playerPed, true)
    IsHandcuffed = false
end)

local commisaryBlip = nil
local blipCoords = ConfigJail.Jails.sisika.Commisary.coords

local function CreateCommisaryBlip()
    if commisaryBlip == nil then
        commisaryBlip = N_0x554d9d53f696d002(1664425300, blipCoords.x, blipCoords.y, blipCoords.z)
        SetBlipSprite(commisaryBlip, 28148096, 1)
        SetBlipScale(commisaryBlip, 0.5)
        Citizen.InvokeNative(0x9CB1A1623062F402, commisaryBlip, "Comisary")
    end
end

local function RemoveCommisaryBlip()
    if commisaryBlip ~= nil then
        RemoveBlip(commisaryBlip)
        commisaryBlip = nil
    end
end

CreateThread(function()
    if ConfigJail.Jails.sisika.Commisary.enable then
        local showingComisary = false

        while true do
            Wait(5)
            local pl = GetEntityCoords(PlayerPedId())
            local dist = GetDistanceBetweenCoords(pl.x, pl.y, pl.z, blipCoords.x, blipCoords.y, blipCoords.z, true)

            if Jailed then
                CreateCommisaryBlip()

                if dist < 5 then
                    if not showingComisary then
                        SendNUIMessage({
                            type = 'showComisary',
                            text = ConfigMain.Text.comisaryMessage
                        })
                        showingComisary = true
                    end

                    if IsControlJustReleased(0, 0x760A9C6F) then
                        TriggerServerEvent('legacy_police:CommisaryAddItem')
                    end
                else
                    if showingComisary then
                        SendNUIMessage({ type = 'hideComisary' })
                        showingComisary = false
                    end

                    if dist > 200 then
                        Wait(2000)
                    end
                end
            else
                if showingComisary then
                    SendNUIMessage({ type = 'hideComisary' })
                    showingComisary = false
                end

                RemoveCommisaryBlip()
                Wait(1000)
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(30000)
        if Jailed then
            TriggerServerEvent("lawmen:updatejailtime", Jail_time)
        end
    end
end)

local spawn_wagon = nil

function GetCurentTownName()
    local pedCoords = GetEntityCoords(PlayerPedId())
    local town_hash = Citizen.InvokeNative(0x43AD8FC02B429D33, pedCoords, 1)

    local townNames = {
        [GetHashKey("Annesburg")] = "Annesburg",
        [GetHashKey("Armadillo")] = "Armadillo",
        [GetHashKey("Blackwater")] = "Blackwater",
        [GetHashKey("Rhodes")] = "Rhodes",
        [GetHashKey("StDenis")] = "Saint Denis",
        [GetHashKey("Strawberry")] = "Strawberry",
        [GetHashKey("Tumbleweed")] = "Tumbleweed",
        [GetHashKey("valentine")] = "Valentine"
    }

    return townNames[town_hash]
end

RegisterNetEvent('lawmen:spawnWagon')
AddEventHandler('lawmen:spawnWagon', function(wagonModel, coords)
    if DoesEntityExist(spawn_wagon) then
        DeleteVehicle(spawn_wagon)
        spawn_wagon = nil
    end

    RequestModel(GetHashKey(wagonModel))
    while not HasModelLoaded(GetHashKey(wagonModel)) do
        Citizen.Wait(10)
    end

    local wagon = CreateVehicle(GetHashKey(wagonModel), coords.x, coords.y, coords.z, coords.h, true, false)
    SetEntityAsMissionEntity(wagon, true, true)

    local netId = NetworkGetNetworkIdFromEntity(wagon)
    SetNetworkIdExistsOnAllMachines(netId, true)

    SetModelAsNoLongerNeeded(GetHashKey(wagonModel))
    spawn_wagon = wagon
end)

function GetClosestWagon(radius)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local closestWagon = nil
    local closestDist = radius

    local vehicles = GetGamePool("CVehicle")
    for _, veh in ipairs(vehicles) do
        if DoesEntityExist(veh) then
            local model = GetEntityModel(veh)
            for _, wagon in ipairs(ConfigMain.Wagons) do
                if model == GetHashKey(wagon.wagon) then
                    local dist = #(playerCoords - GetEntityCoords(veh))
                    if dist < closestDist then
                        closestDist = dist
                        closestWagon = veh
                    end
                end
            end
        end
    end

    if closestWagon then
        return NetworkGetNetworkIdFromEntity(closestWagon)
    end
    return nil
end

RegisterNetEvent("lawmen:deleteWagon")
AddEventHandler("lawmen:deleteWagon", function()
    local wagonNetId = GetClosestWagon(5.0)
    if wagonNetId then
        TriggerServerEvent("lawmen:DeleteWagonServer", wagonNetId)
    else
        TriggerEvent("vorp:NotifyLeft", ConfigMain.Text.Notify.wagon, ConfigMain.Text.Notify.notwagon, "menu_textures", "cross", 2000, "COLOR_RED")
    end
end)

RegisterNetEvent("lawmen:DeleteWagonGlobal")
AddEventHandler("lawmen:DeleteWagonGlobal", function(wagonNetId)
    if NetworkDoesNetworkIdExist(wagonNetId) then
        local wagon = NetToVeh(wagonNetId)
        if DoesEntityExist(wagon) then
            DeleteVehicle(wagon)
        end
    end
end)

Citizen.CreateThread(function()
    local showingWagon = false

    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local nearStation = false

        for _, stationCoords in ipairs(ConfigMain.Stations) do
            if #(playerCoords - stationCoords) < 1.5 then
                nearStation = true

                if not showingWagon then
                    SendNUIMessage({
                        type = "showWagon",
                        text = ConfigMain.Text.wagonMessage
                    })
                    showingWagon = true
                end

                if IsControlJustReleased(0, 0x760A9C6F) then
                    TriggerServerEvent("lawmen:CheckJob")
                end
                break
            end
        end

        if not nearStation and showingWagon then
            SendNUIMessage({ type = "hideWagon" })
            showingWagon = false
        end

        Citizen.Wait(nearStation and 0 or 500)
    end
end)

RegisterNetEvent("lawmen:JobAccepted")
AddEventHandler("lawmen:JobAccepted", function()
    TriggerEvent("lawmen:OpenWagonMenu")
end)

RegisterNetEvent("lawmen:JobDenied")
AddEventHandler("lawmen:JobDenied", function()
    TriggerEvent("vorp:NotifyLeft", ConfigMain.Text.Notify.job, ConfigMain.Text.Notify.notjob, "menu_textures", "cross", 2000, "COLOR_RED")
end)

RegisterNetEvent("lawmen:JobCabinetAccepted")
AddEventHandler("lawmen:JobCabinetAccepted", function()
    CabinetMenu()
end)

RegisterNetEvent("lawmen:JobCabinetDenied")
AddEventHandler("lawmen:JobCabinetDenied", function()
    TriggerEvent("vorp:NotifyLeft", ConfigMain.Text.Notify.job, ConfigMain.Text.Notify.notjob, "menu_textures", "cross", 2000, "COLOR_RED")
end)

local showingStorage = false
local currentStorageKey = nil

Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local nearStorage = false

        for key, data in pairs(ConfigMain.Storage) do
            local distance = #(playerCoords - data.Coords)
            if distance < 1.5 then
                nearStorage = true

                if not showingStorage then
                    SendNUIMessage({
                        type = "showStorage",
                        text = ConfigMain.Text.storage
                    })
                    showingStorage = true
                end

                currentStorageKey = key

                if IsControlJustReleased(0, 0x760A9C6F) then
                    if not isPlayerNearby() then
                        TriggerServerEvent("lawmen:checkstoragejob", currentStorageKey)
                    else
                        TriggerEvent("vorp:NotifyLeft", ConfigMain.Text.Notify.lockpick, ConfigMain.Text.Notify.playernearby, "menu_textures", "cross", 2000, "COLOR_RED")
                    end
                end
                break
            end
        end

        if not nearStorage and showingStorage then
            SendNUIMessage({ type = "hideStorage" })
            showingStorage = false
        end

        Citizen.Wait(nearStorage and 0 or 500)
    end
end)

RegisterNetEvent("lawmen:JobStorageAccepted")
AddEventHandler("lawmen:JobStorageAccepted", function(key)
    TriggerServerEvent("lawmen:Server:OpenStorage", key)
end)

RegisterNetEvent("lawmen:JobStorageDenied")
AddEventHandler("lawmen:JobStorageDenied", function(key)
    TriggerEvent("vorp:NotifyLeft", ConfigMain.Text.Notify.storage, ConfigMain.Text.Notify.notaccess, "menu_textures", "cross", 3000, "COLOR_RED")
end)

function isPlayerNearby()
    local players = GetActivePlayers()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    for _, playerId in ipairs(players) do
        if playerId ~= PlayerId() then
            local targetPed = GetPlayerPed(playerId)
            local targetCoords = GetEntityCoords(targetPed)
            if #(coords - targetCoords) < 2.0 then
                return true
            end
        end
    end
    return false
end

CreateThread(function()
    if ConfigMain.ShowBlip then 
        for i = 1, #ConfigMain.PoliceStationblip do 
            local zone = ConfigMain.PoliceStationblip[i]
            if zone.blips and type(zone.blips) == "number" then
                local blip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, zone.coords.x, zone.coords.y, zone.coords.z) 
                SetBlipSprite(blip, zone.blips, 1)
                SetBlipScale(blip, 0.8)
                Citizen.InvokeNative(0x9CB1A1623062F402, blip, zone.blipsName)
            end
        end
    end
end)

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName == GetCurrentResourceName() then
        RemoveBlip(blip)
        RemoveBlip(choreBlip)
        RemoveCommisaryBlip()
    end
end)
