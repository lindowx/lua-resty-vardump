package = "lua-resty-vardump"
version = "1.0.1-1"
source = {
	url = "https://github.com/lindowx/lua-resty-vardump/archive/v1.0.1.tar.gz"
}
description = {
	summary = "A debug tool for the Openresty/ngx_lua",
	detailed = [[
		Vardump is a debug tool for the Openresty/ngx_lua that pretty-prints some Lua values.
	]],
	homepage = "https://github.com/lindowx/lua-resty-vardump",
	maintainer = "lindowx",
	license = "MIT"
}
dependencies = {
	"lua >= 5.1"
}
build = {
	type = 'builtin',
	modules = {
		['resty.vardump'] = 'lib/resty/vardump.lua'
	}
}