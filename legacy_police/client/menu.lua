local Menu = exports.vorp_menu:GetMenuData()
local Tele = ConfigMain.Text.Menu.vartrue
local timeinjail = 0
local Playerid = 0
local jailname = ConfigMain.Text.Menu.none

PlayerIDInput = {
    type = "enableinput",
    inputType = "input",
    button = ConfigMain.Text.Input.inputconfirm,
    placeholder = ConfigMain.Text.Input.playerid,
    style = "block",
    attributes = {
        inputHeader = ConfigMain.Text.Input.playerid,
        type = "number",
        pattern = "[0-9]",
        title = ConfigMain.Text.Input.numberonly,
        style = "border-radius: 10px; background-color: ; border:none;"
    }
}

JailTime = {
    type = "enableinput",
    inputType = "input",
    button = ConfigMain.Text.Input.inputconfirm,
    placeholder = ConfigMain.Text.Input.jailamount,
    style = "block",
    attributes = {
        inputHeader = ConfigMain.Text.Input.jailamount,
        type = "number",
        pattern = "[0-9]",
        title = ConfigMain.Text.Input.numberonly,
        style = "border-radius: 10px; background-color: ; border:none;"
    }
}

function OpenPoliceMenu()
    Inmenu = true
    Menu.CloseAll()
    local elements = {
        { label = ConfigMain.Text.Menu.togglebadge,     value = 'star' },
        { label = ConfigMain.Text.Menu.idmenu,          value = 'idmenu' },
        { label = ConfigMain.Text.Menu.cufftoggle,      value = 'cuff' },
        { label = ConfigMain.Text.Menu.escort,          value = 'escort' },
        { label = ConfigMain.Text.Menu.putinoutvehicle, value = 'vehicle' },
        { label = ConfigMain.Text.Menu.jailplayer,      value = 'jail' },
        { label = ConfigMain.Text.Menu.unjailplayer,    value = 'unjail' },
    }
    Menu.Open('default', GetCurrentResourceName(), 'menuapi',
        {
            title    = ConfigMain.Text.Menu.lawmenu,
            align    = 'top-right',
            elements = elements,
        },
        function(data, menu)
            if (data.current.value == 'star') then
                menu.close()
                TriggerServerEvent('legacy_police:checkjob')
            elseif (data.current.value == 'cuff') then
                local closestPlayer, closestDistance = GetClosestPlayer()
                if closestPlayer ~= -1 and closestDistance <= 3.0 then
                    HandcuffPlayer()
                else
                    TriggerEvent("vorp:NotifyLeft", ConfigMain.Text.Notify.handcuff, ConfigMain.Text.Notify.notcloseenough, "menu_textures", "cross", 2000, "COLOR_RED")
                end
            elseif (data.current.value == 'escort') then
                local closestPlayer, closestDistance = GetClosestPlayer()
                if closestPlayer ~= -1 and closestDistance <= 3.0 then
                    TriggerServerEvent('lawmen:drag', GetPlayerServerId(closestPlayer))
                else
                    TriggerEvent("vorp:NotifyLeft", ConfigMain.Text.Notify.escort, ConfigMain.Text.Notify.notcloseenough, "menu_textures", "cross", 2000, "COLOR_RED")
                end
            elseif (data.current.value == 'vehicle') then
                local ped = PlayerPedId()
                local coords = GetEntityCoords(ped)
                local closestWagon, distance = GetClosestVehicle(coords)
                if closestWagon ~= -1 and distance <= 5.0 then
                    PutInOutVehicle()
                else
                    TriggerEvent("vorp:NotifyLeft", ConfigMain.Text.Notify.wagon, ConfigMain.Text.Notify.notcloseenoughtowagon, "menu_textures", "cross", 2000, "COLOR_RED")
                end
            elseif (data.current.value == 'jail') then
                OpenJailMenu()
            elseif (data.current.value == 'unjail') then
                OpenUnjailMenu()    
            elseif (data.current.value == 'idmenu') then
                OpenIDMenu()
            end
        end,
        function(data, menu)
            Inmenu = false
            menu.close()
        end)
