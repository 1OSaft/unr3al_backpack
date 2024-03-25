fx_version 'cerulean'
game 'gta5'
lua54 'yes'

description 'Unr3al Backpack for Ox Inventory'
version '1.1.1'

client_scripts {
    'client/**.lua'
}

server_scripts {
  'server/**.lua',
  '@oxmysql/lib/MySQL.lua'
}

shared_scripts {
  '@es_extended/imports.lua',
  '@ox_lib/init.lua',
  'config.lua'
}

dependencies {
  'ox_inventory',
  'ox_lib',
  'oxmysql'
}
