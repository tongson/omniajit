local ring = {}

function ring.new(max_size)
   local hist = { __index = ring }
   setmetatable(hist, hist)
   hist.max_size = max_size
   hist.size = 0
   hist.cursor = 1
   return hist
end

function ring:concat(c)
  local s = ""
  for n=1, #self do
    s = string.format("%s%s%s", s, tostring(self[n]), c)
  end
  return s
end

function ring:table()
  local t = {}
  for n=1, #self do
    t[n] = tostring(self[n])
  end
  return t
end

function ring:push(value)
  if self.size < self.max_size then
    table.insert(self, value)
    self.size = self.size + 1
  else
    self[self.cursor] = value
    self.cursor = self.cursor % self.max_size + 1
  end
end

function ring:iterator()
  local i = 0
  return function()
    i = i + 1
    if i <= self.size then
      return self[(self.cursor - i - 1) % self.size + 1]
    end
  end
end

return ring
