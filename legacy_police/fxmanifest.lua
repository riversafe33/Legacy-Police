game 'rdr3'
fx_version 'adamant'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

ui_page 'html/index.html'

files {
    'html/index.html'
}

client_scripts {
    'config/ConfigMain.lua',
    'config/ConfigJail.lua',
    'config/ConfigCabinets.lua',
    'client/client.lua',
    'client/functions.lua',
    'client/menu.lua'
}

server_scripts {
    'config/ConfigMain.lua',
    'config/ConfigJail.lua',
    'config/ConfigCabinets.lua',
    'server/server.lua'
}
