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

=== TEST 1: sanity
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex = expr.new({
                {"remote_addr", "ipmatch", "127.0.0.1"},
            })
            ngx.say(ex:eval(ngx.var))
        }
    }
--- response_body
true



=== TEST 2: invalid ipmatch address
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")

            -- validate by expr
            local ex, err = expr.new({
                {"remote_addr", "ipmatch", nil}

            })
            ngx.say(err)

            local ex, err = expr.new({
                {"remote_addr", "ipmatch", ""}

            })
            ngx.say(err)

            local ex, err = expr.new({
                {"remote_addr", "ipmatch", {}}

            })
            ngx.say(err)

            -- validate by ipmatch
            local ex, err = expr.new({
                {"remote_addr", "ipmatch", {""}}

            })

            assert(err == "invalid ip address: ")
        }
    }
--- response_body
invalid ip address
invalid ip address
invalid ip address



=== TEST 3: ips is a table
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex = expr.new({
                {"remote_addr", "ipmatch", {"127.0.0.1"}},
            })
            ngx.say(ex:eval(ngx.var))
        }
    }
--- response_body
true



=== TEST 4: ips is CIDR
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex = expr.new({
                {"remote_addr", "ipmatch", "127.0.0.0/16"},
            })
            ngx.say(ex:eval(ngx.var))

            local ex = expr.new({
                {"remote_addr", "ipmatch", {"127.0.0.0/16"}},
            })
            ngx.say(ex:eval(ngx.var))
        }
    }
--- response_body
true
true



=== TEST 5: ips with multiple values
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex = expr.new({
                {"remote_addr", "ipmatch", {"127.0.0.1", "127.0.0.2"}},
            })
            ngx.say(ex:eval(ngx.var))

            local ex = expr.new({
                {"remote_addr", "ipmatch", {"127.0.0.2", "127.0.0.3"}},
            })
            ngx.say(ex:eval(ngx.var))
        }
    }
--- response_body
true
false



=== TEST 6: ip in args
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex = expr.new({
                {"arg_real_ip", "ipmatch", {"127.0.0.1"}},
            })
            ngx.say(ex:eval(ngx.var))

            local ex = expr.new({
                {"arg_real_ip", "ipmatch", {"127.0.0.2"}},
            })
            ngx.say(ex:eval(ngx.var))
        }
    }
--- request
GET /t?real_ip=127.0.0.1
--- response_body
true
false



=== TEST 7: ip in headers
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex = expr.new({
                {"http_real_ip", "ipmatch", {"127.0.0.1"}},
            })
            ngx.say(ex:eval(ngx.var))

            local ex = expr.new({
                {"http_real_ip", "ipmatch", {"127.0.0.2"}},
            })
            ngx.say(ex:eval(ngx.var))
        }
    }
--- more_headers
real-ip: 127.0.0.1
--- response_body
true
false



=== TEST 8: work with other operators
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex = expr.new({
                {"remote_addr", "ipmatch", {"127.0.0.1"}},
                {"arg_k", "==", "v"}

            })
            ngx.say(ex:eval(ngx.var))

            local ex = expr.new({
                {"remote_addr", "ipmatch", {"127.0.0.2"}},
                {"arg_k", "==", "v"}
            })
            ngx.say(ex:eval(ngx.var))
        }
    }
--- request
GET /t?k=v
--- response_body
true
false
