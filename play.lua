local state_manager = require 'state_manager'
local play = state_manager:register('play')

local SimpleQueue = require 'simple_queue'
local timer_obj = require 'timer'
local gui = require 'gui_overlay'
local paper = require 'paper'
local gradient = require 'gradient'
local image_bank = require 'image_bank'
local sound_bank = require 'sound_bank'

local stages = {
  {
    key = {0, 0, 0, 0, 0},
    pins = {true, true, true, true, true},
    rest_period = 5,
  },
  {
    key = {2, 3, 4, 2, 1},
    pins = {false, true, true},
    rest_period = 3,
  },
  {
    key = {2, 1, 3, 2, 2},
    pins = {false, true, true, true},
    rest_period = 3,
  },
  {
    key = {3, 5, 1, 4, 2},
    pins = {false, true, true, true},
    rest_period = 3,
  },
  {
    key = {4, 1, 4, 4, 1},
    pins = {true, true, true, true},
    rest_period = 2,
  },
  {
    key = {2, 1, 4, 5, 1},
    pins = {true, true, true, true},
    rest_period = 2,
  },
  {
    key = {4, 3, 5, 1, 2},
    pins = {true, true, true, true, true},
    rest_period = 1
  },
  {
    key = {5, 1, 4, 2, 5},
    pins = {true, true, true, true, true},
    rest_period = 1,
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
local current_stage = 2
local winning = false
local winning_timer = 2
local losing_timer = 3

local pin_img = image_bank:get('assets/tumbler.png')

local lock = gradient.vertical(
  {
    {154, 139, 51},
    {154, 139, 51},
    {194, 184, 89},
    {194, 184, 89}
  },
  FILLER_HEIGHT
)

local key = stages[current_stage].key
local pins = stages[current_stage].pins
local rest_time = stages[current_stage].rest_period

function first_true(arr)
  for i=1,#arr do
    if arr[i] then
      return i
    end
  end
  return nil
end

local selection_index = first_true(pins)


function flat_win()
  for i=1,#pins do
    if pins[i] and player_offsets[i] ~= 1 then
      return false
    end
  end

  return true
end


function puzzle_success()
  if flat_win() then
    return false
  end

  for i=1,#pins do
    if pins[i] then
      if i > 1 then
        if player_offsets[i] - 1 ~= points[i - 1] then
          return false
        end
      else
        if player_offsets[i] - 1 ~= point_queue:peek() then
          return false
        end
      end
    end
  end

  return true
end


function play:start_over()
  current_stage = #stages
  losing_timer = 3
  self:reset()
  gui:start_over()
end


function play:reset()
  winning = false
  winning_timer = 2

  points = {}
  displacements = {0, 0, 0, 0, 0}
  player_offsets = {0, 0, 0, 0, 0}

  timer_obj:init(stages, current_stage)
  point_queue:init()

  key = stages[current_stage].key
  pins = stages[current_stage].pins
  rest_time = stages[current_stage].rest_period

  supply_points()

  for i=1,#key+2 do
    table.insert(points, 0)
  end
end


function play:enter()
  love.audio.stop(sound_bank:get('assets/heartbeat.mp3'))
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
  state_manager:switch('win')

  local index_offset = first_true(pins) - 1
  local pin_count = #pins - index_offset

  if current_stage == 1 then
    if k == 'kpenter' or k == 'return' then
      self:start_over()
    end
  end

  if k == 'left' then
    selection_index = ((pin_count + selection_index - 2 - index_offset) % pin_count) + 1 + index_offset
  elseif k == 'right' then
    selection_index = ((selection_index - index_offset) % pin_count) + 1 + index_offset
  elseif k == 'up' then
    if player_offsets[selection_index] > 0 then
      player_offsets[selection_index] = player_offsets[selection_index] - 1
    end
  elseif k == 'down' then
    if player_offsets[selection_index] < PIN_HEIGHT/PIN_DY - 2 then
      player_offsets[selection_index] = player_offsets[selection_index] + 1
    end
  end
end


function play:update(dt)
  paper:update(dt)

  if winning then
    winning_timer = winning_timer - dt
    if winning_timer <= 0 then
      winning = false
      paper.winning = false
      points[#points] = 0

      if current_stage == #stages then
        state_manager:switch('win')
      else
        gui:move_forward()
        state_manager:switch('slide_forward')
      end
    end

    return
  end

  total_time = total_time + dt

  if current_stage > 1 then
    timer_obj:update(dt)
  else
    losing_timer = losing_timer - dt
  end

  gui:update(dt)

  if losing_timer <= 0 then
    losing_timer = 3
    state_manager:switch('lose')
  end

  if timer_obj.current_time <= 0 then
    if current_stage == 2 then
      sound_bank:get('assets/approach_flatline.mp3'):play()
    end

    state_manager:switch('slide')
    gui:move_back()
  end

  if total_time > TOOTH_DT then

    if puzzle_success() then
      winning = true
      paper.winning = true
      return
    end

    total_time = total_time - TOOTH_DT

    points[#points] = nil
    table.insert(points, 1, point_queue:pop())

    if point_queue:size() < #key then
      supply_points()
    end
  end

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
  love.graphics.setColor(255, 255, 255)
  for i=1,6 do
    love.graphics.draw(
      lock,
      10 + PIN_SPACING * (i - 1) - FILLER_SPACING - FILLER_WIDTH, SCREEN_PADDING,
      0,
      FILLER_WIDTH, 1
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
  love.graphics.setBlendMode('multiplicative')
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
  love.graphics.setBlendMode('alpha')

  -- pins
  for i=1,#pins do
    if pins[i] then
      x = 10 + PIN_SPACING * (i - 1)
      y = SCREEN_PADDING + PIN_HEIGHT - displacements[i] * PIN_DY - RESTING_PIN_OFFSET

      love.graphics.setColor(255, 255, 255)
      love.graphics.draw(
        pin_img,
        x, y
      )

      if i == selection_index then
        love.graphics.setBlendMode('additive')
        love.graphics.setColor(100, 100, 80)
        love.graphics.draw(
          pin_img,
          x, y
        )
        love.graphics.setBlendMode('alpha')
      end

      love.graphics.setLineWidth(4)
      if winning and winning_timer % 1 < 0.5 then
        love.graphics.setColor(0, 255, 0)
        love.graphics.setBlendMode('alpha')
      else
        love.graphics.setColor(0, 0, 255)
        love.graphics.setBlendMode('multiplicative')
      end
      local dy = PIN_DY * (player_offsets[i] + 1)
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
