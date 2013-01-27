local state_manager = require 'state_manager'
local tutorial = state_manager:register('tutorial')
local paper = require 'paper'
local image_bank = require 'image_bank'
local sound_bank = require 'sound_bank'

local img = image_bank:get('assets/ggj_chamber_tutorial.png')

function tutorial:draw()
  paper:draw_background()
  love.graphics.draw(
    img,
    0, 0
  )
end


function tutorial:keyreleased(k)
  if k == 'kpenter' or k =='return' then
    state_manager.states.play:start_over()
    sound_bank:get('assets/heartlocker.mp3'):play()
    state_manager:switch('play')
  end
end


return title