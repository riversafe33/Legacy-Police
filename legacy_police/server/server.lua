local VorpInv = {}
VorpInv = exports.vorp_inventory:vorp_inventoryApi()
local VORPcore = exports.vorp_core:GetCore()

RegisterNetEvent("lawmen:deleteBroom")
AddEventHandler("lawmen:deleteBroom", function(netId)
    local entity = NetworkGetEntityFromNetworkId(netId)
    if DoesEntityExist(entity) then
        DeleteEntity(entity)
    end
end)

RegisterServerEvent("lawmen:grabdata")
AddEventHandler("lawmen:grabdata", function(id)
    local _source = source
    local player = VORPcore.getUser(id).getUsedCharacter
    local playermoney = player.money
    TriggerClientEvent('lawmen:senddata', _source, playermoney)
end)

RegisterServerEvent("lawmen:goondutysv")
AddEventHandler("lawmen:goondutysv", function(ptable)
    local _source = source
    local player = VORPcore.getUser(_source).getUsedCharacter
    local job = player.job
    local grade = player.jobGrade

    local jobIndex = nil
    for i, v in ipairs(OffDutyJobs) do
        if v == job then
            jobIndex = i
            break
        end
    end

    if jobIndex then
        player.setJob(ConfigMain.allowedJobs[jobIndex], grade)
        VORPcore.NotifyLeft(_source, ConfigMain.Text.Notify.service, ConfigMain.Text.Notify.goonduty, "generic_textures", "tick", 4000, "COLOR_GREEN")
        TriggerClientEvent("lawmen:onduty", _source, true)
    else
        VORPcore.NotifyLeft(_source, ConfigMain.Text.Notify.job, ConfigMain.Text.Notify.nojob, "menu_textures", "cross", 3000, "COLOR_RED")
    end
end)

RegisterServerEvent('legacy_police:checkjob')
AddEventHandler('legacy_police:checkjob', function()
    local _source = source
    local User = VORPcore.getUser(_source)
    local Character = User.getUsedCharacter
    local job = Character.job
    local jobgrade = Character.jobGrade
    TriggerClientEvent('legacy_police:badgeon', _source, job, jobgrade)
end)

RegisterServerEvent("lawmen:gooffdutysv")
AddEventHandler("lawmen:gooffdutysv", function()
    local _source = source
    local player = VORPcore.getUser(_source).getUsedCharacter
    local job = player.job
    local grade = player.jobGrade
    for k, v in pairs(ConfigMain.allowedJobs) do
        if v == job then
            player.setJob('off' .. job, grade)
            VORPcore.NotifyLeft(_source, ConfigMain.Text.Notify.service, ConfigMain.Text.Notify.gooffduty, "generic_textures", "tick", 4000, "COLOR_GREEN")
        end
        TriggerClientEvent("lawmen:onduty", _source, false)
    end
end)

RegisterServerEvent('lawmen:JailPlayerServer')
AddEventHandler('lawmen:JailPlayerServer', function(player, amount, loc)
    local _source = source

    if not player or player == 0 then
        VORPcore.NotifyLeft(_source, ConfigMain.Text.Notify.id, ConfigMain.Text.Notify.idinvalid, "menu_textures", "cross", 3000, "COLOR_RED")
        return
    end

    local targetUser = VORPcore.getUser(player)
    local sourceUser = VORPcore.getUser(_source)

    if not targetUser or not targetUser.getUsedCharacter then
        VORPcore.NotifyLeft(_source, ConfigMain.Text.Notify.id, ConfigMain.Text.Notify.idincorret, "menu_textures", "cross", 3000, "COLOR_RED")
        return
    end

    local target = targetUser.getUsedCharacter
    local user = sourceUser.getUsedCharacter
    local username = user.firstname .. ' ' .. user.lastname
    local Job = user.job
    local targetname = target.firstname .. ' ' .. target.lastname
    local steam_id = target.identifier
    local Character = target.charIdentifier

    local amountInSeconds = amount * 60

    exports.oxmysql:execute("SELECT * FROM jail WHERE characterid = @characterid", {
        ["@characterid"] = Character
    }, function(result)
        if result[1] then
            VORPcore.NotifyLeft(_source, ConfigMain.Text.Notify.prison, ConfigMain.Text.Notify.inprison, "menu_textures", "cross", 3000, "COLOR_RED")
            return
        end

        exports.oxmysql:execute(
            "INSERT INTO jail (identifier, characterid, name, time_s, jaillocation) VALUES (@identifier, @characterid, @name, @time, @jaillocation)",
            {
                ["@identifier"] = steam_id,
                ["@characterid"] = Character,
                ["@name"] = targetname,
                ["@time"] = amountInSeconds,
                ["@jaillocation"] = loc
            },
            function()
                TriggerClientEvent("lawmen:JailPlayer", player, amountInSeconds, loc)
            end
        )
    end)
end)

