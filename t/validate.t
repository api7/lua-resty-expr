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
invalid expression



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
