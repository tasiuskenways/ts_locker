fx_version 'cerulean'
game 'gta5'
author 'Tasius'

version '2.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/*.lua',
    '@qbx_core/modules/playerdata.lua'
}

server_scripts {
    'server/*.lua',
    '@oxmysql/lib/MySQL.lua'
}

files {
    'data/*.lua',
    'locales/*.json'
}
ox_lib "locale"

dependencies {
    'ox_lib',
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'
