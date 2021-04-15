# vim:set ft= ts=4 sw=4 et fdm=marker:

use t::Expr 'no_plan';

repeat_each(1);

add_block_preprocessor(sub {
    my ($block) = @_;

    if (!$block->no_error_log) {
        $block->set_value("no_error_log", "[error]\n[alert]");
    }

    $block;
});

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
            local ex, err = expr.new({
                {"arg_k", "invalid", 10}
            })

            ngx.say(err)
        }
    }
--- request
GET /t?k=9
--- response_body
invalid operator 'invalid'



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



=== TEST 17: not operator
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex = expr.new({
                {"k", "!", ">", 10}
            })

            ngx.say(ex:eval({k = 11}))
            ngx.say(ex:eval({k = 9}))
        }
    }
--- response_body
false
true



=== TEST 18: and + not operator
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex = expr.new({
                {"x", ">", 10},
                {"x", "!", ">", 15},
            })

            ngx.say(ex:eval({x = 11}))
            ngx.say(ex:eval({x = 16}))
        }
    }
--- response_body
true
false



=== TEST 19: not ~~
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex = expr.new({
                {"k", "!", "~~", "[a-z]"}
            })

            ngx.say(ex:eval({k = "a"}))
            ngx.say(ex:eval({k = "9"}))
        }
    }
--- response_body
false
true



=== TEST 20: not in
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex = expr.new({
                {"k", "!", "in", {1, 2}}
            })

            ngx.say(ex:eval({k = 3}))
            ngx.say(ex:eval({k = 1}))
        }
    }
--- response_body
true
false



=== TEST 21: not has
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex = expr.new({
                {"k", "!", "has", 1}
            })

            ngx.say(ex:eval({k = {2, 3}}))
            ngx.say(ex:eval({k = {1, 2}}))
        }
    }
--- response_body
true
false



=== TEST 22: operator ~*
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex = expr.new({
                {"x", "~*", "A"}
            })

            ngx.say(ex:eval({x = 'a'}))
            ngx.say(ex:eval({x = 'A'}))
            ngx.say(ex:eval({x = 'b'}))
            ngx.say(ex:eval({x = ''}))
        }
    }
--- response_body
true
true
false
false



=== TEST 23: not ~*
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex = expr.new({
                {"x", "!", "~*", "A"}
            })

            ngx.say(ex:eval({x = 'a'}))
            ngx.say(ex:eval({x = 'A'}))
            ngx.say(ex:eval({x = 'b'}))
            ngx.say(ex:eval({x = ''}))
        }
    }
--- response_body
false
false
true
true



=== TEST 24: bad argument for ~~
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex = expr.new({
                {"arg_k", "~~", "A"}
            })

            ngx.say(ex:eval(ngx.var))
        }
    }
--- response_body
false



=== TEST 25: bad argument for ~*
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex = expr.new({
                {"arg_k", "~*", "A"}
            })

            ngx.say(ex:eval(ngx.var))
        }
    }
--- response_body
false



=== TEST 26: test ~= for the r_v is a number and equal with the tonumber(l_v), not hit
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex = expr.new({
                {"arg_age", "~=", 18}
            })

            ngx.say(ex:eval(ngx.var))
        }
    }
--- request
GET /t?age=18
--- response_body
false



=== TEST 27: test ~= for the r_v is a number and not equal with the tonumber(l_v), hit
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex = expr.new({
                {"arg_age", "~=", 18}
            })

            ngx.say(ex:eval(ngx.var))
        }
    }
--- request
GET /t?age=16
--- response_body
true



=== TEST 28: test ~= for the r_v is a number and the l_v is not , hit
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex = expr.new({
                {"arg_age", "~=", 18}
            })

            ngx.say(ex:eval(ngx.var))
        }
    }
--- request
GET /t?age=aa
--- response_body
true



=== TEST 29: test ~= for the r_v is a string but the tonumber() is true, not hit
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex = expr.new({
                {"arg_age", "~=", "18"}
            })

            ngx.say(ex:eval(ngx.var))
        }
    }
--- request
GET /t?age=18
--- response_body
false



=== TEST 30: the request parameter `name` is missing and the operator is `~=`
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex = expr.new({
                {"arg_name", "~=", "jack"}
            })

            ngx.say(ex:eval(ngx.var))
        }
    }
--- request
GET /t
--- response_body
true



=== TEST 31: the request parameter `name` is missing and the operator is `~~`
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex = expr.new({
                {"arg_name", "~~", "[a-z]{1,4}"}
            })

            ngx.say(ex:eval(ngx.var))
        }
    }
--- request
GET /t
--- response_body
false



=== TEST 32: the request parameter `name` is missing and the operator is `~*`
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex = expr.new({
                {"arg_name", "~*", "[a-z]{1,4}"}
            })

            ngx.say(ex:eval(ngx.var))
        }
    }
--- request
GET /t
--- response_body
false



=== TEST 33: operator is case insensitive
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex = expr.new({
                "or",
                {"x", "HAS", "a"},
                {"x", "HAS", "c"}
            })

            ngx.say(ex:eval({x = {'a', 'b'}}))
            ngx.say(ex:eval({x = {'a'}}))
            ngx.say(ex:eval({x = {'b'}}))
            ngx.say(ex:eval({x = {}}))
            ngx.say(ex:eval({x = {'c'}}))
        }
    }
--- response_body
true
true
false
false
true



=== TEST 34: >=
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex = expr.new({
                {"arg_k", ">=", "2"}
            })
            ngx.say(ex:eval(ngx.var))
            local ex = expr.new({
                {"arg_k", ">=", 3}
            })
            ngx.say(ex:eval(ngx.var))
        }
    }
--- request
GET /t?k=2
--- response_body
true
false



=== TEST 35: <=
--- config
    location /t {
        content_by_lua_block {
            local expr = require("resty.expr.v1")
            local ex = expr.new({
                {"arg_k", "<=", "2"}
            })
            ngx.say(ex:eval(ngx.var))
            local ex = expr.new({
                {"arg_k", "<=", 3}
            })
            ngx.say(ex:eval(ngx.var))
        }
    }
--- request
GET /t?k=3
--- response_body
false
true
