lib.addCommand('createlocker', {
    help = locale("ts_locker:createlocker:cmd:help"),
    restricted = 'admin'
}, function(src, args, raw)
    TriggerClientEvent('ts_locker:client:createlocker', src)
end)

RegisterNetEvent('ts_locker:server:saveNewData', function(data)
    local mergedData = {}
    local Model = [[
        ['%s'] = {
            coords = %s,
            price = %s,
            slot = %s,
            maxWeight = %s,
            blips = %s
        },
    ]]

    for k, v in pairs(TS.Lockers) do
        mergedData[k] = {
            coords = v.coords,
            price = v.price,
            slot = v.slot,
            maxWeight = v.maxWeight,
            blips = v.blips
        }
    end
    for k, v in pairs(data) do
        mergedData[k] = {
            coords = v.coords,
            price = v.price,
            slot = v.slot,
            maxWeight = v.maxWeight,
            blips = v.blips
        }
    end

    local sdata = {}

    for k, v in pairs(mergedData) do
        sdata[#sdata + 1] = Model:format(
            k,
            v.coords,
            v.price,
            v.slot,
            v.maxWeight,
            v.blips
        )
    end

    local serialized = ('return { \n%s }'):format(table.concat(sdata, '\n'))
    SaveResourceFile(cache.resource, 'data/locker.lua', serialized, -1)

    GlobalState.ts_locker_save_locker = mergedData
    TS.Lockers = mergedData
end)

lib.addCommand('lockerlist', {
    help = locale("ts_locker:lockerlist:cmd:help"),
    restricted = 'admin'
}, function(src, args, raw)
    TriggerClientEvent('ts_locker:client:lockerList', src)
end)

lib.callback.register('ts_locker:server:fetchTotalUserLocker', function(source, locker_id)
    local response = MySQL.query.await(
        'SELECT `locker_id` FROM `ts_lockers` WHERE `locker_id` = ?',
        {
            locker_id
        })

    return #response
end)

RegisterNetEvent('ts_locker:server:removeLockers', function(id)
    TS.Lockers[id] = nil
    local Model = [[
        ['%s'] = {
            coords = %s,
            price = %s,
            slot = %s,
            maxWeight = %s,
            blips = %s
        },
    ]]
    local sdata = {}

    for k, v in pairs(TS.Lockers) do
        sdata[#sdata + 1] = Model:format(
            k,
            v.coords,
            v.price,
            v.slot,
            v.maxWeight,
            v.blips
        )
    end

    local serialized = ('return { \n%s }'):format(table.concat(sdata, '\n'))
    SaveResourceFile(cache.resource, 'data/locker.lua', serialized, -1)
    print(json.encode(TS.Lockers))
    GlobalState.ts_locker_save_locker = TS.Lockers
end)
