local image_bank = {
  cache = {}
}

local function get(self, path)
  if self.cache[path] == nil then
    self.cache[path] = love.graphics.newImage(path)
  end

  return self.cache[path]
end

image_bank.get = get
return image_bank