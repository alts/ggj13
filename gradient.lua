local gradient = {}

function gradient.vertical(colors, height)
  local data = love.image.newImageData(1, height)
  local segment_size = height / (#colors - 1)
  local index = 0
  local fractional = 0
  for i=0,height-1 do
    index = math.floor(i / segment_size) + 1
    fractional = (i % segment_size) / segment_size
    data:setPixel(
      0, i,
      colors[index][1] + (colors[index+1][1] - colors[index][1]) * fractional,
      colors[index][2] + (colors[index+1][2] - colors[index][2]) * fractional,
      colors[index][3] + (colors[index+1][3] - colors[index][3]) * fractional,
      255
    )
  end

  local image = love.graphics.newImage(data)
  image:setFilter('linear', 'linear')
  return image
end

return gradient