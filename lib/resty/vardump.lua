-- Copyright (C) Zhiqiang Lan (lindowx)

local ngx = ngx
local str_replace = string.gsub
local str_repeat = string.rep
local sprintf = string.format
local type = type
local pairs = pairs
local next = next
local tostring = tostring
local pcall = pcall

module(...)

_VERSION = '1.0.2'

send_content_type_header = true
html = true
local inited = false
local max_depth = 15

local D_INDENT = '    '
local D_INDENT_HTML = '<span class="lrvd-idt"></span>'

local function minify(str)
    return str_replace(str, "%s", "")
end

local html_css = '<style type="text/css">' .. minify([[
.lrvd-idt {
    display:inline-block;
    width:2em;
}
.lrvd-t-str {
    color:black;
}
.lrvd-v-str {
    color:green;
}
.lrvd-v-num {
    color:red;
}
.lrvd-t-table{
    font-weight:bold;
}
.lrvd-ts {
    color:#009;
    font-weight:bold;
}
.lrvd-t-nil {
    color:#aaa;
    font-style:italic;
}
.lrvd-t-g-data {
    color:#999;
    font-style:italic;
}]]) .. [[
</style>
]]


local function output(str, nl)
	if nl then
		if html then
			str = str .. '<br>'
		else
			str = str .. "\n"
		end
	end
	ngx.print(str)
end


local function init()
	if not inited then
		if send_content_type_header then
			ngx.header["Content-Type"] = "text/html"
		end
        if html then
            output(html_css)
        end
    end
    inited = true
end


local function indent(n)
    local indent_str
	if html then
        indent_str = D_INDENT_HTML
    else
        indent_str = D_INDENT
	end
	return str_repeat(indent_str, n)
end


local function dsprint(str, css_class)
	if html then
        str = sprintf('<span class="%s">%s</span>', css_class, str)
	end
	return str
end


local function t_table(tbl)
	local t_name = 'table'
	if tbl._NAME then
		t_name = tbl._NAME
		if tbl._VERSION then
			t_name = t_name .. '@' .. tbl._VERSION
		end
	end
	return t_name
end


function depth(d)
	max_depth = d
	return _M
end


local function print_table(t, i)
	init()

	i = i or 0
	if i > max_depth then
		return
	end

	for k, v in pairs(t) do
		local v_type = type(v)
		local k_type = type(k)

		if k_type == "string" then
			output(indent(i) .. "[" .. dsprint('"' .. k .. '"', "lrvd-v-str") .. "] => ")
		else
			output(indent(i) .. "[" .. dsprint(k, "lrvd-v-num") .. "] => ")
		end

		if k == "_G" then
			output(dsprint("Global Data {...}", "lrvd-t-g-data"), true)

		elseif k == "_M" then
			output(dsprint("Module Self {...}", "lrvd-t-g-data"), true)

		elseif v == ngx.var then
			dump(v)
		elseif v_type == "table" then
			local nl = false
			local t_indent = ''
			if next(v) ~= nil then
				nl = true
				t_indent = indent(i)
			end
			output(dsprint(t_table(v), "lrvd-t-table") .. dsprint(" {", "lrvd-ts"), nl)
			if not nl then
				output(dsprint(" Empty ", "lrvd-t-g-data"))
			end
			print_table(v, i + 1)
			output(t_indent .. dsprint("}", "lrvd-ts"), true)
		else
			dump(v)
		end
	end

end


function dump(...)
    init()

	local argv = {...}
	local argc = #argv
    local idx = 1

	if argc == 0 then
		output(dsprint("nil", "lrvd-t-nil"), true)
	end

	for _, var in pairs(argv) do
		local var_type = type(var)

		if var == nil then
			output(dsprint("nil", "lrvd-t-nil"), true)

		elseif var == ngx.null then
			output(dsprint("ngx.null", "lrvd-t-nil"), true)

		elseif var == ngx.var then
			output(dsprint("ngx.var{...}", "lrvd-t-nil"), true)

		elseif var_type == "string" then
			output( dsprint(var_type, "lrvd-t-str") .. "(" .. dsprint(#var, "lrvd-v-num") .. ")" .. dsprint('"' .. var .. '"', "lrvd-v-str"), true)
	
		elseif var_type == "table" then
			output(dsprint(t_table(var), "lrvd-t-table") .. dsprint("  {", "lrvd-ts"), true)
			print_table(var, 1)
			output(dsprint("}", "lrvd-ts"), true)

		else
			local ok, v_str = pcall(function ()
				return tostring(var)
			end)
			if v_str then
				output(dsprint(v_str, "lrvd-v-num"), true)

			elseif var_type == "userdata" then
				output(dsprint("userdata [...]", "lrvd-t-str"), true)

			else
				output(dsprint("Not Dumpable", "lrvd-t-g-data"), true)
			end
		end
	end
end


function dd(...)
	dump(...)
	ngx.exit(ngx.HTTP_OK)
end


