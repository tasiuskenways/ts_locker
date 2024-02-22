lib.versionCheck('tasiuskenways/ts_locker')
lib.callback.register('ts_locker:server:checkOwned', function(source, locker_id)
    local affectedRows = MySQL.update.await('DELETE FROM ts_lockers WHERE expired_date < NOW() AND user = ?', {
        GetPlayerIdentifierByType(source, 'steam')
    })

    local response = MySQL.query.await(
        'SELECT `user`, `locker_id` FROM `ts_lockers` WHERE `user` = ? AND `locker_id` = ?',
        {
            GetPlayerIdentifierByType(source, 'steam'),
            locker_id
        })
    if #response > 0 and affectedRows == 0 then
        return true
    else
        return false
    end
end)

local function getEndTime(time)
    local s1 = os.time()
    local x1 = os.date('*t', s1)

    x1.day = x1.day + time
    x1.isdst = nil -- this prevents DST time changes

    local s2 = os.time(x1)
    return os.date("%Y/%m/%d %X", s2)
end

local function getPlayerMoney(src)
    if TS.Framwork == 'qbx' then
        local player = exports.qbx_core:GetPlayer(src)
        return player.PlayerData.money['bank']
    elseif TS.Framework == 'qb' then
        local QBCore = exports['qb-core']:GetCoreObject()
        local player = QBCore.Functions.GetPlayer(src)
        return player.PlayerData.money.bank
    elseif TS.Framework == 'esx' then
        local ESX = exports["es_extended"]:getSharedObject()
        local xPlayer = ESX.GetPlayerFromId(src)
        return xPlayer.getMoney()
    end
end

lib.callback.register('ts_locker:server:rentLocker', function(source, data)
    local endTime = getEndTime(data.time)
    local identifier = GetPlayerIdentifierByType(source, 'steam')
    exports.ox_inventory:RegisterStash(data.locker_id .. '.' .. identifier, data.locker_id, data.slot, data.maxWeight)
    local playerMoney = getPlayerMoney(source)
    if playerMoney < data.price then
        return TS.STATUS.NO_MONEY
    end
    local id = MySQL.insert.await('INSERT INTO `ts_lockers` (user, locker_id, expired_date) VALUES (?, ?, ?)', {
        identifier, data.locker_id, endTime
    })
    if not id then
        return TS.STATUS.FAILED_SQL
    else
        if TS.Framwork == 'qbx' then
            local player = exports.qbx_core:GetPlayer(source)
            player.Functions.RemoveMoney('bank', data.price)
        elseif TS.Framework == 'qb' then
            local QBCore = exports['qb-core']:GetCoreObject()
            local player = QBCore.Functions.GetPlayer(source)
            player.Functions.RemoveMoney('bank', data.price)
        elseif TS.Framework == 'esx' then
            local ESX = exports["es_extended"]:getSharedObject()
            local xPlayer = ESX.GetPlayerFromId(source)
            xPlayer.removeMoney(data.price)
        end
        return TS.STATUS.SUCCESS
    end
end)

lib.callback.register('ts_locker:server:getUserIdentifier', function(source)
    return GetPlayerIdentifierByType(source, 'steam')
end)
