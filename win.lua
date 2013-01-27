local state_manager = require 'state_manager'
local win = state_manager:register('win')
local paper = require 'paper'
local gui = require 'gui_overlay'

local displacement = 0
local captured_scene
local base_y = SCREEN_PADDING + PIN_WIDTH / 2 + 5 * PIN_SPACING - RESTING_PIN_OFFSET
local points = {600,-600,600,-500,250,-200,100,-90,-80,-80,0,0,0,0,0,0,0,0}
local dx = 0

function win:enter(scene)
  points = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
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
  else
    dx = dx + dt * PIN_SPACING/ TOOTH_DT
    while dx > PIN_SPACING / 10 do
      dx = dx - PIN_SPACING / 10
      if points[1] < 0 then
        table.insert(points, 1, 300)
      else
        table.insert(points, 1, -300)
      end
    end
  end

  paper:update(dt)
end

function win:draw()
  paper:draw_background()

  love.graphics.setColor(255, 0, 0)

  if displacement > -SCREEN_WIDTH - 250 then
    love.graphics.line(
      SCREEN_WIDTH + 250 + displacement, base_y,
      SCREEN_WIDTH, base_y
    )

    love.graphics.push()
    love.graphics.translate(-displacement, 0)
    paper:draw_shear()
    captured_scene:draw_contents()
    love.graphics.pop()
  else
    local draw_shit = {}
    for i=1,#points do
      table.insert(draw_shit, dx + (i-2)* PIN_SPACING / 10)
      table.insert(draw_shit, base_y + points[i])
    end
    love.graphics.line(draw_shit)
  end

  gui:draw()
end

return win