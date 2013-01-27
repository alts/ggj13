local state_manager = require 'state_manager'
local tutorial = state_manager:register('tutorial')
local paper = require 'paper'
local image_bank = require 'image_bank'

local img = image_bank:get('assets/ggj_chamber_tutorial.png')

function tutorial:draw()
  paper:draw(true)
  love.graphics.draw(
    img,
    0, 0
  )
end


function tutorial:keyreleased(k)
  if k == 'kpenter' or k =='return' then
    state_manager:switch('play')
  end
end


return title