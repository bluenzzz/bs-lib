fx_version 'cerulean'
game 'gta5'
lua54 'yes'
use_experimental_fxv2_oal 'yes'

author 'bluenzzz'
description 'BLUEN LIB'
version '1.0.0'

client_script 'modules/client/**/**/*'
server_script 'modules/server/**/*'
shared_scripts { 'modules/shared/shared.lua', 'modules/shared/**/*' }

files { 'modules/shared/**/*' }