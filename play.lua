local state_manager = require 'state_manager'
local play = state_manager:register('play')

local SimpleQueue = require 'simple_queue'
local timer_obj = require 'timer'
local gui = require 'gui_overlay'
local paper = require 'paper'

local stages = {
  {
    key = {0, 0, 0, 0, 0},
    pins = {true, true, true, true, true},
  },
  {
    key = {2, 1, 3, 2, 2},
    pins = {false, true, true},
  },
  {
    key = {3, 5, 1, 4, 2},
    pins = {false, true, true, true},
  },
  {
    key = {4, 1, 4, 4, 1},
    pins = {true, true, true, true},
  },
  {
    key = {4, 1, 4, 4, 1},
    pins = {true, true, true, true},
  },
  {
    key = {4, 1, 4, 4, 1},
    pins = {true, true, true, true},
  },
  {
    key = {4, 1, 4, 4, 1},
    pins = {true, true, true, true},
  },
  {
    key = {4, 1, 4, 4, 1},
    pins = {true, true, true, true},
  }
}
gui.stages = stages
local displacements = {0, 0, 0, 0, 0}
local player_offsets = {0, 0, 0, 0, 0}
local total_time = 0
local teeth = 0
local rest_time = 3
local frac = 0
local point_queue = create(SimpleQueue)
local points = {}
local current_stage = 3

local key = stages[current_stage].key
local pins = stages[current_stage].pins

function first_true(arr)
  for i=1,#arr do
    if arr[i] then
      return i
    end
  end
  return nil
end

local selection_index = first_true(pins)


function play:reset()
  points = {}
  displacements = {0, 0, 0, 0, 0}
  player_offsets = {0, 0, 0, 0, 0}

  timer_obj:init(stages, current_stage)
  point_queue:init()

  key = stages[current_stage].key
  pins = stages[current_stage].pins
  supply_points()

  for i=1,#key+2 do
    table.insert(points, 0)
  end
end


function play:enter()
  self:reset()
end


function play:switch_stage(di)
  current_stage = current_stage + di
end


function supply_points()
  for i=1, rest_time do
    point_queue:add(0)
  end

  for i=1,#key do
    point_queue:add(key[i])
  end
end


function play:keyreleased(k)
  local index_offset = first_true(pins) - 1
  local pin_count = #pins - index_offset

  if k == 'left' then
    selection_index = ((pin_count + selection_index - 2 - index_offset) % pin_count) + 1 + index_offset
  elseif k == 'right' then
    selection_index = ((selection_index - index_offset) % pin_count) + 1 + index_offset
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

  timer_obj:update(dt)
  paper:update(dt)
  gui:update(dt)

  if timer_obj.current_time <= 0 then
    state_manager:switch('slide')
    gui:move_back()
  end

  if total_time > TOOTH_DT then
    total_time = total_time - TOOTH_DT

    points[#points] = nil
    table.insert(points, 1, point_queue:pop())

    if point_queue:size() < #key then
      supply_points()
    end
  end

  teeth = math.floor(total_time / TOOTH_DT)
  frac = (total_time % TOOTH_DT) / TOOTH_DT

  local size = #key + rest_time
  local next

  for i=1,#key do
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


function play:draw_contents()
  local x, y = 0, 0

  love.graphics.push()
  love.graphics.translate(120, 0)

  -- lock innards
  -- intentional harcoding
  love.graphics.setColor(194, 184, 89)
  for i=1,6 do
    love.graphics.rectangle(
      'fill',
      10 + PIN_SPACING * (i - 1) - FILLER_SPACING - FILLER_WIDTH, SCREEN_PADDING,
      FILLER_WIDTH, FILLER_HEIGHT
    )
  end

  -- springs
  for i=1,#pins do
    if pins[i] then
      local stretch = PIN_HEIGHT - displacements[i] * PIN_DY - RESTING_PIN_OFFSET
      local x_offset = 10 + PIN_SPACING * (i - 1)
      for j=1,5 do
        -- draw each segment of the spring
        love.graphics.setColor(124, 112, 39)
        love.graphics.setLineWidth(4)
        love.graphics.line(
          x_offset, SCREEN_PADDING + (j - 1) * (10 + stretch) / 5,
          x_offset + PIN_WIDTH, SCREEN_PADDING + (j - 0.5) * (10 + stretch) / 5
        )

        love.graphics.setColor(94, 82, 9)
        love.graphics.setLineWidth(3)
        love.graphics.line(
          x_offset + PIN_WIDTH, SCREEN_PADDING + (j - 0.5) * (10 + stretch) / 5,
          x_offset, SCREEN_PADDING + j * (10 + stretch) / 5
        )
      end
    end
  end

  -- EKG line
  love.graphics.setColor(255, 0, 0)
  love.graphics.setLineWidth(2)
  local ekg_points = {}
  local val, peak
  for i=-3,#points do
    x = 10 + PIN_WIDTH / 2 + PIN_SPACING * (i - 1) + frac * PIN_SPACING
    table.insert(ekg_points, x)

    if i <= -3 then
      val = 0
    elseif i <= 0 then
      val = point_queue:peek(1 - i) or 0
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
    if i < 0 then
      peak = math.max(val, point_queue:peek(-i) or 0)
    else
      peak = math.max(val, points[i + 1] or 0)
    end

    table.insert(
      ekg_points,
      SCREEN_PADDING + PIN_WIDTH / 2 + 5 * PIN_SPACING - (peak > 0 and peak + 0.5 or 0) * PIN_DY - RESTING_PIN_OFFSET
    )
  end

  love.graphics.line(ekg_points)

  -- pins
  for i=1,#pins do
    if pins[i] then
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
      local dy = key[#key + 1 - i] * PIN_DY + PIN_DY * player_offsets[i]
      love.graphics.line(
        x, y + dy,
        x + PIN_WIDTH, y + dy
      )
      love.graphics.setBlendMode('alpha')
    end
  end

  love.graphics.pop()
end


function play:draw()
  paper:draw()
  self:draw_contents()
  gui:draw()
end

return play