RegisterServerEvent("lawmen:finishedjail")
AddEventHandler("lawmen:finishedjail", function(target_id)
    local target = VORPcore.getUser(target_id).getUsedCharacter
    local steam_id = target.identifier
    local Character = target.charIdentifier

    exports.oxmysql:execute("SELECT * FROM `jail` WHERE characterid = @characterid", {
        ["@characterid"] = Character
    }, function(result)
        if result[1] then
            local loc = result[1]["jaillocation"]
            TriggerClientEvent("lawmen:UnjailPlayer", target_id, loc)
        end
    end)

    exports.oxmysql:execute("DELETE FROM jail WHERE identifier = @identifier AND characterid = @characterid", {
        ["@identifier"] = steam_id,
        ["@characterid"] = Character
    })
end)

RegisterServerEvent("lawmen:unjailed")
AddEventHandler("lawmen:unjailed", function(target_id, loc)
    local _source = source

    if not target_id or target_id == 0 then
        VORPcore.NotifyLeft(_source, ConfigMain.Text.Notify.id, ConfigMain.Text.Notify.idinvalid, "menu_textures", "cross", 3000, "COLOR_RED")
        return
    end

    local targetUser = VORPcore.getUser(target_id)
    local user = VORPcore.getUser(_source).getUsedCharacter

    if not targetUser or not targetUser.getUsedCharacter then
        VORPcore.NotifyLeft(_source, ConfigMain.Text.Notify.id, ConfigMain.Text.Notify.idincorret, "menu_textures", "cross", 3000, "COLOR_RED")
        return
    end

    local target = targetUser.getUsedCharacter
    local username = user.firstname .. ' ' .. user.lastname
    local Job = user.job
    local targetname = target.firstname .. ' ' .. target.lastname
    local steam_id = target.identifier
    local Character = target.charIdentifier

    exports.oxmysql:execute("SELECT * FROM `jail` WHERE characterid = @characterid", {
        ["@characterid"] = Character
    }, function(result)
        if result[1] then
            local jailLoc = result[1]["jaillocation"]
            TriggerClientEvent("lawmen:UnjailPlayer", target_id, jailLoc)

            exports.oxmysql:execute("DELETE FROM jail WHERE identifier = @identifier AND characterid = @characterid", {
                ["@identifier"] = steam_id,
                ["@characterid"] = Character
            })

        else
            VORPcore.NotifyLeft(_source, ConfigMain.Text.Notify.prison, ConfigMain.Text.Notify.noprison, "menu_textures", "cross", 3000, "COLOR_RED")
        end
    end)
end)

RegisterServerEvent('lawmen:GetID')
AddEventHandler('lawmen:GetID', function(player)
    local _source = tonumber(source)

    local User = VORPcore.getUser(player)
    local Target = User.getUsedCharacter

    VORPcore.NotifyLeft(_source, ConfigMain.Text.Notify.idcheck, ConfigMain.Text.Notify.name .. Target.firstname .. ' ' .. Target.lastname .. "             " .. ConfigMain.Text.Notify.jobok .. Target.job, "toasts_mp_generic", "toast_mp_customer_service", 8000, "COLOR_WHITE")
end)

