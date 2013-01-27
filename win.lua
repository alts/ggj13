local state_manager = require 'state_manager'
local win = state_manager:register('win')
local paper = require 'paper'
local gui = require 'gui_overlay'
local image_bank = require 'image_bank'

local displacement = 0
local captured_scene
local base_y = SCREEN_PADDING + PIN_WIDTH / 2 + 5 * PIN_SPACING - RESTING_PIN_OFFSET
local points = {600,-600,600,-500,250,-200,100,-90,-80,-80,0,0,0,0,0,0,0,0}
local dx = 0
local img = image_bank:get('assets/ggj_win.png')

function win:enter(scene)
  points = {0,0,0,0,0,0,0}
  displacement = 0
  dx = 0
  captured_scene = scene
end

function win:update(dt)
  displacement = displacement - dt * PIN_SPACING / TOOTH_DT

  if displacement > -SCREEN_WIDTH - 250 then
    if #points == 0 then
      for i=1,15 do
        table.insert({0, 0})
      end
    end
  end

  if displacement > -SCREEN_WIDTH - 250 then
    dx = dx + dt * PIN_SPACING / TOOTH_DT
    while dx > PIN_SPACING / 3 do
      dx = dx - PIN_SPACING / 3
      if points[1] < 0 then
        table.insert(points, 1, 300)
      else
        table.insert(points, 1, -300)
      end
    end
  else
    if points[1] ~= 0 then
      for i=1,10 do
        points[i] = 0
      end
    end

    dx = dx + dt * PIN_SPACING/ TOOTH_DT
  end

  paper:update(dt)
end

function win:keyreleased(k)
  if k == 'escape' then
    state_manager:switch('title')
  end
end

function win:draw()
  paper:draw_background()

  love.graphics.setColor(255, 0, 0)

  if displacement > -SCREEN_WIDTH - 250 then
    love.graphics.push()
    love.graphics.translate(-displacement, 0)
    paper:draw_shear()
    captured_scene:draw_contents()
    love.graphics.pop()
  else
    love.graphics.setColor(255, 0, 0)
    love.graphics.line(
      -displacement - SCREEN_WIDTH - 250, base_y,
      -displacement - SCREEN_WIDTH - 250, base_y
    )
  end

  love.graphics.setColor(255, 0, 0)
  love.graphics.setLineWidth(2)
  local draw_shit = {}
  for i=1,#points do
    table.insert(draw_shit, dx + (i-1)* PIN_SPACING / 3 - 400)
    table.insert(draw_shit, base_y + points[i])
  end
  love.graphics.line(draw_shit)
  love.graphics.setLineWidth(1)

  local img_width = img:getWidth()
  local x = -displacement - SCREEN_WIDTH - 250 - img_width * 2
  love.graphics.setColor(244, 242, 216)
  love.graphics.setColor(255, 255, 255)
  love.graphics.draw(
    img,
    math.min(x, (SCREEN_WIDTH - img_width) / 2), 80
  )

  gui:draw()
end

return win