use t::Expr 'no_plan';

repeat_each(1);

run_tests();

__DATA__

=== TEST 1: and
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex = expr.new({
                "AND",
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



=== TEST 2: and (one rule fails)
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex = expr.new({
                "AND",
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



=== TEST 3: nested expr
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex = expr.new({
                "AND",
                {
                    "AND",
                    {"arg_weight", "<", 20},
                    {"arg_weight", "!", "<", 15},
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



=== TEST 4: nested expr (fail)
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex = expr.new({
                "AND",
                {
                    {"arg_height", ">", 10},
                    {"arg_height", "!", "<", 15},
                },
                {
                    "AND",
                    {"arg_weight", "<", 20},
                    {"arg_weight", "!", "<", 15},
                }
            })

            ngx.say(ex:eval(ngx.var))
        }
    }
--- request
GET /t?weight=14&height=16
--- response_body
false
