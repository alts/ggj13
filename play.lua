local state_manager = require 'state_manager'
local play = state_manager:register('play')

local key = {3, 1, 2, 4, 0}
local displacements = {0, 0, 0, 0, 0}
local player_offsets = {0, 0, 0, 0, 0}
local selection_index = 1
local tooth_dt = 0.5
local total_time = 0
local teeth = 0
local rest_time = 5

-- CONSTANTS
local PIN_WIDTH = 40
local PIN_HEIGHT = 4 * PIN_WIDTH
local PIN_SPACING = PIN_WIDTH * 1.5
local PIN_DY = PIN_WIDTH / 2
local RESTING_PIN_OFFSET = 60

function play:keyreleased(k)
  if k == 'left' then
    selection_index = ((#key + selection_index - 2) % #key) + 1
  elseif k == 'right' then
    selection_index = (selection_index % #key) + 1
  elseif k == 'up' then
      if player_offsets[selection_index] > -1 then
        player_offsets[selection_index] = player_offsets[selection_index] - 1
      end
  elseif k == 'down' then
      if player_offsets[selection_index] < PIN_HEIGHT/PIN_DY - 1 then
        player_offsets[selection_index] = player_offsets[selection_index] + 1
      end
  end
end


function play:update(dt)
  total_time = total_time + dt

  teeth = math.floor(total_time / tooth_dt)
  local size = #key + rest_time
  local disp

  for i=1,5 do
    disp = key[((teeth - i - 1) % size) + 1]
    if disp then
      displacements[i] = disp
    else
      displacements[i] = 0
    end
  end
end


function play:draw()
  -- pins
  for i=1,5 do
    local x = 10 + PIN_SPACING * (i - 1)
    local y = PIN_HEIGHT - displacements[i] * PIN_DY - RESTING_PIN_OFFSET
    if i == selection_index then
      love.graphics.setColor(0, 255, 255)
    else
      love.graphics.setColor(255, 255, 255)
    end

    love.graphics.rectangle(
      'fill',
      x,
      y,
      PIN_WIDTH,
      PIN_HEIGHT
    )
    love.graphics.setColor(0, 0, 255)
    love.graphics.rectangle(
      'fill',
      x,
      y,
      PIN_WIDTH,
      key[6 - i] * PIN_DY + PIN_DY * player_offsets[i]
    )
  end

  -- EKG line
  love.graphics.setColor(0, 255, 0)
  local points = {}
  local dx = 0
  for i=1,#key*2 do
    local t = ((teeth - i - 1) % #key) + 1
    table.insert(points, 10 + PIN_WIDTH / 2 + PIN_SPACING * (i - 1))
    local t2 = ((teeth - i - 1) % (#key*2)) + 1
    if t2 > #key then
      table.insert(points, 20 + 5 * PIN_SPACING - RESTING_PIN_OFFSET)
    else
      table.insert(points, 20 + 5 * PIN_SPACING - key[t] * PIN_DY - RESTING_PIN_OFFSET)
    end
  end

  love.graphics.line(points)

  -- shear line
  love.graphics.setColor(255, 0, 0)
  love.graphics.line(10, PIN_HEIGHT, 10 + PIN_SPACING * 5, PIN_HEIGHT)
end

return play
