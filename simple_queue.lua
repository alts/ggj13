local SimpleQueue = {}

local function init(self)
  self.head = 1
  self.tail = 1
  self.items = {}
end


local function add(self, item)
  local tail = self.tail
  table.insert(self.items, tail, item)
  self.tail = tail + 1
end


local function is_empty(self)
  local items = self.items

  for i = self.head, self.tail do
    if items[i] ~= nil then
      return false
    end
  end


  self:init() -- size maintenance
  return true
end


local function pop(self)
  local head = self.head
  local ret = self.items[head]
  self.head = head + 1
  return ret
end


local function peek(self, index)
  -- preserve indexing from 1
  index = (index or 1) - 1
  return self.items[self.head + index]
end


local function size(self)
  return self.tail - self.head
end


init(SimpleQueue)
SimpleQueue.init = init
SimpleQueue.add = add
SimpleQueue.is_empty = is_empty
SimpleQueue.pop = pop
SimpleQueue.peek = peek
SimpleQueue.size = size

return SimpleQueue