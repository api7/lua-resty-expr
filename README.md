# lua-resty-expr

## Name

A tiny DSL to evaluate expressions which is used inside of APISIX.

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://github.com/api7/lua-resty-expr/blob/main/LICENSE)

This project has been working in microservices API gateway [Apache APISIX](https://github.com/apache/incubator-apisix).

The project is open sourced by [Shenzhen ZhiLiu](https://www.apiseven.com/) Technology Co., Ltd.

In addition to this open source version, our company also provides a more powerful and performing commercial version, and provides technical support. If you are interested in our commercial version, please [contact us](https://www.apiseven.com/).

Table of Contents
=================

* [lua-resty-expr](#lua-resty-expr)
    * [Name](#name)
    * [Synopsis](#synopsis)
    * [Methods](#methods)
        * [new](#new)
            * [Operator List](#operator-list)
        * [eval](#eval)
    * [Install](#install)
        * [Compile and install](#compile-and-install)
    * [DEV ENV](#dev-env)
        * [Install Dependencies](#install-dependencies)

## Synopsis

```lua
 location / {
     content_by_lua_block {
        local expr = require("resty.expr.v1")
        local ex = expr.new({
            {"arg_name", "==", "json"},
            {"arg_weight", ">", 10},
            {"arg_weight", "!", ">", 15},
        })

        -- equal to
        -- 'ngx.say(ngx.var.arg_name == "json" and ngx.var.arg_weight > 10 and not ngx.var.arg_weight > 15)'
        ngx.say(ex:eval(ngx.var))
     }
 }
```

```lua
 location / {
     content_by_lua_block {
        local expr = require("resty.expr.v1")
        local ex = expr.new({
            "!AND",
            {"arg_name", "==", "json"},
            {
                "OR",
                {"arg_weight", ">", 10},
                {"arg_height", "!", ">", 15},
            }
        })

        -- equal to
        -- 'ngx.say(not (ngx.var.arg_name == "json" and
        --               (ngx.var.arg_weight > 10 or
        --                not ngx.var.arg_height > 15))'
        ngx.say(ex:eval(ngx.var))
     }
 }
```

[Back to TOC](#table-of-contents)

## Methods

### new

`syntax: ex, err = expr.new(rule)`

Create an expression object which can be evaluated later.

The syntax of rule is an array table of nodes.

The first node can be an expression or a logical operator.
The remain nodes can be an expression or another array of nodes which contain its logical operator and expressions.

Each expression is an array table which has three or four elements:
```lua
{
    {"var name (aka. left value)", "optional '!' operator", "operator", "const value (aka. right value)"},
    ...
}
```

Logical operator can be one of
* OR
* AND
* !OR: not (expr1 or expr2 or ...)
* !AND: not (expr1 and expr2 and ...)

Their combination can be like:

```json
[
    "AND",
    ["arg_name", "==", "json"],
    [
        "!OR",
        ["arg_weight", ">", 10],
        ["arg_height", "!", ">", 15]
    ]
]
```

[Back to TOC](#table-of-contents)

#### Operator List

|operator|description|example|
|--------|-----------|-------|
|==      |equal      |{"arg_name", "==", "json"}|
|~=      |not equal  |{"arg_name", "~=", "json"}|
|>       |greater than|{"arg_age", ">", 24}|
|<       |less than  |{"arg_age", "<", 24}|
|~~      |Regular match|{"arg_name", "~~", "[a-z]+"}|
|~*      |Case insensitive regular match|{"arg_name", "~*", "[a-z]+"}|
|in      |find in array|{"arg_name", "in", {"1","2"}}|
|has     |left value array has value in the right |{"graphql_root_fields", "has", "repo"}|
|!       |reverse the result|{"arg_name", "!", "~~", "[a-z]+"}|

[Back to TOC](#table-of-contents)

### eval

`syntax: ok, err = ex:eval(ctx)`

Evaluate the expression according to the `ctx`. If `ctx` is missing, `ngx.var` is used by default.

```lua
local ok = rx:eval()
if ok == nil then
    log_err("failed to eval expression: ", err)
    return false
end

return ok
```

[Back to TOC](#table-of-contents)

## Install

### Compile and install

```shell
make install
```

[Back to TOC](#table-of-contents)

## DEV ENV

### Install Dependencies

```shell
make deps
```
[Back to TOC](#table-of-contents)

