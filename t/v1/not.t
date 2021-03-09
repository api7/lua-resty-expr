use t::Expr 'no_plan';

repeat_each(1);

run_tests();

__DATA__

=== TEST 1: not and
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex = expr.new({
                "!AND",
                {"arg_weight", ">", 10},
                {"arg_weight", "!", ">", 15},
            })

            ngx.say(ex:eval(ngx.var))
        }
    }
--- request
GET /t?weight=12
--- response_body
false



=== TEST 2: not and (one rule fails)
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex = expr.new({
                "!AND",
                {"arg_weight", ">", 10},
                {"arg_weight", "!", ">", 15},
            })

            ngx.say(ex:eval(ngx.var))
        }
    }
--- request
GET /t?weight=8
--- response_body
true



=== TEST 3: not and (both rules fail)
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex = expr.new({
                "!AND",
                {"arg_weight", ">", 10},
                {"arg_weight", "!", "<", 15},
            })

            ngx.say(ex:eval(ngx.var))
        }
    }
--- request
GET /t?weight=8
--- response_body
true



=== TEST 4: not or
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex = expr.new({
                "!OR",
                {"arg_weight", ">", 10},
                {"arg_weight", "!", ">", 15},
            })

            ngx.say(ex:eval(ngx.var))
        }
    }
--- request
GET /t?weight=12
--- response_body
false



=== TEST 5: not or (one rule fails)
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex = expr.new({
                "!OR",
                {"arg_weight", ">", 10},
                {"arg_weight", "!", ">", 15},
            })

            ngx.say(ex:eval(ngx.var))
        }
    }
--- request
GET /t?weight=8
--- response_body
false



=== TEST 6: not or (both rules fail)
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex = expr.new({
                "!OR",
                {"arg_weight", ">", 10},
                {"arg_weight", "!", "<", 15},
            })

            ngx.say(ex:eval(ngx.var))
        }
    }
--- request
GET /t?weight=8
--- response_body
true



=== TEST 7: nested expr
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex = expr.new({
                "!OR",
                {
                    "AND",
                    {"arg_weight", "<", 20},
                    {"arg_weight", "!", "<", 15},
                },
                {
                    {"arg_height", ">", 10},
                    {"arg_height", "!", "<", 15},
                },
                {
                    "OR",
                    {"arg_height", ">", 10},
                    {"arg_height", "!", "<", 15},
                }
            })

            ngx.say(ex:eval(ngx.var))
        }
    }
--- request
GET /t?weight=16&height=16
--- response_body
false



=== TEST 8: nested expr (not)
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex = expr.new({
                "!OR",
                {
                    "!AND",
                    {"arg_weight", "<", 20},
                    {"arg_weight", "!", "<", 15},
                },
                {
                    "!OR",
                    {"arg_height", ">", 10},
                    {"arg_height", "!", "<", 15},
                }
            })

            ngx.say(ex:eval(ngx.var))
        }
    }
--- request
GET /t?weight=16&height=16
--- response_body
true



=== TEST 9: mix expr
--- config
    location /t {
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

            ngx.say(ex:eval(ngx.var))
        }
    }
--- request
GET /t?weight=6&height=6&name=json
--- response_body
false



=== TEST 10: mix expr (success)
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex = expr.new({
                "!AND",
                {
                    "OR",
                    {"arg_weight", ">", 10},
                    {"arg_height", "!", ">", 15},
                },
                {"arg_name", "==", "json"}
            })

            ngx.say(ex:eval(ngx.var))
        }
    }
--- request
GET /t?weight=6&height=6&name=xx
--- response_body
true



=== TEST 11: mix expr (multiple layers)
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex = expr.new({
                "!AND",
                {"arg_name", "==", "json"},
                {
                    "OR",
                    {
                        "AND",
                        {"arg_weight", ">", 10},
                        {"arg_height", ">", 10},
                    },
                    {"arg_height", "!", ">", 15},
                }
            })

            ngx.say(ex:eval(ngx.var))
        }
    }
--- request
GET /t?weight=6&height=6&name=json
--- response_body
false
