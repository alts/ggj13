local events = {}

local function init(self)
  self.listeners = {}
  setmetatable(self.listeners, {
    __mode = 'k'
  })

  setmetatable(events, {
    __call = function (_, obj)
      return {
        listen = function (_, event_type, listener)
          return self:listen(event_type, obj, listener)
        end
      }
    end
  })
end

local function listen(self, event_type, key, listener)
  if self.listeners[event_type] == nil then
    self.listeners[event_type] = {}
  end

  self.listeners[event_type][key] = listener
end

local function trigger(self, event_type, event)
  local listeners = self.listeners[event_type]
  if listeners ~= nil then
    for _, fn in pairs(listeners) do
      fn(event)
    end
  end
end

local function clear(self, key)
  for event_type, t in pairs(self.listeners) do
    t[key] = nil
  end
end

events.init = init
events.listen = listen
events.trigger = trigger
events.clear = clear

events:init()

return events