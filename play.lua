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
local rest_time = 3
local frac = 0
local point_queue = create(SimpleQueue)
local points = {}


function play:enter()
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

  for i=1,#displacements do
    next = points[i - 1] or point_queue:peek()
    if frac > 0.5 then
      displacements[i] = next
    elseif frac > 0.25 then
      local peak = math.max(next, points[i])
      if peak > 0 then
        peak = peak + 0.5
      end
      displacements[i] = peak + (frac - 0.25) / 0.25 * (next - peak)
    else
      local peak = math.max(next, points[i])
      if peak > 0 then
        peak = peak + 0.5
      end
      displacements[i] = points[i] + frac / 0.25 * (peak - points[i])
    end
  end
end


function play:draw()
  local x, y = 0, 0

  -- lock innards
  love.graphics.setColor(194, 184, 89)
  for i=1,#key do
    love.graphics.rectangle(
      'fill',
      10 + PIN_SPACING * (i - 1) - FILLER_SPACING - FILLER_WIDTH, SCREEN_PADDING,
      FILLER_WIDTH, FILLER_HEIGHT
    )
  end

  -- springs
  love.graphics.setColor(124, 112, 39)
  love.graphics.setLineWidth(4)
  for i=1,#key do
    local stretch = PIN_HEIGHT - displacements[i] * PIN_DY - RESTING_PIN_OFFSET
    for j=1,5 do
      -- draw each segment of the spring
      love.graphics.line(
        10 + PIN_SPACING * (i - 1), SCREEN_PADDING + (j - 1) * (10 + stretch) / 5,
        10 + PIN_SPACING * (i - 1) + PIN_WIDTH, SCREEN_PADDING + (j - 0.5) * (10 + stretch) / 5
      )
    end
  end


  -- shear line
  love.graphics.setColor(88, 86, 131)
  love.graphics.setLineWidth(4)
  love.graphics.line(
    0, SCREEN_PADDING + PIN_HEIGHT - PIN_DY,
    PIN_SPACING * 5, SCREEN_PADDING + PIN_HEIGHT - PIN_DY
  )

  -- EKG line
  love.graphics.setColor(255, 0, 0)
  love.graphics.setLineWidth(5)
  local ekg_points = {}
  local val, peak
  for i=0,#points do
    x = 10 + PIN_WIDTH / 2 + PIN_SPACING * (i - 1) + frac * PIN_SPACING
    table.insert(
      ekg_points,
      x
    )

    if i == 0 then
      val = point_queue:peek()
    else
      val = points[i]
    end

    y = SCREEN_PADDING + PIN_WIDTH / 2 + 5 * PIN_SPACING - val * PIN_DY - RESTING_PIN_OFFSET
    table.insert(ekg_points, y)

    table.insert(ekg_points, x + PIN_SPACING/4)
    table.insert(ekg_points, y)

    table.insert(ekg_points, x + PIN_SPACING/2)
    table.insert(ekg_points, y)

    table.insert(ekg_points, x + 3 * PIN_SPACING/4)
    peak = math.max(val, points[i + 1] or 0)
    table.insert(ekg_points, SCREEN_PADDING + PIN_WIDTH / 2 + 5 * PIN_SPACING - (peak > 0 and peak + 0.5 or 0) * PIN_DY - RESTING_PIN_OFFSET)
  end

  love.graphics.line(ekg_points)

  -- pins
  for i=1,5 do
    x = 10 + PIN_SPACING * (i - 1)
    y = SCREEN_PADDING + PIN_HEIGHT - displacements[i] * PIN_DY - RESTING_PIN_OFFSET
    if i == selection_index then
      love.graphics.setColor(150, 140, 46)
    else
      love.graphics.setColor(190, 180, 86)
    end

    local poly_points = {
      x, y,
      x + PIN_WIDTH, y,
      x + PIN_WIDTH, y + PIN_HEIGHT - PIN_WIDTH / 2,
      x + PIN_WIDTH / 2, y + PIN_HEIGHT,
      x, y + PIN_HEIGHT - PIN_WIDTH / 2
    }


    love.graphics.polygon('fill', poly_points)
    love.graphics.setColor(143, 127, 32)
    love.graphics.setLineWidth(2)
    love.graphics.polygon('line', poly_points)

    love.graphics.setColor(0, 0, 255)
    love.graphics.setLineWidth(4)
    love.graphics.setBlendMode('multiplicative')
    local dy = key[6 - i] * PIN_DY + PIN_DY * player_offsets[i]
    love.graphics.line(
      x, y + dy,
      x + PIN_WIDTH, y + dy
    )
    love.graphics.setBlendMode('alpha')
  end
end

return play
