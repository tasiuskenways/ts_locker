local QBCore = exports['qb-core']:GetCoreObject()

function CreateTargetAndBlips()
    for k, v in pairs(Config.GudangStash) do
        local Gudang = AddBlipForCoord(v.coords.x, v.coords.y, v.coords.z)
        SetBlipSprite(Gudang, 473)
        SetBlipDisplay(Gudang, 4)
        SetBlipScale(Gudang, 0.7)
        SetBlipAsShortRange(Gudang, true)
        SetBlipColour(Gudang, 67)
        AddTextEntry(v.label, v.label)
        BeginTextCommandSetBlipName(v.label)
        EndTextCommandSetBlipName(Gudang)

        if Config.Target == "qb-target" then
            exports['qb-target']:AddBoxZone("gudang" .. v.id, v.coords, 1.5, 1, {
                name = "gudang" .. v.id,
                debugPoly = false,
                heading = -20,
                minZ = v.coords.z - 1.5,
                maxZ = v.coords.z + 1.5,
            }, {
                options = {
                    {
                        type = "client",
                        icon = "fa fa-warehouse",
                        label = "Open Stash",
                        action = function()
                            TriggerEvent('gudang:client:openMainMenu', v.id)
                        end,
                    }
                },
                distance = 2.5
            })
        elseif Config.Target == "ox_target" then
            exports.ox_target:addBoxZone({
                coords = v.coords,
                size = vec3(1.2, 1.6, 1),
                rotation = -20,
                options = {
                    {
                        icon = 'fas fa-warehouse',
                        label = "Open Stash",
                        distance = 2.5,
                        onSelect = function()
                            TriggerEvent('gudang:client:openMainMenu', v.id)
                        end
                    }
                }
            })
        end
    end
end

RegisterNetEvent('gudang:client:openMainMenu')
AddEventHandler('gudang:client:openMainMenu', function(id)
    lib.registerContext({
        id = 'gudang_mainMenu',
        title = 'Storage Menu Options',
        options = {
            {
                title = 'Buy Storage',
                description = 'Buy Storage If U Have Money And U Dont Have Storage Here',
                icon = 'warehouse',
                onSelect = function()
                    TriggerEvent('gudang:client:buyStorage', id)
                end,
            },
            {
                title = 'Open Stash',
                description = 'Open Stash If U Have Stash Here',
                icon = 'warehouse',
                onSelect = function()
                    TriggerEvent('gudang:client:openStorage', id)
                end,
            },
            {
                title = "Close Menu",
                icon = "fas fa-times-circle",
                onSelect = function()
                    lib.hideContext()
                end,
            },
        }
    })

    lib.registerContext({
        id = 'buy_storage_menu',
        title = 'Storage Menu Options',
        options = {
            {
                title = 'Open Stash',
                description = 'Open Stash If U Have Stash Here',
                icon = 'warehouse',
                event = 'test_event',
            }
        }
    })

    lib.showContext('gudang_mainMenu')
end)

RegisterNetEvent('gudang:client:buyStorage')
AddEventHandler('gudang:client:buyStorage', function(id)
    local input = lib.inputDialog('Warehouse Rental', {
        { type = 'input',  label = 'Warehouse Name',  default = 'Locker ' .. id,                         disabled = true },
        { type = 'input',  label = 'Warehouse Price', default = '$ ' .. Config.Price .. ' Per Day',      disabled = true },
        { type = 'number', label = 'Day',             description = 'How Many Days to Rent a Warehouse', default = 1,
                                                                                                                             min = 1,
                                                                                                                                      required = true },
    })

    local day = tonumber(input[3])
    local price = Config.Price * day

    if day ~= nil then
        local input = lib.inputDialog('Are You Sure You Want to Rent a Warehouse?', {
            { type = 'input', label = 'Total Price', default = '$ ' .. price, disabled = true },
        })
    end
    TriggerServerEvent('gudang:server:buyStorage', day, price, id)
end)

RegisterNetEvent('gudang:client:openStorage')
AddEventHandler('gudang:client:openStorage', function(id)
    QBCore.Functions.TriggerCallback('gudang:server:GetWareHouse', function(ada, identifier)
        if ada then
            local cid = QBCore.Functions.GetPlayerData().citizenid
            if Config.Inventory == "qb-inventory" then
                TriggerEvent("inventory:client:SetCurrentStash", "Lockers" .. id .. cid)
                TriggerServerEvent("inventory:server:OpenInventory", "stash", "Lockers" .. id .. cid, {
                    maxweight = Config.Weight,
                    slots = Config.Slot,
                })
            elseif Config.Inventory == "ox_inventory" then
                exports.ox_inventory:openInventory('stash', { id = "locker_" .. id .. cid, owner = identifier })
            end
        else
            QBCore.Functions.Notify('You Dont Have Locker Here', 'error', 7500)
        end
    end, id)
end)


AddEventHandler('onResourceStart', function(resource)
    CreateTargetAndBlips()
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    CreateTargetAndBlips()
end)
