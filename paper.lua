local paper = {}

local total_time = 0
local progress = 0

function paper:update(dt)
  total_time = total_time + dt

  if total_time > TOOTH_DT then
    total_time = total_time - TOOTH_DT
  end

  progress = (total_time % TOOTH_DT) / TOOTH_DT
end


function paper:draw()
  -- grid lines
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

  -- shear line
  love.graphics.setColor(88, 86, 131)
  love.graphics.setLineWidth(4)
  love.graphics.line(
    0, SCREEN_PADDING + PIN_HEIGHT - PIN_DY,
    SCREEN_WIDTH, SCREEN_PADDING + PIN_HEIGHT - PIN_DY
  )
end


return paper