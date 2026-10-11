fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'dps-autoshops'
description 'DelPerroSands automatic repair shops: full self-service repair when no mechanic is on duty, a simple repair plus a pointer to the open shops when one is'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'shared/price.lua',
}

client_script 'client/main.lua'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
}

dependencies {
    'ox_lib',
    'oxmysql',
    'qbx_core',
}
