# vim:set ft= ts=4 sw=4 et fdm=marker:

use t::Expr 'no_plan';

repeat_each(1);
run_tests();

__DATA__

=== TEST 1: uri args
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex = expr.new({
                {"arg_k", "==", "v"}
            })

            ngx.say(ex:eval(ngx.var))
        }
    }
--- request
GET /t?k=v
--- response_body
true



=== TEST 2: uri args(not hit)
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex = expr.new({
                {"arg_k", "v"}
            })

            ngx.say(ex:eval(ngx.var))
        }
    }
--- request
GET /t?k=not_hit
--- response_body
false



=== TEST 3: http header
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex = expr.new({
                {"http_test", "==", "v"}
            })

            ngx.say(ex:eval(ngx.var))
        }
    }
--- more_headers
test: v
--- response_body
true



=== TEST 4: http header(not hit)
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex = expr.new({
                {"http_test", "v"}
            })

            ngx.say(ex:eval(ngx.var))
        }
    }
--- more_headers
test: not-hit
--- response_body
false



=== TEST 5: uri args + header + server_port
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex = expr.new({
                {"arg_k", "==", "v"},
                {"host", "==", "localhost"},
                {"server_port", "==", "1984"},
            })

            ngx.say(ex:eval(ngx.var))
        }
    }
--- request
GET /t?k=v
--- response_body
true



=== TEST 6: uri args + header + server_port (not hit)
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex = expr.new({
                {"arg_k", "v"},
                {"host", "localhost"},
                {"server_port", "1984-not"},
            })

            ngx.say(ex:eval(ngx.var))
        }
    }
--- request
GET /t?k=v
--- response_body
false



=== TEST 7: ~=: not hit
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex = expr.new({
                {"arg_k", "~=", "v"}
            })

            ngx.say(ex:eval(ngx.var))
        }
    }
--- request
GET /t?k=v
--- response_body
false



=== TEST 8: ~=: hit
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex = expr.new({
                {"arg_k", "~=", "************"}
            })

            ngx.say(ex:eval(ngx.var))
        }
    }
--- request
GET /t?k=v
--- response_body
true



=== TEST 9: argument `a` > 10
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex = expr.new({
                {"arg_k", ">", 10}
            })

            ngx.say(ex:eval(ngx.var))
        }
    }
--- request
GET /t?k=11
--- response_body
true



=== TEST 10: argument `a` > 10
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex = expr.new({
                {"arg_k", ">", 10}
            })

            ngx.say(ex:eval(ngx.var))
        }
    }
--- request
GET /t?k=9
--- response_body
false



=== TEST 11: invalid operator
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex = expr.new({
                {"arg_k", "invalid", 10}
            })

            ngx.say(ex:eval(ngx.var))
        }
    }
--- request
GET /t?k=9
--- response_body
false



=== TEST 12: have no uri args
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex = expr.new({
                {"arg_k", ">", 10}
            })

            ngx.say(ex:eval({}))
        }
    }
--- response_body
false



=== TEST 13: ~= nil
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex = expr.new({
                {"arg_k", "~=", nil}
            })
            ngx.say(ex:eval(ngx.var))
        }
    }
--- request
GET /t?k=v
--- response_body
true



=== TEST 14: IN: hit
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex = expr.new({
                {"arg_k", "in", {'1','2'}}
            })

            ngx.say(ex:eval(ngx.var))
            ngx.say(ex:eval({arg_k='2'}))
            ngx.say(ex:eval({arg_k='4'}))
            ngx.say(ex:eval({}))
            ngx.say(ex:eval({arg_k=nil}))
        }
    }
--- request
GET /t?k=1
--- response_body
true
true
false
false
false



=== TEST 15: operator has
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex = expr.new({
                {"x", "has", "a"}
            })

            ngx.say(ex:eval({x = {'a', 'b'}}))
            ngx.say(ex:eval({x = {'a'}}))
            ngx.say(ex:eval({x = {'b'}}))
            ngx.say(ex:eval({x = {}}))
        }
    }
--- response_body
true
true
false
false



=== TEST 16: use ngx.var if ctx is not specific
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex = expr.new({
                {"arg_k", "==", "v"}
            })

            ngx.say(ex:eval())
        }
    }
--- request
GET /t?k=v
--- response_body
true
