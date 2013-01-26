local Gamestate = require 'lib.hump.gamestate'

local state_manager = {}

local function init(self)
  self.states = {}
end

local function switch(self, tag, ...)
  Gamestate.switch(self.states[tag], ...)
end

local function register(self, tag)
  local state = Gamestate.new()
  self.states[tag] = state
  return state
end

init(state_manager)
state_manager.init = init
state_manager.switch = switch
state_manager.register = register

return state_manager
