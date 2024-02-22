local blips = {}

local function openLockerMenu(data)
    local owned = lib.callback.await('ts_locker:server:checkOwned', false, data.locker_id)
    local identifier = lib.callback.await('ts_locker:server:getUserIdentifier', false)
    if not owned then
        lib.notify({
            title = locale("ts_locker:title"),
            description = locale("ts_locker:notify:notowned"),
            type = 'error'
        })

        local input = lib.inputDialog(locale("ts_locker:input:rentStorage"):format(data.locker_id), {
            { type = 'number', label = locale("ts_locker:input:rentStorage:input1"), default = data.price, disabled = true },
            { type = 'number', label = locale("ts_locker:input:rentStorage:input2"), required = true,      min = 1 },
        })

        if not input then return end
        local price = data.price * input[2]
        local alert = lib.alertDialog({
            header = locale("ts_locker:title"),
            content = locale("ts_locker:dialog:confirm"):format(price, input[2]),
            centered = true,
            cancel = true
        })

        if alert == 'confirm' then
            lib.callback('ts_locker:server:rentLocker', false, function(cb)
                    if (cb == TS.STATUS.SUCCESS) then
                        lib.notify({
                            title = locale("ts_locker:title"),
                            description = locale("ts_locker:notify:successRent"):format(price),
                            type = 'success'
                        })
                        exports.ox_inventory:openInventory('stash', data.locker_id .. '.' .. identifier)
                    elseif cb == TS.STATUS.NOTENOUGHMONEY then
                        lib.notify({
                            title = locale("ts_locker:title"),
                            description = locale("ts_locker:notify:noMoney"),
                            type = 'error'
                        })
                    elseif cb == TS.STATUS.FAILED_SQL then
                        lib.notify({
                            title = locale("ts_locker:title"),
                            description = locale("ts_locker:notify:failedSQL"),
                            type = 'error'
                        })
                    end
                end,
                {
                    time = input[2],
                    locker_id = data.locker_id,
                    slot = data.slot,
                    maxWeight = data.maxWeight,
                    price =
                        price
                })
        end
    else
        exports.ox_inventory:openInventory('stash', data.locker_id .. '.' .. identifier)
    end
end

local function refreshLockers()
    print(json.encode(TS.Lockers))
    local blip
    for k, v in pairs(TS.Lockers) do
        exports.ox_target:addBoxZone({
            name = k:gsub(' ', '_'),
            coords = v.coords,
            options = {
                {
                    icon = 'fas fa-warehouse',
                    label = "Open Stash",
                    onSelect = function()
                        openLockerMenu({
                            locker_id = k,
                            price = v.price,
                            slot = v.slot,
                            maxWeight = v.maxWeight
                        })
                    end
                }
            }
        })
        if v.blips then
            blip = AddBlipForCoord(v.coords.x, v.coords.y, v.coords.z)
            SetBlipSprite(blip, TS.BlipsIcon)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, 0.8)
            SetBlipAsShortRange(blip, true)
            SetBlipColour(blip, 9)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(k)
            EndTextCommandSetBlipName(blip)

            blips[#blips + 1] = {
                blip = blip
            }
        end
    end
end

AddEventHandler('onResourceStart', function(resource)
    if resource ~= cache.resource then return end
    refreshLockers()
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    refreshLockers()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    if not blips then return end
    for i = 1, #blips do
        local blip = blips[i].blip
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end
    blips = {}
end)

AddEventHandler('onResourceStop', function(resource)
    if not blips then return end
    for i = 1, #blips do
        local blip = blips[i].blip
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end
    blips = {}
end)

AddStateBagChangeHandler('ts_locker_save_locker', 'global', function(bagname, key, value)
    if value then
        for k, _ in pairs(TS.Lockers) do
            exports.ox_target:removeZone(k:gsub(' ', '_'))
        end
        TS.Lockers = value
        refreshLockers()
    end
end)