RegisterServerEvent('lawmen:getVehicleInfo')
AddEventHandler('lawmen:getVehicleInfo', function(player, mount)
    local _source = tonumber(source)

    local User = VORPcore.getUser(player)
    local Character = User.getUsedCharacter
    local charID = Character.charIdentifier

    local sqlTable = ConfigMain.SQLTable
    local columns = {}

    if sqlTable == "sirevlc_horses_v3" then
        columns.charid = "CHARID"
        columns.model = "MODEL"
        columns.name = "NAME"
    elseif sqlTable == "sirevlc_horses" then
        columns.charid = "charid"
        columns.model = "model"
        columns.name = "name"    
    elseif sqlTable == "rsd_horses" then
        columns.charid = "charid"
        columns.model = "model"
        columns.name = "name"
    elseif sqlTable == "stables" then
        columns.charid = "charidentifier"
        columns.model = "modelname"
        columns.name = "name"  
    elseif sqlTable == "player_horses" then
        columns.charid = "charid"
        columns.model = "model"
        columns.name = "name"      
    end

    exports.oxmysql:execute("SELECT * FROM `" .. sqlTable .. "` WHERE " .. columns.charid .. "=@identifier",
        { identifier = charID },
        function(result)
            local found = false
            if result[1] then
                for i, v in pairs(result) do
                    local modelHash = GetHashKey(v[columns.model])

                    if modelHash == mount then
                        found = true
                        VORPcore.NotifyLeft(_source,
                            ConfigMain.Text.Notify.idcheck,
                            ConfigMain.Text.Notify.name .. Character.firstname .. ' ' .. Character.lastname .. ConfigMain.Text.Notify.horse .. (v[columns.name]), "toasts_mp_generic", "toast_mp_customer_service", 8000, "COLOR_WHITE")
                        break
                    end
                end
            end

            if not found then
                VORPcore.NotifyLeft(_source, ConfigMain.Text.Notify.idcheck, ConfigMain.Text.Notify.notowned, "toasts_mp_generic", "toast_mp_customer_service", 8000, "COLOR_WHITE")
            end
        end)
end)


RegisterServerEvent('lawmen:handcuff', function(player)
    TriggerClientEvent('lawmen:handcuff', player)
end)

RegisterServerEvent('lawmen:lockpicksv')
AddEventHandler('lawmen:lockpicksv', function(player)
    local _source = source
    local chance = math.random(1, 100)
    if chance < 5 then
        VorpInv.subItem(_source, 'lockpick', 1)
        VORPcore.NotifyLeft(_source, ConfigMain.Text.Notify.lockpick, ConfigMain.Text.Notify.lockpickbroke, "menu_textures", "cross", 3000, "COLOR_RED")
    else
        TriggerClientEvent('lawmen:lockpicked', player)
    end
end)

RegisterServerEvent('lawmen:drag')
AddEventHandler('lawmen:drag', function(target)
    local _source = source
    local user = VORPcore.getUser(_source).getUsedCharacter
    for i, v in pairs(ConfigMain.allowedJobs) do
        if user.job == v then
            TriggerClientEvent('lawmen:drag', target, _source)
        end
    end
end)

RegisterServerEvent("lawmen:check_jail")
AddEventHandler("lawmen:check_jail", function()
    local _source = source
    local User = VORPcore.getUser(_source)
    if not User then return end

    local CharInfo = User.getUsedCharacter
    if not CharInfo then return end

    local steam_id = CharInfo.identifier
    local character_id = CharInfo.charIdentifier

    local query = "SELECT * FROM jail WHERE identifier = @identifier AND characterid = @characterid"
    local params = {
        ["@identifier"] = steam_id,
        ["@characterid"] = character_id
    }

    exports.oxmysql:execute(query, params, function(result)
        if not result or not result[1] then return end

        local jailData = result[1]
        local time = tonumber(jailData.time_s)
        local jailLocation = jailData.jaillocation

        local updateQuery = "UPDATE jail SET time_s = @time WHERE identifier = @identifier AND characterid = @characterid"
        local updateParams = {
            ["@time"] = time,
            ["@identifier"] = steam_id,
            ["@characterid"] = character_id
        }

        exports.oxmysql:execute(updateQuery, updateParams)

        TriggerClientEvent("lawmen:JailPlayer", _source, time, jailLocation)
        TriggerClientEvent("lawmen:wear_prison", _source)
    end)
end)

