package = "lua-resty-expr"
version = "1.3.0-0"
source = {
    url = "git://github.com/api7/lua-resty-expr",
    tag = "v1.3.0"
}

description = {
    summary = "A tiny DSL to evaluate expressions which is used inside of APISIX",
    homepage = "https://github.com/api7/lua-resty-expr",
    license = "Apache License 2.0",
    maintainer = "Yuansheng Wang <membphis@gmail.com>"
}

dependencies = {
}


build = {
   type = "builtin",
   modules = {
    ["resty.expr.v1"] = "lib/resty/expr/v1.lua",
   }
}
