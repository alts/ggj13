local gui_overlay = {
  stage = 3
  -- stages = nil
}

local timer = require 'timer'

local frame_offset = 0
local direction = nil

function gui_overlay:move_back()
  self.stage = self.stage - 1
  frame_offset = SCREEN_WIDTH / #self.stages
  direction = -1
end


function gui_overlay:move_forward()
  self.stage = self.stage + 1
  frame_offset = -SCREEN_WIDTH / #self.stages
  direction = 1
end


function gui_overlay:update(dt)
  if direction == -1 then
    frame_offset = frame_offset - SCREEN_WIDTH / (#self.stages * 3) * dt
    if frame_offset <= 0 then
      direction = nil
    end
  elseif direction == 1 then
    frame_offset = frame_offset + SCREEN_WIDTH / (#self.stages * 3) * dt
    if frame_offset >= 0 then
      direction = nil
    end
  end
end


function gui_overlay:draw()
  local stages = self.stages
  local stage

  -- overview bar
  love.graphics.setColor(41, 39, 59)
  love.graphics.rectangle(
    'fill',
    0, 0,
    SCREEN_WIDTH, OVERVIEW_HEIGHT
  )

  love.graphics.setColor(255, 255, 0)
  love.graphics.setLineWidth(1)
  local stage_size = SCREEN_WIDTH / #stages
  local baseline = OVERVIEW_HEIGHT * 0.8
  local dx = stage_size / 8
  local dy = OVERVIEW_HEIGHT * 6 / 50
  local base_x
  for i=1,#stages do
    base_x = (i - 1) * stage_size
    stage = stages[i]
    love.graphics.line(
      base_x, baseline,
      base_x + dx, baseline,
      base_x + dx * 2, baseline - dy * stage.key[5],
      base_x + dx * 3, baseline - dy * stage.key[4],
      base_x + dx * 4, baseline - dy * stage.key[3],
      base_x + dx * 5, baseline - dy * stage.key[2],
      base_x + dx * 6, baseline - dy * stage.key[1],
      base_x + dx * 7, baseline,
      base_x + dx * 8, baseline
    )
  end
  love.graphics.setLineWidth(1)

  love.graphics.setColor(255, 0, 0)
  love.graphics.setLineWidth(2)
  love.graphics.rectangle(
    'line',
    frame_offset + (self.stage - 1) * stage_size, 0,
    stage_size, OVERVIEW_HEIGHT
  )
  love.graphics.setLineWidth(1)

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