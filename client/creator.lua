RegisterNetEvent('ts_locker:client:createlocker', function()
    local newData = {}
    local pos = GetEntityCoords(cache.ped)
    local input = lib.inputDialog(locale("ts_locker:title"), {
        { type = 'input',    label = 'Name',       placeholder = 'TS LOCKER', required = true },
        { type = 'number',   label = 'Price',      placeholder = '10',        min = 0,        required = true },
        { type = 'number',   label = 'Slot',       placeholder = '10',        min = 0,        required = true },
        { type = 'number',   label = 'Max Weight', placeholder = '10',        min = 0,        required = true },
        { type = 'checkbox', label = 'Blips',      default = true }
    })

    if not input then return end

    newData[input[1]] = {
        coords = pos,
        price = input[2],
        slot = input[3],
        maxWeight = input[4],
        blips = input[5] or false
    }
    TriggerServerEvent('ts_locker:server:saveNewData', newData)
end)

local function menuAction(id, coords)
    lib.registerContext({
        id = 'ts_locker:menuAction',
        title = locale("ts_locker:title"),
        options = {
            {
                title = 'Remove',
                onSelect = function(args)
                    TriggerServerEvent('ts_locker:server:removeLockers', id)
                end
            },
            {
                title = 'Goto',
                onSelect = function()
                    SetEntityCoords(cache.ped, coords.x, coords.y, coords.z)
                end
            },
        },
    })
    lib.showContext('ts_locker:menuAction')
end

RegisterNetEvent('ts_locker:client:lockerList', function()
    local menuList = {}
    for k, v in pairs(TS.Lockers) do
        menuList[#menuList + 1] = {
            title = k,
            metadata = {
                { label = 'Coords',              value = v.coords },
                { label = 'Price',               value = v.price },
                { label = 'Slot',                value = v.slot },
                { label = 'Max Weight',          value = v.maxWeight },
                { label = 'Total rented player', value = lib.callback.await('ts_locker:server:fetchTotalUserLocker', false, k) or 0 }
            },
            onSelect = function()
                menuAction(k, v.coords)
            end
        }
    end

    lib.registerContext({
        id = 'ts_locker:lockerList',
        title = locale("ts_locker:title"),
        options = menuList
    })

    lib.showContext('ts_locker:lockerList')
end)
