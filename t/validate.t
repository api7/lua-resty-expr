# vim:set ft= ts=4 sw=4 et fdm=marker:

use t::Expr 'no_plan';

add_block_preprocessor(sub {
    my ($block) = @_;

    if (!$block->request) {
        $block->set_value("request", "GET /t");
    }

    if (!$block->no_error_log) {
        $block->set_value("no_error_log", "[error]\n[alert]");
    }

    $block;
});

repeat_each(1);
run_tests();

__DATA__

=== TEST 1: invalid operator
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex, err = expr.new({
                {"arg_k", "=", "v"}
            })

            ngx.say(err)
        }
    }
--- response_body
invalid operator '='



=== TEST 2: invalid expression
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            for _, case in ipairs({
                {
                    {"arg_k"}
                },
                {
                    {}
                },
            }) do
                local ex, err = expr.new(case)

                ngx.say(err)
            end
        }
    }
--- response_body
invalid expression
rule too short



=== TEST 3: bad not expression
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex, err = expr.new({
                { "!", "arg_k", "==", "1"}
            })

            ngx.say(err)
        }
    }
--- response_body
bad 'not' expression



=== TEST 4: empty argument
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex, err = expr.new()

            ngx.say(err)
        }
    }
--- response_body
missing argument rule



=== TEST 5: rule too short
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex, err = expr.new({
                "OR",
                {"arg_weight", ">", 10},
            })
            ngx.say(err)
        }
    }
--- request
GET /t?weight=12
--- response_body
rule too short



=== TEST 6: rule too short, nested
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex, err = expr.new({
                "OR",
                {"arg_weight", ">", 10},
                {
                    "AND"
                }
            })
            ngx.say(err)
        }
    }
--- request
GET /t?weight=12
--- response_body
rule too short



=== TEST 7: empty rule
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex, err = expr.new({
            })
            ngx.say(err)
            ngx.say(ex:eval(ngx.var))
        }
    }
--- request
GET /t?weight=12
--- response_body
nil
true