RegisterNetEvent("lawmen:updatejailtime")
AddEventHandler("lawmen:updatejailtime", function(currentTime)
    local _source = source
    local User = VORPcore.getUser(_source)
    if not User or not User.getUsedCharacter then return end
    local CharInfo = User.getUsedCharacter
    local steam_id = CharInfo.identifier
    local Character = CharInfo.charIdentifier

    currentTime = tonumber(currentTime) or 0

    exports.oxmysql:execute("SELECT * FROM jail WHERE identifier = @identifier AND characterid = @characterid",
        { ["@identifier"] = steam_id, ["@characterid"] = Character }, function(result)
            if result[1] then
                exports.oxmysql:execute("UPDATE jail SET time_s = @time WHERE identifier = @identifier AND characterid = @characterid",
                    { ["@time"] = currentTime, ["@identifier"] = steam_id, ["@characterid"] = Character })
            else
                exports.oxmysql:execute(
                    "INSERT INTO jail (identifier, characterid, time_s) VALUES (@identifier, @characterid, @time)",
                    { ["@identifier"] = steam_id, ["@characterid"] = Character, ["@time"] = currentTime }
                )
            end
        end)
end)

RegisterServerEvent("lawmen:guncabinet")
AddEventHandler("lawmen:guncabinet", function(index)
    local _source = source
    local player = VORPcore.getUser(_source).getUsedCharacter
    local grade = player.jobGrade

    local item = ConfigCabinets.WeaponsandAmmo.Weapons[index]
    if not item then
        return
    end

    local label = item.label
    if grade >= item.allowedGrade then
        VORPcore.NotifyLeft(_source, ConfigMain.Text.Notify.armory, ConfigMain.Text.Notify.collect .. label, "generic_textures", "tick", 4000, "COLOR_GREEN")
        VorpInv.createWeapon(_source, item.weapon, {}, {})
    else
        VORPcore.NotifyLeft(_source, ConfigMain.Text.Notify.grade, ConfigMain.Text.Notify.nograde, "menu_textures", "cross", 4000, "COLOR_RED")
    end
end)

RegisterServerEvent("lawmen:addammo")
AddEventHandler("lawmen:addammo", function(index)
    local _source = source
    local player = VORPcore.getUser(_source).getUsedCharacter
    local grade = player.jobGrade

    local item = ConfigCabinets.WeaponsandAmmo.Ammo[index]
    if item then
        if grade >= item.allowedGrade then
            VorpInv.addItem(_source, item.ammo, 1)
            VORPcore.NotifyLeft(_source, ConfigMain.Text.Notify.armory, ConfigMain.Text.Notify.collect .. item.label, "generic_textures", "tick", 4000, "COLOR_GREEN")
        else
            VORPcore.NotifyLeft(_source, ConfigMain.Text.Notify.grade, ConfigMain.Text.Notify.nograde, "menu_textures", "cross", 4000, "COLOR_RED")
        end
    end
end)

function CheckTable(tbl, val)
    if not tbl then return false end
    for _, v in pairs(tbl) do
        if v == val then return true end
    end
    return false
end

function getTime()
    return os.time(os.date("!*t"))
end

RegisterServerEvent('lawmen:lockpick:break')
AddEventHandler('lawmen:lockpick:break', function()
    local _source = source
    VorpInv.subItem(_source, "lockpick", 1)
    VORPcore.NotifyLeft(_source, ConfigMain.Text.Notify.lockpick, ConfigMain.Text.Notify.lockpickbroke, "menu_textures", "cross", 3000, "COLOR_RED")
end)

VorpInv.RegisterUsableItem("lockpick", function(data)
    VorpInv.CloseInv(data.source)
    TriggerClientEvent("lawmen:lockpick", data.source)
end)

