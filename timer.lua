local timer = {}
local max_time = 1

function timer:init(stages, stage_index)
  self.failures = {}
  for i=1, #stages do
    table.insert(self.failures, 0)
  end

  self.current_stage = stage_index
  self.current_time = max_time
end


function timer:update(dt)
  self.current_time = self.current_time - dt
end


function timer:percent_remaining()
  local failures = self.failures[self.current_stage]
  return math.max(0, self.current_time * (failures + 1)/ max_time)
end


return timer