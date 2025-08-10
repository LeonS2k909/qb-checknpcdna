fx_version 'cerulean'
game 'gta5'

name 'qb-checknpcdna'
description 'Police can check DNA on dead NPCs and identify the killer if it was a player'
author 'Leon'
version '1.0.0'

lua54 'yes'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'config.lua',
}

client_scripts {
    'client.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua', -- safe to leave; not required
    '@qb-core/server/player.lua',
    'server.lua',
}

dependencies {
    'qb-core',
    'qb-target'
}
