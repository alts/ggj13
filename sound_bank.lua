local sound_bank = {
  cache = {}
}

local function get(self, path)
  if self.cache[path] == nil then
    self.cache[path] = love.audio.newSource(path, 'static')
  end

  return self.cache[path]
end

sound_bank.get = get
return sound_bank