---
-- @module typeutils

local json = require("json")
local jsonschema = require("jsonschema")

local typeutils = {}

---
-- @tparam any value
-- @tparam[opt=math.huge] number limit [0, ∞)
-- @treturn bool
function typeutils.is_positive_number(value, limit)
  limit = limit or math.huge

  assert(type(limit) == "number" and limit >= 0)

  return type(value) == "number" and value >= 0 and value <= limit
end

---
-- @tparam any value
-- @treturn bool
function typeutils.is_callable(value)
  if type(value) == "function" then
    return true
  end

  return typeutils._has_metamethod(value, "__call")
end

---
-- @tparam any value
-- @tparam tab class class created via the middleclass library
-- @treturn bool
function typeutils.is_instance(value, class)
  assert(type(class) == "table")

  return type(value) == "table"
    and typeutils.is_callable(value.isInstanceOf)
    and value:isInstanceOf(class)
end

---
-- @tparam string path
-- @tparam tab schema JSON Schema
-- @treturn tab
-- @error error message
function typeutils.load_json(path, schema)
  assert(type(path) == "string")
  assert(type(schema) == "table")

  local data_in_json, reading_err = love.filesystem.read(path)
  if not data_in_json then
    return nil, "unable to read data: " .. reading_err
  end

  local data, decoding_err = typeutils._catch_error(json.decode, data_in_json)
  if not data then
    return nil, "unable to parse data: " .. decoding_err
  end

  local data_validator, generation_err =
    typeutils._catch_error(jsonschema.generate_validator, schema)
  if not data_validator then
    return nil, "unable to generate the validator: " .. generation_err
  end

  local ok, validation_err = data_validator(data)
  if not ok then
    return nil, "incorrect data: " .. validation_err
  end

  return data
end

---
-- @tparam any value
-- @tparam string metamethod
-- @treturn bool
function typeutils._has_metamethod(value, metamethod)
  assert(type(metamethod) == "string")

  local metatable = getmetatable(value)
  return metatable and typeutils.is_callable(metatable[metamethod])
end

---
-- @tparam func handler func(): any; function that raises an error
-- @tparam[opt] {any,...} ... handler arguments
-- @treturn any successful handler result
-- @error raised handler error
function typeutils._catch_error(handler, ...)
  assert(type(handler) == "function")

  local arguments = table.pack(...)
  local ok, result = pcall(function()
    return handler(table.unpack(arguments))
  end)
  if not ok then
    return nil, result
  end

  return result
end

return typeutils
