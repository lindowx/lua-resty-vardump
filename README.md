Name
====

lua-resty-vardump - A debug tool for the Openresty/ngx_lua

Table of Contents
=================

- [Name](#name)
- [Table of Contents](#table-of-contents)
- [Description](#description)
- [Synopsis](#synopsis)
- [Methods](#methods)
  - [dump](#dump)
  - [dd](#dd)
  - [depth](#depth)
- [Attributes](#attributes)
  - [html](#html)
  - [send_content_type_header](#send_content_type_header)
- [Installation](#installation)

Description
===========

Vardump is a debug tool for the Openresty/ngx_lua that pretty-prints some Lua values.

Synopsis
========

```lua
local vardump = require 'resty.vardump'

local my_t = {
  a = 1,
  b = "str",
  c = function ()
    return 3
  end,
  d = ngx.null,
  e = ngx.var,
  f = nil,
  g = vardump,
  h = false,
  i = tostring
}

local my_num_var = 12345
local my_str_var = "hello, world"
local my_arr_var = {"a", "b"} 

vardump.dump(my_t, my_num_var, my_str_var, my_arr_var)

vardump.depth(1).dd(my_t)

ngx.print('This line will not be executed')
```

Output:

![Screenshot](https://raw.githubusercontent.com/lindowx/lua-resty-vardump/master/screenshots/screenshot1.png)

Methods
=======


dump
---
`syntax: vardump.dump(...)`

Pretty print given values.

dd
-------
`syntax: vardump.dd(...)`

Pretty print given values then stop the code execution.

depth
-------
`syntax: vardump.depth(max_depth)`

Set the max traversal depth when dumping your Lua values.

The default value of max depth is 15.

Attributes
=======

html
---
`syntax: vardump.html = false`

>`default: true`

Set the print mode.

**true**: Print in HTML format.

**false**: Print in plain text format.

send_content_type_header
---
`syntax: vardump.send_content_type_header = fase`

>`default: true`

**true**: Send the HTTP response header `Content-Type: text/html` before output the dumps.

**false**: Will not send the header.


Installation
============

Luarocks:
```bash
luarocks install lua-resty-vardump
```

Manually:

Download the package from the releases page, then extract the `lib/resty` directory to the the Lua library directory.

```nginx
    # nginx.conf
    http {
        lua_package_path "/path/to/lua-lib-dir/?.lua;;";
        ...
    }
```

Ensure that the system account running your Nginx ''worker'' proceses have
enough permission to read the `.lua` file.
