-- https://github.com/api7/lua-resty-radixtree
--
-- Copyright 2020 Shenzhen ZhiLiu Technology Co., Ltd.
-- https://www.apiseven.com
--
-- See the NOTICE file distributed with
-- this work for additional information regarding copyright ownership.
-- The owner licenses this file to You under the Apache License, Version 2.0;
-- you may not use this file except in compliance with
-- the License. You may obtain a copy of the License at
--
--    http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
local ipairs      = ipairs
local setmetatable = setmetatable
local tonumber    = tonumber
local type = type
local new_tab     = require("table.new")
local re_find     = ngx.re.find
local ngx_var     = ngx.var
local ngx_null    = ngx.null


local _M = {}
local mt = { __index = _M }
local not_op = "!"


local function in_array(l_v, r_v)
    if type(r_v) == "table" then
        for _,v in ipairs(r_v) do
            if v == l_v then
                return true
            end
        end
    end
    return false
end


local function has_element(l_v, r_v)
    if type(l_v) == "table" then
        for _, v in ipairs(l_v) do
            if v == r_v then
                return true
            end
        end

        return false
    end

    return false
end


local compare_funcs = {
    ["=="] = function (l_v, r_v)
        if type(r_v) == "number" then
            l_v = tonumber(l_v)
            if not l_v then
                return false
            end
        end
        return l_v == r_v
    end,
    ["~="] = function (l_v, r_v)
        return l_v ~= r_v
    end,
    [">"] = function (l_v, r_v)
        l_v = tonumber(l_v)
        r_v = tonumber(r_v)
        if not l_v or not r_v then
            return false
        end
        return l_v > r_v
    end,
    ["<"] = function (l_v, r_v)
        l_v = tonumber(l_v)
        r_v = tonumber(r_v)
        if not l_v or not r_v then
            return false
        end
        return l_v < r_v
    end,
    ["~~"] = function (l_v, r_v)
        local from = re_find(l_v, r_v, "jo")
        if from then
            return true
        end
        return false
    end,
    ["~*"] = function (l_v, r_v)
        local from = re_find(l_v, r_v, "joi")
        if from then
            return true
        end
        return false
    end,
    ["IN"] = in_array,
    ["in"] = in_array,
    ["has"] = has_element,
}


local function compare_val(l_v, op, r_v)
    if r_v == ngx_null then
        r_v = nil
    end

    local com_fun = compare_funcs[op]
    if not com_fun then
        return false
    end
    return com_fun(l_v, r_v)
end


function _M.new(rule)
    if not rule then
        return nil, "missing argument route"
    end

    local compiled = new_tab(#rule, 0)
    for i, expr in ipairs(rule) do
        local l_v, op, r_v
        local reverse = false

        if #expr == 4 then
            if expr[2] ~= not_op then
                return nil, "bad 'not' expression"
            end

            reverse = true
            l_v, op, r_v = expr[1], expr[3], expr[4]
        else
            l_v, op, r_v = expr[1], expr[2], expr[3]
        end

        if r_v == nil and not compare_funcs[op] then
            -- for compatibility
            r_v = op
            op = "=="

            if r_v == nil then
                return nil, "invalid expression"
            end
        end

        if l_v == nil or op == nil then
            return nil, "invalid expression"
        end

        if compare_funcs[op] == nil then
            return nil, "invalid operator '" .. op .. "'"
        end

        compiled[i] = {
            l_v = l_v,
            op = op,
            r_v = r_v,
            reverse = reverse,
        }
    end

    return setmetatable({rule = compiled}, mt)
end


-- '...' is chosen for backward compatibility, for instance, we need to pass
-- `opts` argument in lua-resty-radixtree
function _M.eval(self, ctx, ...)
    local ctx = ctx or ngx_var
    if type(ctx) ~= "table" then
        return nil, "bad ctx type"
    end

    for _, expr in ipairs(self.rule) do
        local l_v = ctx[expr.l_v]

        if compare_val(l_v, expr.op, expr.r_v, ...) == expr.reverse then
            return false
        end
    end

    return true
end


return _M