Citizen.CreateThread(function()
    Wait(200)
    VorpInv.RegisterUsableItem("handcuffs", function(data)
        local _source = data.source
        local Character = VORPcore.getUser(_source).getUsedCharacter
        local job = Character.job
        VorpInv.CloseInv(_source)

        if not ConfigMain.jobRequired or hasJob(job) then
            TriggerClientEvent("lawmen:tryHandcuff", _source)
        else
            VORPcore.NotifyLeft(_source, ConfigMain.Text.Notify.handcuff, ConfigMain.Text.Notify.nojob, "menu_textures", "cross", 3000, "COLOR_RED")
        end
    end)
end)

function hasJob(job)
    for _, allowedJob in ipairs(ConfigMain.allowedJobs) do
        if job == allowedJob then
            return true
        end
    end
    return false
end

function CheckTable(table, element)
    for k, v in pairs(table) do
        if v == element then
            return true
        end
    end
    return false
end

RegisterServerEvent('lawmen:PlayerJob')
AddEventHandler('lawmen:PlayerJob', function()
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter
    local CharacterJob = Character.job
    TriggerClientEvent('lawmen:PlayerJob', _source, CharacterJob)
end)

RegisterServerEvent("lawmen:GetPlayerWagonID")
AddEventHandler("lawmen:GetPlayerWagonID", function(player)
    if player ~= nil then
        TriggerClientEvent('lawmen:PlayerInWagon', player)
    end
end)

RegisterServerEvent('syn_search:TakeFromsteal')
AddEventHandler('syn_search:TakeFromsteal', function(obj)
    local _source = source
    TriggerClientEvent('lawmen:GetSearch', _source, obj)
    TriggerClientEvent("vorp_inventory:CloseInv", _source)
end)

RegisterServerEvent('lawmen:TakeFrom')
AddEventHandler('lawmen:TakeFrom', function(obj, steal_source)
    local _steal_source = steal_source
    local _source = source
    local target = VORPcore.getUser(_steal_source).getUsedCharacter
    local targetname = target.firstname .. ' ' .. target.lastname
    local user = VORPcore.getUser(_source).getUsedCharacter
    local username = user.firstname .. ' ' .. user.lastname

    local decode_obj = json.decode(obj)

    if decode_obj.type ~= 'item_weapon' and tonumber(decode_obj.number) > 0 and tonumber(decode_obj.number) <= tonumber(decode_obj.item.count) then
        local canCarry = VorpInv.canCarryItem(_source, decode_obj.item.name, decode_obj.number)
        if canCarry then
            VorpInv.subItem(_steal_source, decode_obj.item.name, decode_obj.number, decode_obj.item.metadata)
            VorpInv.addItem(_source, decode_obj.item.name, decode_obj.number, decode_obj.item.metadata)
            VORPcore.NotifyLeft(_source, ConfigMain.Text.Notify.inventory, ConfigMain.Text.Notify.took .. decode_obj.number .. " " .. decode_obj.item.label, "generic_textures", "tick", 4000, "COLOR_GREEN")
            Wait(100)
            TriggerEvent('lawmen:ReloadInventory', _steal_source, _source)
        end
    elseif decode_obj.type == 'item_weapon' then
        VorpInv.canCarryWeapons(_source, decode_obj.number, function(cb)
            if cb then
                VorpInv.subWeapon(_steal_source, decode_obj.item.id)
                VorpInv.giveWeapon(_source, decode_obj.item.id, 0)
                VORPcore.NotifyLeft(_source, ConfigMain.Text.Notify.inventory, ConfigMain.Text.Notify.took .. decode_obj.item.label .. ConfigMain.Text.Notify.from .. targetname, "generic_textures", "tick", 4000, "COLOR_GREEN")
                Wait(100)
                TriggerEvent('lawmen:ReloadInventory', _steal_source, _source)
            end
        end)
    end
end)