end

function OpenJailMenu()
    Menu.CloseAll()
    local elements = {
        { label = ConfigMain.Text.Menu.playerid .. "<span style='margin-left:10px; color: Red;'>" .. (Playerid) .. '</span>', value = 'id' },
        { label = ConfigMain.Text.Menu.jailamount .. "<span style='margin-left:10px; color: Red;'>" .. (timeinjail) .. '</span>', value = 'time' },
        { label = ConfigMain.Text.Menu.autotele .. (Tele or ""), value = 'auto', desc = ConfigMain.Text.Menu.autoteledesc },
        { label = ConfigMain.Text.Menu.jaillocaiton .. (jailname or ""), value = 'loc' },
        { label = ConfigMain.Text.Menu.jail, value = 'jail', desc = ConfigMain.Text.Menu.jaildesc }
    }

    Menu.Open('default', GetCurrentResourceName(), 'menuapi',
    {
        title    = ConfigMain.Text.Menu.jailmenu,
        align    = 'top-right',
        elements = elements,
        lastmenu = nil
    },
    function(data, menu)
        if data.current.value == 'id' then
            TriggerEvent("vorpinputs:advancedInput", json.encode(PlayerIDInput), function(result)
                local amount = tonumber(result)
                if amount and amount > 0 then
                    Playerid = amount
                    menu.close()
                    OpenJailMenu()
                end
            end)

        elseif data.current.value == 'time' then
            TriggerEvent("vorpinputs:advancedInput", json.encode(JailTime), function(result)
                local amount = tonumber(result)
                if amount and amount > 0 then
                    timeinjail = amount
                    menu.close()
                    OpenJailMenu()
                end
            end)

        elseif data.current.value == 'jail' then
            Wait(500)
            if JailID == nil then JailID = 'sk' end
            TriggerServerEvent('lawmen:JailPlayerServer', tonumber(Playerid), tonumber(timeinjail), JailID)
            menu.close()

        elseif data.current.value == 'auto' then
            Autotele = not Autotele
            Tele = Autotele and ConfigMain.Text.Menu.vartrue or ConfigMain.Text.Menu.varfalse
            menu.close()
            OpenJailMenu()

        elseif data.current.value == 'loc' then
            OpenSubJailMenu()
        end
    end,
    function(data, menu)
        menu.close()
    end)
end

function OpenUnjailMenu()
    Menu.CloseAll()
    local elements = {
        { label = ConfigMain.Text.Menu.playerid .. "<span style='margin-left:10px; color: Red;'>" .. (Playerid) .. '</span>', value = 'id' },
        { label = ConfigMain.Text.Menu.unjail, value = 'unjail', desc = ConfigMain.Text.Menu.unjaildesc }
    }

    Menu.Open('default', GetCurrentResourceName(), 'menuapi',
    {
        title    = ConfigMain.Text.Menu.jailmenu,
        align    = 'top-right',
        elements = elements,
        lastmenu = nil
    },
    function(data, menu)
        if data.current.value == 'id' then
            TriggerEvent("vorpinputs:advancedInput", json.encode(PlayerIDInput), function(result)
                local amount = tonumber(result)
                if amount and amount > 0 then
                    Playerid = amount
                    menu.close()
                    OpenUnjailMenu()
                end
            end)

        elseif data.current.value == 'unjail' then
            if Playerid ~= nil then
                TriggerServerEvent('lawmen:unjailed', Playerid, JailID)
                menu.close()
            else
                TriggerEvent("vorp:TipRight", "Debes ingresar un ID válido", 3000)
            end
        end
    end,
    function(data, menu)
        menu.close()
    end)
end


