local gui_overlay = {
  stage = 3
}

local timer = require 'timer'

function gui_overlay:move_back()
end


function gui_overlay:move_forward()
end


function gui_overlay:update(dt)
end


function gui_overlay:draw()
  -- overview bar
  love.graphics.setColor(41, 39, 59)
  love.graphics.rectangle(
    'fill',
    0, 0,
    SCREEN_WIDTH, OVERVIEW_HEIGHT
  )

  -- timer bar
  love.graphics.setColor(0, 0, 0)
  love.graphics.rectangle(
    'fill',
    0, SCREEN_HEIGHT - TIMER_HEIGHT,
    SCREEN_WIDTH, TIMER_HEIGHT
  )

  local timer_progress = timer:percent_remaining()
  love.graphics.setColor(255, 255 * timer_progress, 41)
  love.graphics.rectangle(
    'fill',
    0, SCREEN_HEIGHT - TIMER_HEIGHT,
    SCREEN_WIDTH * timer_progress, TIMER_HEIGHT
  )
end


return gui_overlay