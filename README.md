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
            * [Comparison Operators](#comparison-operators)
            * [Logical Operators](#logical-operators)
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

#### Comparison Operators

|**Operator**|**Description**|**Example**|
|--------|-----------|-------|
|`==`      |equal      |`["arg_version", "==", "v2"]`|
|`~=`      |not equal  |`["arg_version", "~=", "v2"]`|
|`>`       |greater than|`["arg_ttl", ">", 3600]`|
|`>=`      |greater than or equal to|`["arg_ttl", ">=", 3600]`|
|`<`       |less than  |`["arg_ttl", "<", 3600]`|
|`<=`      |less than or equal to|`["arg_ttl", "<=", 3600]`|
|`~~`      |match [RegEx](https://www.pcre.org)|`["arg_env", "~~", "[Dd]ev"]`|
|`~*`      |match [RegEx](https://www.pcre.org) (case-insensitive) |`["arg_env", "~~", "dev"]`|
|`in`      |exist in the right-hand side|`["arg_version", "in", ["v1","v2"]]`|
|`has`     |contain item in the right-hand side|`["graphql_root_fields", "has", "owner"]`|
|`!`       |reverse the adjacent operator|`["arg_env", "!", "~~", "[Dd]ev"]`|
|`ipmatch` |match IP address|`["remote_addr", "ipmatch", ["192.168.102.40", "192.168.3.0/24"]]`|


[Back to TOC](#table-of-contents)

#### Logical Operators

| **Operator** | **Explanation** |
|---|---|
| `AND` | `AND(A,B)` is true if both A and B are true. |
| `OR` | `OR(A,B)` is true if either A or B is true. |
| `!AND` | `!AND(A,B)` is true if either A or B is false. |
| `!OR` | `!OR(A,B)` is true only if both A and B are false. |

Example usage with comparison operators:

```json
[
    "AND",
    ["arg_version", "==", "v2"],
    [
        "OR",
        ["arg_action", "==", "signup"],
        ["arg_action", "==", "subscribe"]
    ]
]
```

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

