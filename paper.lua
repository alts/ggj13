local paper = {
  winning = false
}

local total_time = 0
local progress = 0
local winning_timer = 3

function paper:update(dt)
  if self.winning then
    winning_timer = winning_timer - dt
    return
  end

  total_time = total_time + dt

  if total_time > TOOTH_DT then
    total_time = total_time - TOOTH_DT
  end

  progress = (total_time % TOOTH_DT) / TOOTH_DT
end

function paper:draw_background()
  love.graphics.setColor(214, 227, 218)
  love.graphics.setLineWidth(2)
  for i=1,SCREEN_HEIGHT / PIN_DY do
    love.graphics.line(
      0, (i - 1) * PIN_DY - 10,
      SCREEN_WIDTH, (i - 1) * PIN_DY - 10
    )
  end

  for i=-1,SCREEN_WIDTH / PIN_DY do
    love.graphics.line(
      (i-1) * PIN_DY + progress * PIN_SPACING, 0,
      (i-1) * PIN_DY + progress * PIN_SPACING, SCREEN_HEIGHT
    )
  end
end

function paper:draw_shear()
  if self.winning and winning_timer % 1 < 0.5 then
    love.graphics.setColor(0, 255, 0)
  else
    love.graphics.setColor(88, 86, 131)
  end
  love.graphics.setLineWidth(4)
  love.graphics.line(
    0, SCREEN_PADDING + PIN_HEIGHT - PIN_DY,
    SCREEN_WIDTH, SCREEN_PADDING + PIN_HEIGHT - PIN_DY
  )
end

function paper:draw(hide_shear)
  self:draw_background()
  self:draw_shear()
end


return paper