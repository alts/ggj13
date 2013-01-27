local state_manager = require 'state_manager'
local slide = state_manager:register('slide_forward')
local gui = require 'gui_overlay'
local paper = require 'paper'

local elapsed_time = 0
local move_factor = 3
local distance = 0
local additional_distance = 0
local from_right = false

function slide:enter()
  from_right = false
  line_width = 0
  elapsed_time = 0
  distance = 0
end

function slide:update(dt)
  elapsed_time = elapsed_time + dt
  gui:update(dt)
  paper:update(-dt * move_factor)

  distance = distance + move_factor * dt * PIN_SPACING / TOOTH_DT

  if elapsed_time > 2 then
    if not from_right then
      state_manager.states.play:switch_stage(1)
      state_manager.states.play:reset()
      from_right = true
    end

    additional_distance = SCREEN_WIDTH - move_factor * (elapsed_time - 2) * PIN_SPACING / TOOTH_DT

    if additional_distance <= 0 then
      state_manager:switch('play')
    end
  end
end


function slide:draw()
  paper:draw()

  love.graphics.push()
  love.graphics.translate(
    from_right and additional_distance or -distance,
    0
  )
  state_manager.states.play:draw_contents()
  love.graphics.pop()

  love.graphics.setColor(255, 0, 0)
  love.graphics.setLineWidth(2)
  local y = SCREEN_PADDING + PIN_WIDTH / 2 + 5 * PIN_SPACING - RESTING_PIN_OFFSET
  love.graphics.line(
    SCREEN_WIDTH * 5 / 4 - distance, y,
    SCREEN_WIDTH, y
  )
  love.graphics.setLineWidth(1)


  gui:draw()
end


return slide