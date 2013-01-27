local state_manager = require 'state_manager'
local slide = state_manager:register('slide')
local gui = require 'gui_overlay'
local paper = require 'paper'

local line_width = 0
local elapsed_time = 0
local from_left = false
local distance = 0
local move_factor = 3

function slide:enter()
  from_left = false
  line_width = 0
  elapsed_time = 0
  distance = 0
end

function slide:update(dt)
  elapsed_time = elapsed_time + dt
  line_width = line_width + move_factor * dt * PIN_SPACING / TOOTH_DT
  gui:update(dt)
  paper:update(dt * move_factor)

  if elapsed_time > 2 then
    if not from_left then
      state_manager.states.play:reset()
      from_left = true
    end

    distance = move_factor * (elapsed_time - 2) * PIN_SPACING / TOOTH_DT - SCREEN_WIDTH

    if distance >= 0 then
      state_manager:switch('play')
    end
  end
end


function slide:draw()
  paper:draw()

  love.graphics.push()
  love.graphics.translate(
    from_left and distance or line_width,
    0
  )
  state_manager.states.play:draw_contents()
  love.graphics.pop()

  gui:draw()

  local y = SCREEN_PADDING + PIN_WIDTH / 2 + 5 * PIN_SPACING - RESTING_PIN_OFFSET
  love.graphics.setColor(255, 0, 0)
  love.graphics.setLineWidth(2)
  love.graphics.line(
    distance < 0 and distance + SCREEN_WIDTH or -200, y,
    line_width - 200, y
  )
  love.graphics.setLineWidth(1)
end

return slide