fx_version 'cerulean'
game 'gta5'
author 'Tasius Kenways'
description 'Gudang Storage'
version '1.0.0'

client_scripts {
    '@PolyZone/client.lua',
    'client/*.lua'
}

server_scripts {
    'server/*.lua',
    '@oxmysql/lib/MySQL.lua',
}

shared_scripts {
    'config.lua',
    '@qb-core/shared/locale.lua',
    '@ox_lib/init.lua', -- OX_Lib, only line this in if you have ox_lib and are using them.
}

lua54 'yes'

dependencies { -- Make sure these are started before cdn-fuel in your server.cfg!
    'ox_lib'
}