RegisterServerEvent('lawmen:ReloadInventory')
AddEventHandler('lawmen:ReloadInventory', function(steal_source, player_source)
    local _steal_source = steal_source
    local _source
    if not player_source then
        _source = source
    else
        _source = player_source
    end
    local inventory = {}

    TriggerEvent('VORPcore:getUserInventory', tonumber(_steal_source), function(getInventory)
        for _, item in pairs(getInventory) do
            local data_item = {
                count = item.count,
                name = item.name,
                limit = item.limit,
                type = item.type,
                label = item.label,
                metadata = item.metadata,
            }
            table.insert(inventory, data_item)
        end
    end)
    TriggerEvent('VORPcore:getUserWeapons', tonumber(_steal_source), function(getUserWeapons)
        for _, weapon in pairs(getUserWeapons) do
            local data_weapon = {
                count = -1,
                name = weapon.name,
                limit = -1,
                type = 'item_weapon',
                label = '',
                id = weapon.id,
            }
            table.insert(inventory, data_weapon)
        end
    end)

    local data = {
        itemList = inventory,
        action = 'setSecondInventoryItems',
    }
    TriggerClientEvent('vorp_inventory:ReloadstealInventory', _source, json.encode(data))
end)

local playersTakenFood = {}

RegisterServerEvent('legacy_police:CommisaryAddItem', function()
    local _source = source
    local commisary = ConfigJail.Jails.sisika.Commisary

    if playersTakenFood[_source] then
        VORPcore.NotifyLeft(_source, ConfigMain.Text.Notify.canteen, ConfigMain.Text.Notify.succes, "menu_textures", "cross", 3000, "COLOR_RED")
        return
    end

    for _, item in ipairs(commisary.Items) do
        VorpInv.addItem(_source, item.name, item.amount)
    end

    playersTakenFood[_source] = true

    local msg = ConfigMain.Text.Notify.collect1
    for i, item in ipairs(commisary.Items) do
        msg = msg .. item.amount .. "x " .. item.label
        if i < #commisary.Items then
            msg = msg .. ", "
        end
    end

    TriggerClientEvent('vorp:NotifyLeft', _source, ConfigMain.Text.Notify.canteen, msg, "generic_textures", "tick", 4000, "COLOR_GREEN")
end)

RegisterServerEvent("legacy_police:PlayerReleased")
AddEventHandler("legacy_police:PlayerReleased", function()
    local _source = source
    playersTakenFood[_source] = nil
end)

AddEventHandler("playerDropped", function()
    local _source = source
    playersTakenFood[_source] = nil
end)

local function HasAllowedJob(job)
    for _, allowedJob in ipairs(ConfigMain.allowedJobs) do
        if job == allowedJob then
            return true
        end
    end
    return false
end

RegisterServerEvent("lawmen:CheckJob")
AddEventHandler("lawmen:CheckJob", function()
    local _source = source
    local player = VORPcore.getUser(_source).getUsedCharacter
    local job = player.job

    if ConfigMain.jobRequired and not HasAllowedJob(job) then
        TriggerClientEvent("lawmen:JobDenied", _source)
    else
        TriggerClientEvent("lawmen:JobAccepted", _source)
    end
end)

RegisterServerEvent("lawmen:checkcabinetjob")
AddEventHandler("lawmen:checkcabinetjob", function()
    local _source = source
    local player = VORPcore.getUser(_source).getUsedCharacter
    local job = player.job

    if ConfigMain.jobRequired and not HasAllowedJob(job) then
        TriggerClientEvent("lawmen:JobCabinetDenied", _source)
    else
        TriggerClientEvent("lawmen:JobCabinetAccepted", _source)
    end
end)

RegisterServerEvent("lawmen:RequestSpawnWagon")
AddEventHandler("lawmen:RequestSpawnWagon", function(wagonModel, coords)
    local _source = source
    local player = VORPcore.getUser(_source).getUsedCharacter
    local job = player.job
    local grade = player.jobGrade

    local requiredGrade = nil
    for _, data in ipairs(ConfigMain.Wagons) do
        if data.wagon == wagonModel then
            requiredGrade = data.allowedGrade
            break
        end
    end

    if requiredGrade and grade < requiredGrade then
        VORPcore.NotifyLeft(_source, ConfigMain.Text.Notify.wagon, ConfigMain.Text.Notify.nograde, "menu_textures", "cross", 3000, "COLOR_RED")
        return
    end

    TriggerClientEvent("lawmen:spawnWagon", _source, wagonModel, coords)
    VORPcore.NotifyLeft(_source, ConfigMain.Text.Notify.wagon, ConfigMain.Text.Notify.wagonok, "generic_textures", "tick", 4000, "COLOR_GREEN")
end)


