# Name

A tiny DSL to evaluate expressions inside [Apache APISIX](https://github.com/apache/apisix).

# Status

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://github.com/api7/lua-resty-expr/blob/main/LICENSE)

Used by:

- [Apache APISIX](https://github.com/apache/apisix): A high-performance cloud native API gateway.

Developed by [API7.ai](https://api7.ai/).

> **Note**
>
> API7.ai provides technical support for the software it maintains like this library and [Apache APISIX](https://github.com/apache/apisix). Please [contact us](https://api7.ai/contact) to learn more.

# Table of Contents

- [Name](#name)
- [Status](#status)
- [Table of Contents](#table-of-contents)
- [Synopsis](#synopsis)
- [Methods](#methods)
  - [new](#new)
    - [Usage](#usage)
  - [eval](#eval)
    - [Usage](#usage-1)
    - [Example](#example)
- [Operators](#operators)
  - [Comparison Operators](#comparison-operators)
  - [Logical Operators](#logical-operators)
  - [Example](#example-1)
- [Installation](#installation)
  - [From LuaRocks](#from-luarocks)
  - [From Source](#from-source)
- [Development](#development)

# Synopsis

```lua
 location / {
     set $arg_name 'json';
     set $arg_weight 12;
     content_by_lua_block {
        local expr = require("resty.expr.v1")
        local ex = expr.new({
            {"arg_name", "==", "json"},
            {"arg_weight", ">", 10},
            {"arg_weight", "!", ">", 15},
        })

        -- evaluates to
        -- 'ngx.say(ngx.var.arg_name == "json" and ngx.var.arg_weight > 10 and not ngx.var.arg_weight > 15)'
        ngx.say(ex:eval(ngx.var))
     }
 }
```

```lua
 location / {
    set $arg_name 'json';
    set $arg_weight 12;
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

      -- evaluates to
      -- 'ngx.say(not (ngx.var.arg_name == "json" and
      --              (ngx.var.arg_weight > 10 or
      --              not ngx.var.arg_height > 15))'
      ngx.say(ex:eval(ngx.var))
     }
 }
```

[Back to TOC](#table-of-contents)

# Methods

## new

Creates a new expression object.

### Usage

`rule` is an array of nodes. The first node can be an expression or a logical operator. The remaining nodes can be an expression or another array of nodes with logical operators and expressions.

```lua
ex, err = expr.new(rule)
```

Each expression is an array which can three or four elements:

```lua
{
    {"variable", "optional '!' operator", "operator", "constant"},
    ...
}
```

[Back to TOC](#table-of-contents)

## eval

Evaluates an expression.

### Usage

The expression is evaluated according to the `ctx`. If `ctx` is missing, `ngx.var` is used.

```lua
ok, err = ex:eval(ctx)
```

### Example

```lua
local ok = rx:eval()
if ok == nil then
    log_err("failed to evaluate expression: ", err)
    return false
end

return ok
```

[Back to TOC](#table-of-contents)

# Operators

## Comparison Operators

| Operator  | Description                                            | Example                                                            |
|-----------|--------------------------------------------------------|--------------------------------------------------------------------|
| `==`      | Equal to                                               | `["arg_version", "==", "v2"]`                                      |
| `~=`      | Not equal to                                           | `["arg_version", "~=", "v2"]`                                      |
| `>`       | Greater than                                           | `["arg_ttl", ">", 3600]`                                           |
| `>=`      | Greater than or equal to                               | `["arg_ttl", ">=", 3600]`                                          |
| `<`       | Less than                                              | `["arg_ttl", "<", 3600]`                                           |
| `<=`      | Less than or equal to                                  | `["arg_ttl", "<=", 3600]`                                          |
| `~~`      | Match [RegEx](https://www.pcre.org)                    | `["arg_env", "~~", "[Dd]ev"]`                                      |
| `~*`      | Match [RegEx](https://www.pcre.org) (case-insensitive) | `["arg_env", "~~", "dev"]`                                         |
| `in`      | Exists in the right-hand side of the operator          | `["arg_version", "in", ["v1","v2"]]`                               |
| `has`     | Contains item in the right-hand side of the operator   | `["graphql_root_fields", "has", "owner"]`                          |
| `!`       | Inverts the adjacent operator                          | `["arg_env", "!", "~~", "[Dd]ev"]`                                 |
| `ipmatch` | Match IP address                                       | `["remote_addr", "ipmatch", ["192.168.102.40", "192.168.3.0/24"]]` |

[Back to TOC](#table-of-contents)

## Logical Operators

| Operator | Description                                        |
|----------|----------------------------------------------------|
| `AND`    | `AND(A,B)` is true if both A and B are true.       |
| `OR`     | `OR(A,B)` is true if either A or B is true.        |
| `!AND`   | `!AND(A,B)` is true if either A or B is false.     |
| `!OR`    | `!OR(A,B)` is true only if both A and B are false. |

[Back to TOC](#table-of-contents)

## Example

```json
[
  "AND",
  ["arg_version", "==", "v2"],
  ["OR", ["arg_action", "==", "signup"], ["arg_action", "==", "subscribe"]]
]
```

[Back to TOC](#table-of-contents)

# Installation

## From LuaRocks

```shell
luarocks install lua-resty-expr
```

## From Source

```shell
make install
```

[Back to TOC](#table-of-contents)

# Development

To install dependencies, run:

```shell
make deps
```

[Back to TOC](#table-of-contents)
