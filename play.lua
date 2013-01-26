local state_manager = require 'state_manager'
local play = state_manager:register('play')

local key = {1, 5, 3, 2, 1}
local displacements = {0, 0, 0, 0, 0}
local player_offsets = {0, 0, 0, 0, 0}
local selection_index = 1
local tooth_dt = 0.5
local total_time = 0
local teeth = 0

function play:keyreleased(k)
  if k == 'left' then
    selection_index = ((#key + selection_index - 2) % #key) + 1
  elseif k == 'right' then
    selection_index = (selection_index % #key) + 1
  elseif k == 'up' then
    player_offsets[selection_index] = player_offsets[selection_index] - 1
  elseif k == 'down' then
    player_offsets[selection_index] = player_offsets[selection_index] + 1
  end
end


function play:update(dt)
  total_time = total_time + dt
  total_time = total_time % (tooth_dt * 8)

  teeth = math.floor(total_time / tooth_dt)

  for i=1,5 do
    if key[teeth - i] then
      displacements[i] = key[teeth - i]
    else
      displacements[i] = 0
    end
  end
end


function play:draw()
  for i=1,5 do
    local x = 10 + 15 * (i - 1)
    local y = 40 - displacements[i] * 5
    if i == selection_index then
      love.graphics.setColor(0, 255, 255)
    else
      love.graphics.setColor(255, 255, 255)
    end
    love.graphics.rectangle(
      'fill',
      x,
      y,
      10,
      40
    )
    love.graphics.setColor(0, 0, 255)
    love.graphics.rectangle(
      'fill',
      x,
      y,
      10,
      key[6 - i] * 5 + 5 * player_offsets[i]
    )
  end

  love.graphics.setColor(0, 255, 0)
  local points = {}
  local dx = 0
  for i=1,20 do
    local t = ((teeth - i - 1) % #key) + 1
    table.insert(points, 15 + 15 * (i - 1))
    table.insert(points, 85 - key[t] * 5)
  end

  love.graphics.line(points)

  love.graphics.setColor(255, 0, 0)
  love.graphics.line(10, 40, 80, 40)

  --[[
  love.graphics.rectangle('fill', 25, 10, 10, 40)
  love.graphics.rectangle('fill', 40, 10, 10, 40)
  love.graphics.rectangle('fill', 55, 10, 10, 40)
  love.graphics.rectangle('fill', 70, 10, 10, 40)
  ]]
end

return play