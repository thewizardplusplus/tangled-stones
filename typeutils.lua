---
-- @module typeutils

local json = require("json")
local jsonschema = require("jsonschema")
local assertions = require("luatypechecks.assertions")

local typeutils = {}

---
-- @tparam string path
-- @tparam tab schema JSON Schema
-- @treturn tab
-- @error error message
function typeutils.load_json(path, schema)
  assertions.is_string(path)
  assertions.is_table(schema)

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
-- @tparam func handler func(): any; function that raises an error
-- @tparam[opt] {any,...} ... handler arguments
-- @treturn any successful handler result
-- @error raised handler error
function typeutils._catch_error(handler, ...)
  assertions.is_function(handler)

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
