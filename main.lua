inspect = require 'lib.inspect.inspect'

require 'constants'
require 'create'
Timer = require 'lib.hump.timer'
inspect = require 'lib.inspect.inspect'
require 'lib.slam'

--love.audio.setVolume(0)
love.graphics.setBackgroundColor(244, 242, 216)

local Gamestate = require 'lib.hump.gamestate'

-- game states
local play_state = require 'play'

-- load other states
local states = {
  'slide'
}

for i = 1, #states do
  require(states[i])
end

Gamestate.registerEvents()
Gamestate.switch(play_state)