function OpenSubJailMenu()
    Menu.CloseAll()
    local elements = {
        { label = ConfigMain.Text.Menu.valjail, value = "val" },
        { label = ConfigMain.Text.Menu.bwjail,  value = 'bw' },
        { label = ConfigMain.Text.Menu.sdjail,  value = "sd" },
        { label = ConfigMain.Text.Menu.rhjail,  value = "rh" },
        { label = ConfigMain.Text.Menu.stjail,  value = "st" },
        { label = ConfigMain.Text.Menu.arjail,  value = "ar" },
        { label = ConfigMain.Text.Menu.tujail,  value = "tu" },
        { label = ConfigMain.Text.Menu.anjail,  value = "an" },
        { label = ConfigMain.Text.Menu.sisika,  value = "sk" },
    }
    Menu.Open('default', GetCurrentResourceName(), 'menuapi',
        {
            title    = ConfigMain.Text.Menu.jailmenu,
            align    = 'top-right',
            elements = elements,
            lastmenu = "OpenJailMenu"
        },
        function(data, menu)
            if data.current == "backup" then
                _G[data.trigger]()
            elseif data.current.value then
                jailname = data.current.label
                JailID = data.current.value
                menu.close()
                OpenJailMenu()
            end
        end,
        function(data, menu)
            menu.close()
        end)
end

function CloseMenu()
    Inmenu = false
    Menu.CloseAll()
end

function WeaponMenu()
    Menu.CloseAll()
    local elements = {}

    for i, item in ipairs(ConfigCabinets.WeaponsandAmmo.Weapons) do
        local imgPath = "nui://vorp_inventory/html/img/items/" .. item.weapon .. ".png"
        local labelHTML = "<div style='display:flex;align-items:center;gap:10px;'>"
                        .. "<img src='" .. imgPath .. "' style='width:32px;height:32px;'>"
                        .. "<span>" .. item.label .. "</span></div>"

        table.insert(elements, {
            label = labelHTML,
            value = i,
            desc  = ConfigMain.Text.Menu.gradeRequired .. item.allowedGrade
        })
    end

    Menu.Open('default', GetCurrentResourceName(), 'weapon_menu', {
        title    = ConfigMain.Text.Menu.grabweapons,
        align    = 'top-right',
        elements = elements,
        lastmenu = "CabinetMenu"
    },
    function(data, menu)
        local index = data.current.value
        TriggerServerEvent("lawmen:guncabinet", index)
        CloseMenu()
    end,
    function(data, menu)
        CloseMenu()
    end)
end


function AmmoMenu()
    Menu.CloseAll()
    local elements = {}

    for i, item in ipairs(ConfigCabinets.WeaponsandAmmo.Ammo) do
        local imgPath = "nui://vorp_inventory/html/img/items/" .. item.ammo .. ".png"
        local labelHTML = "<div style='display:flex;align-items:center;gap:10px;'>"
                        .. "<img src='" .. imgPath .. "' style='width:32px;height:32px;'>"
                        .. "<span>" .. item.label .. "</span></div>"

        table.insert(elements, {
            label = labelHTML,
            value = i,
            desc  = ConfigMain.Text.Menu.gradeRequired .. item.allowedGrade
        })
    end

    Menu.Open('default', GetCurrentResourceName(), 'ammo_menu', {
        title    = ConfigMain.Text.Menu.grabammo,
        align    = 'top-right',
        elements = elements,
        lastmenu = "CabinetMenu"
    },
    function(data, menu)
        local index = data.current.value
        TriggerServerEvent("lawmen:addammo", index)
        Inmenu = false
        menu.close()
    end,
    function(data, menu)
        Inmenu = false
        menu.close()
    end)
end


function CabinetMenu()
    Menu.CloseAll()
    local elements = {
        { label = ConfigMain.Text.Menu.grabammo,    value = 'ammo' },
        { label = ConfigMain.Text.Menu.grabweapons, value = 'wep' },
    }

    Menu.Open('default', GetCurrentResourceName(), 'cabinet_menu', {
        title    = ConfigMain.Text.Menu.cabinet,
        align    = 'top-right',
        elements = elements
    },
    function(data, menu)
        if data.current.value == "ammo" then
            AmmoMenu()
        elseif data.current.value == "wep" then
            WeaponMenu()
        end
    end,
    function(data, menu)
        menu.close()
        Inmenu = false
    end)
