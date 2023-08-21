Config = {}

Config.Inventory = "ox_inventory" -- "ox_inventory", "qb-inventory"

Config.Target = "ox_target"       -- "ox_target", "qb-target

Config.Price = 10

Config.Slot = 200

Config.Weight = 2500000

Config.GudangStash = {
    [1] = {
        id = 'utama', -- Harus Uniqe
        label = 'Gudang Utama',
        coords = vector3(-19.16, -1439.2, 31.1)
    },
    [2] = {
        id = 'pantai',
        label = 'Gudang Pantai',
        coords = vector3(-1607.623, -830.954, 10.078)
    }
}