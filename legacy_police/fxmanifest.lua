game 'rdr3'
fx_version 'adamant'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

ui_page 'html/index.html'

files {
    'html/index.html'
}

client_script {
    'client/client.lua',
    'client/functions.lua',
    'client/menu.lua'

}

server_script {
    'server/server.lua'
}

shared_script {
    'config/ConfigMain.lua',
    'config/ConfigJail.lua',
    'config/ConfigCabinets.lua',
}