end


function OpenIDMenu()
    Menu.CloseAll()
    local elements = {
        { label = ConfigMain.Text.Menu.citizenid, value = 'getid' },
    }
    if ConfigMain.CheckHorse then
        table.insert(elements, { label = ConfigMain.Text.Menu.horseowner, value = 'getowner', desc = ConfigMain.Text.Menu.horseownerdesc })
    end
    Menu.Open('default', GetCurrentResourceName(), 'menuapi',
        {
            title    = ConfigMain.Text.Menu.idmenu,
            align    = 'top-right',
            elements = elements,
            lastmenu = "OpenPoliceMenu"
        },
        function(data, menu)
            if data.current == "backup" then
                _G[data.trigger]()
            elseif data.current.value == "getid" then
                local closestPlayer, closestDistance = GetClosestPlayer()
                if closestPlayer ~= -1 and closestDistance <= 3.0 then
                    TriggerServerEvent('lawmen:GetID', GetPlayerServerId(closestPlayer))
                end
            elseif data.current.value == "getowner" then
                local closestPlayer, closestDistance = GetClosestPlayer()
                if closestPlayer ~= -1 and closestDistance <= 3.0 then
                    local mount = GetMount(PlayerPedId())
                    TriggerServerEvent('lawmen:getVehicleInfo', GetPlayerServerId(closestPlayer), GetEntityModel(mount))
                else
                    local mount = GetMount(PlayerPedId())
                    local id = GetPlayerServerId(GetPlayerIndex())
                    TriggerServerEvent('lawmen:getVehicleInfo', id, GetEntityModel(mount))
                end
            end
        end,
        function(data, menu)
            CloseMenu()
        end)
end

function SearchMenu(takenmoney)
    Menu.CloseAll()
    Inmenu = true
    local elements = {
        { label = ConfigMain.Text.Menu.playermoney .. takenmoney, value = 'Money' },
        { label = ConfigMain.Text.Menu.checkitems, value = 'Items' },

    }
    Menu.Open('default', GetCurrentResourceName(), 'menuapi',
        {
            title    = "Search Menu",
            align    = 'top-right',
            elements = elements
        },
        function(data, menu)
            if data.current == "backup" then
                _G[data.trigger]()
            elseif data.current.value == "Items" then
                TriggerEvent('lawmen:StartSearch')
            end
        end,
        function(data, menu)
            menu.close()
            Inmenu = false
        end)
end

RegisterNetEvent("lawmen:OpenWagonMenu")
AddEventHandler("lawmen:OpenWagonMenu", function()
    local town = GetCurentTownName()
    if not town or not ConfigMain.SpawnCoords[town] then
        TriggerEvent("vorp:NotifyLeft", ConfigMain.Text.Notify.wagon, ConfigMain.Text.Notify.nocoords, "menu_textures", "cross", 2000, "COLOR_RED")
        return
    end

    local elements = {}
    for _, data in ipairs(ConfigMain.Wagons) do
        table.insert(elements, {
            label = data.label,
            value = data.wagon,
            desc = string.format("%s%d", ConfigMain.Text.Menu.gradeRequired, data.allowedGrade)
        })
    end

    Menu.Open('default', GetCurrentResourceName(), 'wagon_menu', {
        title   = ConfigMain.Text.Menu.wagonmenutitle,
        subtext = ConfigMain.Text.Menu.wagonmenusub .. town,
        align   = 'top-right',
        elements = elements,
    }, function(data, menu)
        local coords = ConfigMain.SpawnCoords[town]
        TriggerServerEvent('lawmen:RequestSpawnWagon', data.current.value, coords)

        menu.close()
    end, function(data, menu)
        menu.close()
    end)
end)
