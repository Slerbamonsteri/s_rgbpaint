fx_version 'adamant'

games { 'gta5' }

description 's_rgbPaint'


client_scripts {
    'cl.lua',
}

server_script {
     'sv.lua',
     --'@mysql-async/lib/MySQL.lua', --Works with OX too, just dont uncomment this if you dont use ESX
}