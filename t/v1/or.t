use t::Expr 'no_plan';

repeat_each(1);

run_tests();

__DATA__

=== TEST 1: or
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex = expr.new({
                "OR",
                {"arg_weight", ">", 10},
                {"arg_weight", "!", ">", 15},
            })

            ngx.say(ex:eval(ngx.var))
        }
    }
--- request
GET /t?weight=12
--- response_body
true



=== TEST 2: or (one rule fails)
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex = expr.new({
                "OR",
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



=== TEST 3: or (both rules fail)
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex = expr.new({
                "OR",
                {"arg_weight", ">", 20},
                {"arg_weight", "!", ">", 15},
            })

            ngx.say(ex:eval(ngx.var))
        }
    }
--- request
GET /t?weight=16
--- response_body
false



=== TEST 4: nested logical expr
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex = expr.new({
                "OR",
                {
                    "OR",
                    {"arg_weight", ">", 20},
                    {"arg_weight", "!", ">", 15},
                },
                {
                    "AND",
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



=== TEST 5: nested logical expr (both fail)
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex = expr.new({
                "OR",
                {
                    "OR",
                    {"arg_weight", ">", 20},
                    {"arg_weight", "!", ">", 15},
                },
                {
                    "AND",
                    {"arg_height", ">", 10},
                    {"arg_height", "!", "<", 15},
                }
            })

            ngx.say(ex:eval(ngx.var))
        }
    }
--- request
GET /t?weight=16&height=14
--- response_body
false



=== TEST 6: nested normal expr
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex, err = expr.new({
                "OR",
                {
                    {"arg_weight", "!", ">", 15},
                },
                {
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



=== TEST 7: nested normal expr (both fail)
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex = expr.new({
                "OR",
                {
                    {"arg_weight", "!", ">", 15},
                },
                {
                    {"arg_height", ">", 10},
                    {"arg_height", "!", "<", 15},
                }
            })

            ngx.say(ex:eval(ngx.var))
        }
    }
--- request
GET /t?weight=16&height=14
--- response_body
false
