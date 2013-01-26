function create(obj)
  new_obj = {}
  setmetatable(new_obj, obj)
  obj.__index = obj
  return new_obj
end

clone = create