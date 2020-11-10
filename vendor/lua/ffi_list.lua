--
-- Copyright (c) 2020 lalawue
--
-- This library is free software; you can redistribute it and/or modify it
-- under the terms of the MIT license. See LICENSE for details.
--

--[[
   ffi_list will keep only one value instance,
   for node <-> value mapping,
   limited size but at least 1e30 slot, change this in _nextKey()
]]
local ffi = require("ffi")

ffi.cdef [[
struct _cnode {
    struct _cnode *prev;
    struct _cnode *next;
    double key;
};
struct _chead {
    struct _cnode *head;
    struct _cnode *tail;
};
void* calloc(size_t count, size_t size);
void free(void *ptr);
]]

local C = ffi.C

local _M = {}
_M.__index = _M

local function _nextKey(self)
    local key = self._key + 1e-32 -- ignore significant digit
    while self._nvmap[key] do
        key = key + math.random()
    end
    self._key = key
    return key
end

local function _calloc(str)
    return ffi.cast(str .. "*", C.calloc(1, ffi.sizeof(str)))
end

local function _add_maps(self, node, value)
    self._vnmap[value] = node
    self._nvmap[node.key] = value
    self._count = self._count + 1
    return value
end

local function _remove_node(self, node)
    if node == nil then
        return nil
    end
    local value = self._nvmap[node.key]
    if self._root.head == node then
        self._root.head = node.next
    end
    if self._root.tail == node then
        self._root.tail = node.prev
    end
    if node.prev ~= nil then
        node.prev.next = node.next
    end
    if node.next ~= nil then
        node.next.prev = node.prev
    end
    self._nvmap[node.key] = nil
    self._vnmap[value] = nil
    C.free(node)
    self._count = self._count - 1
    return value
end

-- public interface
--

function _M:first()
    if self._count <= 0 then
        return nil
    end
    return self._nvmap[self._root.head.key]
end

function _M:last()
    if self._count <= 0 then
        return nil
    end
    return self._nvmap[self._root.tail.key]
end

function _M:pushf(value)
    if value == nil then
        return nil
    end
    _remove_node(self, self._vnmap[value])
    local node = _calloc("struct _cnode")
    node.key = _nextKey(self)
    node.next = self._root.head
    if self._root.head ~= nil then
        self._root.head.prev = node
    else
        self._root.tail = node
    end
    self._root.head = node
    return _add_maps(self, node, value)
end

-- push last
function _M:pushl(value)
    if value == nil then
        return nil
    end
    _remove_node(self, self._vnmap[value])
    local node = _calloc("struct _cnode")
    node.key = _nextKey(self)
    node.prev = self._root.tail
    if self._root.tail ~= nil then
        self._root.tail.next = node
    else
        self._root.head = node
    end
    self._root.tail = node
    return _add_maps(self, node, value)
end

-- insert front
function _M:insertf(value, beforeValue)
    if value == nil or beforeValue == nil then
        return
    end
    local vnode = self._vnmap[value]
    if vnode ~= nil then
        _remove_node(self, vnode)
    end
    local bnode = self._vnmap[beforeValue]
    if bnode == nil then
        return
    end
    vnode = _calloc("struct _cnode")
    vnode.key = _nextKey(self)
    vnode.prev = bnode.prev
    vnode.next = bnode
    if bnode.prev ~= nil then
        bnode.prev.next = vnode
    end
    bnode.prev = vnode
    return _add_maps(self, vnode, value)
end

-- insert after
function _M:insertl(value, afterValue)
    if value == nil or afterValue == nil then
        return
    end
    local vnode = self._vnmap[value]
    if vnode ~= nil then
        _remove_node(self, vnode)
    end
    local anode = self._vnmap[afterValue]
    if anode == nil then
        return
    end
    vnode = _calloc("struct _cnode")
    vnode.key = _nextKey(self)
    vnode.prev = anode
    vnode.next = anode.next
    if anode.next ~= nil then
        anode.next.prev = vnode
    end
    anode.next = vnode
    return _add_maps(self, vnode, value)
end

function _M:popf()
    if self._count <= 0 then
        return nil
    end
    return _remove_node(self, self._root.head)
end

-- popp last
function _M:popl()
    if self._count <= 0 then
        return nil
    end
    return _remove_node(self, self._root.tail)
end

function _M:remove(value)
    if value == nil then
        return nil
    end
    return _remove_node(self, self._vnmap[value])
end

function _M:next(value)
    if value == nil then
        return nil
    end
    local node = self._vnmap[value]
    if node == nil or node.next == nil then
        return nil
    end
    return self._nvmap[node.next.key]
end

function _M:prev(value)
    if value == nil then
        return nil
    end
    local node = self._vnmap[value]
    if node == nil or node.prev == nil then
        return nil
    end
    return self._nvmap[node.prev.key]
end

function _M:range(from, to)
    from = from or 1
    to = to or self._count
    if self._count <= 0 or from < 1 or from > self._count or from > to then
        return {}
    end
    to = math.min(self._count, to)
    local range = {}
    local idx = 1
    local node = self._root.head
    repeat
        local nn = node.next
        if idx >= from and idx <= to then
            range[#range + 1] = self._nvmap[node.key]
        end
        node = nn
        idx = idx + 1
    until (node == nil) or (idx > to)
    return range
end

function _M:walk()
    if self._count <= 0 then
        return function()
            return nil
        end
    end
    local idx = 1
    local node = self._root.head
    return function()
        if node ~= nil then
            local i = idx
            local n = node
            idx = idx + 1
            node = node.next
            return i, self._nvmap[n.key]
        else
            return nil
        end
    end
end

function _M:clear()
    if self._count <= 0 then
        return
    end
    for _, n in pairs(self._vnmap) do
        C.free(n)
    end
    self._root.head = nil
    self._root.tail = nil
    self._vnmap = {} -- value to node
    self._nvmap = {} -- node to value
    self._count = 0
    self._key = 0 -- for key generation
end

function _M:count()
    return self._count
end

-- constructor
local function _new()
    local ins = setmetatable({}, _M)
    ins._root = _calloc("struct _chead")
    ins._root.head = nil
    ins._root.tail = nil
    ins._vnmap = {} -- value to node
    ins._nvmap = {} -- node to value
    ins._count = 0
    ins._key = 0 -- for key generation
    ffi.gc(
        ins._root,
        function(root)
            for _, n in pairs(ins._vnmap) do
                C.free(n)
            end
            C.free(root)
        end
    )
    return ins
end

return {
    new = _new
}
