fx_version 'bodacious'
game 'gta5'
lua54 'yes'

author 'bluenzzz'
description 'BLUEN LIB'
version '1.0.2'

ui_page_preload 'yes'
ui_page 'web/index.html'

shared_script {
    'lib/*',
    'modules/shared/*'
}

client_script 'modules/client/**/**/*'
server_script 'modules/server/**/*'

files { 'web/*' }