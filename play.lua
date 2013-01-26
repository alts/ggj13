local state_manager = require 'state_manager'
local play = state_manager:register('play')

local SimpleQueue = require 'simple_queue'

local key = {3, 5, 1, 4, 2}
local displacements = {0, 0, 0, 0, 0}
local player_offsets = {0, 0, 0, 0, 0}
local selection_index = 1
local tooth_dt = 0.6
local total_time = 0
local teeth = 0
local rest_time = 5
local frac = 0
local point_queue = create(SimpleQueue)
local points = {}


function play:enter()
  print('wat')
  point_queue:init()
  supply_points()

  for i=1,#key do
    table.insert(points, 0)
  end
end


function supply_points()
  for i=1,#key do
    point_queue:add(key[i])
  end

  for i=1, rest_time do
    point_queue:add(0)
  end
end


function play:keyreleased(k)
  if k == 'left' then
    selection_index = ((#key + selection_index - 2) % #key) + 1
  elseif k == 'right' then
    selection_index = (selection_index % #key) + 1
  elseif k == 'up' then
    if player_offsets[selection_index] + key[#key - selection_index + 1] > 1 then
      player_offsets[selection_index] = player_offsets[selection_index] - 1
    end
  elseif k == 'down' then
    if player_offsets[selection_index] + key[#key - selection_index + 1] < PIN_HEIGHT/PIN_DY - 1 then
      player_offsets[selection_index] = player_offsets[selection_index] + 1
    end
  end
end


function play:update(dt)
  total_time = total_time + dt

  if total_time > tooth_dt then
    total_time = total_time - tooth_dt

    points[#points] = nil
    table.insert(points, 1, point_queue:pop())

    if point_queue:is_empty() then
      supply_points()
    end
  end

  teeth = math.floor(total_time / tooth_dt)
  frac = (total_time % tooth_dt) / tooth_dt

  local size = #key + rest_time
  local next

  print(inspect(points))
  for i=1,#displacements do
    next = points[i - 1] or point_queue:peek()
    displacements[i] = points[i] + frac * (next - points[i])
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

    love.graphics.polygon(
      'fill',
      x, y,
      x + PIN_WIDTH, y,
      x + PIN_WIDTH, y + PIN_HEIGHT - PIN_WIDTH / 2,
      x + PIN_WIDTH / 2, y + PIN_HEIGHT,
      x, y + PIN_HEIGHT - PIN_WIDTH / 2
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
  local ekg_points = {}
  local val
  for i=0,#points do
    table.insert(
      ekg_points,
      10 + PIN_WIDTH / 2 + PIN_SPACING * (i - 1) + frac * PIN_SPACING
    )
    if i == 0 then
      val = point_queue:peek()
    else
      val = points[i]
    end
    table.insert(
      ekg_points,
      20 + 5 * PIN_SPACING - val * PIN_DY - RESTING_PIN_OFFSET
    )
  end

  love.graphics.line(ekg_points)

  -- shear line
  love.graphics.setColor(255, 0, 0)
  love.graphics.line(
    10, PIN_HEIGHT - PIN_DY,
    10 + PIN_SPACING * 5, PIN_HEIGHT - PIN_DY
  )
end

return play
