local state_manager = require 'state_manager'
local lose = state_manager:register('lose')
local paper = require 'paper'
local gui = require 'gui_overlay'
local image_bank = require 'image_bank'

local img = image_bank:get('assets/ggj_winlose.png')
local captured_scene
local displacement = 0

function lose:enter(scene)
  captured_scene = scene
end

function lose:update(dt)
  displacement = displacement + dt * PIN_SPACING / TOOTH_DT
  paper:update(dt)
end

function lose:draw()
  paper:draw_background()

  love.graphics.push()
  love.graphics.translate(displacement, 0)
  paper:draw_shear()
  captured_scene:draw_contents()
  love.graphics.pop()

  local img_width = img:getWidth()
  local x = displacement - img_width * 2
  love.graphics.setColor(255, 255, 255)
  love.graphics.draw(
    img,
    math.min(x, (SCREEN_WIDTH - img_width) / 2), 80
  )

  gui:draw()
end

function lose:keyreleased(k)
  if k == 'escape' then
    state_manager:switch('title')
  elseif k == 'kpenter' or k == 'return' then
    state_manager.states.play:start_over()
    state_manager:switch('play')
  end
end

return lose