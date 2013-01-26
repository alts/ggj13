local state_manager = require 'state_manager'
local play = state_manager:register('play')

local key = {1, 5, 3, 2, 1}
local displacements = {0, 0, 0, 0, 0}
local tooth_dt = 0.5
local total_time = 0
local teeth = 0

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
    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle(
      'fill',
      x,
      y,
      10,
      40
    )
    love.graphics.setColor(0, 0, 255)
    if i == 3 then
      love.graphics.rectangle(
        'fill',
        x,
        y,
        10,
        key[6 - i] * 5 + 10
      )
    else
      love.graphics.rectangle(
        'fill',
        x,
        y,
        10,
        key[6 - i] * 5
      )
    end
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