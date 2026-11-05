use_experimental_fxv2_oal 'yes'
fx_version 'cerulean'
games { 'rdr3', 'gta5' }
lua54 'yes'

rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

name 'bs-lib'
author 'bluenzzz'
description 'A library of shared functions to be used in my scripts.'
version '2.0.0'
license 'Blue Studio'
repository 'https://github.com/bluenzzz/bs-lib'

ui_page 'web/dist/index.html'

dependencies {
    '/onesync'
}

shared_scripts {
    'shared/utils.lua',
    'core/init.lua',
    'core/callback/shared.lua',
    'core/locale/shared.lua'
}

client_scripts {
    'core/cache/client.lua',
    'core/interface/client.lua',
    'core/ped/client.lua',
    'core/hoverfy/client.lua'
}

server_scripts {
    'core/version/server.lua'
}

files {
    'init.lua',
    'imports/**/*.lua',
    'web/dist/**/*'
}
