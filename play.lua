local state_manager = require 'state_manager'
local play = state_manager:register('play')

local key = {1, 5, 3, 2, 1}
local displacements = {0, 0, 0, 0, 0}
local tooth_dt = 0.2
local total_time = 0
local teeth = 0

function play:update(dt)
  total_time = total_time + dt
  total_time = total_time % 2

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
  love.graphics.setColor(255, 255, 255)
  for i=1,5 do
    love.graphics.rectangle(
      'fill',
      10 + 15 * (i - 1),
      40 - displacements[i] * 5,
      10,
      40
    )
  end

  love.graphics.setColor(0, 255, 0)
  local points = {}
  local dx = 0
  for i=1,20 do
    local t = ((i - teeth - 1) % #key) + 1
    table.insert(points, -50 + 15 * (i - 1))

    if math.floor((i - 1 - teeth) / 5) % 2 == 0 then
      table.insert(points, 80 - key[t] * 5)
    else
      table.insert(points, 80)
    end
  end

  love.graphics.line(points)

  --[[
  love.graphics.rectangle('fill', 25, 10, 10, 40)
  love.graphics.rectangle('fill', 40, 10, 10, 40)
  love.graphics.rectangle('fill', 55, 10, 10, 40)
  love.graphics.rectangle('fill', 70, 10, 10, 40)
  ]]
end

return play