RegisterServerEvent("lawmen:DeleteWagonServer")
AddEventHandler("lawmen:DeleteWagonServer", function(wagonNetId)
    TriggerClientEvent("lawmen:DeleteWagonGlobal", -1, wagonNetId)
end)

RegisterCommand(ConfigMain.delwagoncommand, function(source)
    local _source = source
    TriggerClientEvent("lawmen:deleteWagon", _source)
end, false)

local Inv = exports.vorp_inventory

local function registerStorage(prefix, name, limit)
    local isInvRegstered <const> = Inv:isCustomInventoryRegistered(prefix)
    if not isInvRegstered then
        local data <const> = {
            id = prefix,
            name = name,
            limit = limit,
            acceptWeapons = true,
            shared = true,
            ignoreItemStackLimit = true,
            whitelistItems = false,
            UsePermissions = false,
            UseBlackList = false,
            whitelistWeapons = false,

        }
        Inv:registerInventory(data)
    end
end

RegisterNetEvent("lawmen:Server:OpenStorage", function(key)
    local _source <const> = source
    local user <const> = VORPcore.getUser(_source)
    if not user then return end

    local prefix = "police_storage_" .. key
    local storageData = ConfigMain.Storage[key]
    if not storageData then return end

    local storageName <const> = storageData.Name
    local storageLimit <const> = storageData.Limit

    registerStorage(prefix, storageName, storageLimit)
    Inv:openInventory(_source, prefix)
end)

RegisterServerEvent("lawmen:checkstoragejob")
AddEventHandler("lawmen:checkstoragejob", function(key)
    local _source = source
    if not key then return end

    local player = VORPcore.getUser(_source)
    if not player then return end

    local character = player.getUsedCharacter
    local job = character.job
    local grade = character.jobGrade

    local storageData = ConfigMain.Storage[key]
    if not storageData then return end

    local requiredGrade = storageData.MinGrade

    if requiredGrade == false then
        if HasAllowedJob(job) then
            TriggerClientEvent("lawmen:JobStorageAccepted", _source, key)
        else
            TriggerClientEvent("lawmen:JobStorageDenied", _source, key)
        end
        return
    end

    if HasAllowedJob(job) and tonumber(grade) and tonumber(requiredGrade) and tonumber(grade) >= tonumber(requiredGrade) then
        TriggerClientEvent("lawmen:JobStorageAccepted", _source, key)
    else
        TriggerClientEvent("lawmen:JobStorageDenied", _source, key)
    end
end)

RegisterServerEvent("CheckPoliceMenuPermission")
AddEventHandler("CheckPoliceMenuPermission", function()
    local _source = source
    local User = VORPcore.getUser(_source)
    if not User then return end

    local character = User.getUsedCharacter
    if not character then return end

    local characterJob = character.job
    local characterGroup = character.group

    if characterGroup == "admin" then
        TriggerClientEvent("OpenPoliceMenuClient", _source)
        return
    end

    if ConfigMain.jobRequired and not HasAllowedJob(characterJob) then
        VORPcore.NotifyLeft(_source, ConfigMain.Text.Notify.job, ConfigMain.Text.Notify.notjoborservice, "menu_textures", "cross", 3000, "COLOR_RED")
        return
    end
    
    TriggerClientEvent("OpenPoliceMenuClient", _source)
end)


AddEventHandler("onResourceStart", function(resource)
    if resource ~= GetCurrentResourceName() then return end

    for key, value in pairs(ConfigMain.Storage) do
        local prefix = "police_storage_" .. key
        registerStorage(prefix, value.Name, value.Limit)
    end
end)