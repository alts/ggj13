local state_manager = require 'state_manager'
local title = state_manager:register('title')
local paper = require 'paper'
local image_bank = require 'image_bank'
local sound_bank = require 'sound_bank'

local img = image_bank:get('assets/ggj_chamber_title.png')


function title:enter()
  heartbeat = sound_bank:get('assets/heartbeat.mp3')
  heartbeat:setLooping(true)
  heartbeat:setVolume(2)
  love.audio.play(heartbeat)
end


function title:draw()
  paper:draw_background()
  love.graphics.draw(
    img,
    0, 0
  )
end


function title:keyreleased(k)
  if k == 'kpenter' or k =='return' then
    state_manager:switch('tutorial')
  end
end


return title