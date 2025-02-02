-- luacheck: no max comment line length

---
-- @module json

local data_module = require("luaserialization.data")
local json_module = require("json")
local checks = require("luatypechecks.checks")
local assertions = require("luatypechecks.assertions")
local jsonschema = require("jsonschema")
local _ENV = require("compat53.module")
if _VERSION == "Lua 5.1" then
  setfenv(1, _ENV)
end

local json = {}

--- ⚠️. This function gets the value data with the @{data.to_data|data.to_data()} function. Then the function transforms this data into the JSON.
-- @tparam any value
-- @treturn string
-- @error error message
function json.to_json(value)
  local data = data_module.to_data(value)
  local encoded_data, err = json._catch_error(json_module.encode, data)
  if err ~= nil then
    return nil, "unable to encode the data: " .. err
  end

  return encoded_data
end

--- ⚠️. This function serializes the passed value to the JSON with the @{json.to_json|json.to_json()} function and saves the result to the file at the specified path via the file writer.
-- @tparam string path
-- @tparam any value
-- @tparam[opt] func file_writer callback for saving the JSON; the value should be `func(path: string, data: string): (bool|nil, error|nil)`; the default implementation uses the standard `io` package
-- @treturn bool
-- @error error message
function json.save_to_json(path, value, file_writer)
  file_writer = file_writer or json._write_file_by_default

  assertions.is_string(path)
  assertions.is_function(file_writer)

  local data, err = json.to_json(value)
  if err ~= nil then
    return nil, "unable to serialize the value: " .. err
  end

  local _, err = file_writer(path, data) -- luacheck: no redefined
  if err ~= nil then
    return nil, "unable to write the serialized value: " .. err
  end

  return true
end

--- ⚠️. This function transforms the text in the JSON to a data.
-- @tparam string text
-- @tparam[opt] tab schema JSON Schema
-- @tparam[optchain] {[string]=func,...} constructors constructors for tables with the `__name` property; the values should be `func(options: tab): tab`; the constructor can either return an error as the second result or throw it as an exception
-- @treturn any
-- @error error message
function json.from_json(text, schema, constructors)
  assertions.is_string(text)
  assertions.is_table_or_nil(schema)
  assertions.is_table_or_nil(constructors, checks.is_string, checks.is_callable)

  local decoded_data, err = json._catch_error(json_module.decode, text)
  if err ~= nil then
    return nil, "unable to decode the data: " .. err
  end

  if schema ~= nil then
    local validator, err = json._catch_error( -- luacheck: no redefined
      jsonschema.generate_validator,
      schema
    )
    if err ~= nil then
      return nil, "unable to generate the validator: " .. err
    end

    local _, err = validator(decoded_data) -- luacheck: no redefined
    if err ~= nil then
      return nil, "invalid data: " .. err
    end
  end

  if constructors ~= nil then
    decoded_data, err = json._apply_constructors(decoded_data, constructors)
    if err ~= nil then
      return nil, "unable to apply the constructors: " .. err
    end
  end

  return decoded_data
end

--- ⚠️. This function loads the JSON via the file reader and transforms it to a data with the @{json.from_json|json.from_json()} function.
-- @tparam string path
-- @tparam[opt] tab schema JSON Schema
-- @tparam[optchain] {[string]=func,...} constructors constructors for tables with the `__name` property; the values should be `func(options: tab): tab`; the constructor can either return an error as the second result or throw it as an exception
-- @tparam[optchain] func file_reader callback for loading the JSON; the value should be `func(path: string): (string|nil, error|nil)`; the default implementation uses the standard `io` package
-- @treturn any
-- @error error message
function json.load_from_json(path, schema, constructors, file_reader)
  file_reader = file_reader or json._read_file_by_default

  assertions.is_string(path)
  assertions.is_table_or_nil(schema)
  assertions.is_table_or_nil(constructors, checks.is_string, checks.is_callable)
  assertions.is_function(file_reader)

  local text, err = file_reader(path)
  if err ~= nil then
    return nil, "unable to read the text: " .. err
  end

  local data, err = json.from_json(text, schema, constructors) -- luacheck: no redefined
  if err ~= nil then
    return nil, "unable to transform the data: " .. err
  end

  return data
end

function json._catch_error(handler, ...)
  assertions.is_function(handler)

  local arguments = table.pack(...)
  local ok, result, err = pcall(function()
    return handler(table.unpack(arguments, 1, arguments.n))
  end)
  if not ok then
    return nil, result
  end
  if err ~= nil then
    return nil, err
  end

  return result
end

function json._write_file_by_default(path, data)
  assertions.is_string(path)
  assertions.is_string(data)

  local file, err = io.open(path, "w")
  if err ~= nil then
    return nil, "unable to open the file: " .. err
  end

  local _, writingErr = file:write(data)
  local wrappedWritingErr =
    writingErr and ("unable to write the data to the file: " .. writingErr)

  local _, closingErr = file:close()
  local wrappedClosingErr =
    closingErr and ("unable to close the file: " .. closingErr)

  if wrappedWritingErr ~= nil then
    return nil, wrappedClosingErr
      and table.concat({wrappedWritingErr, wrappedClosingErr}, "\n")
      or wrappedWritingErr
  end
  if wrappedClosingErr ~= nil then
    return nil, wrappedClosingErr
  end

  return true
end

function json._read_file_by_default(path)
  assertions.is_string(path)

  local file, err = io.open(path, "r")
  if err ~= nil then
    return nil, "unable to open the file: " .. err
  end

  local data, readingErr = file:read("*a")
  local wrappedReadingErr =
    readingErr and ("unable to read the data from the file: " .. readingErr)

  local _, closingErr = file:close()
  local wrappedClosingErr =
    closingErr and ("unable to close the file: " .. closingErr)

  if wrappedReadingErr ~= nil then
    return nil, wrappedClosingErr
      and table.concat({wrappedReadingErr, wrappedClosingErr}, "\n")
      or wrappedReadingErr
  end
  if wrappedClosingErr ~= nil then
    return nil, wrappedClosingErr
  end

  return data
end

function json._apply_constructors(value, constructors)
  assertions.is_table(constructors, checks.is_string, checks.is_callable)

  if not checks.is_table(value) then
    return value
  end

  local transformed_value = {}
  for key, value in pairs(value) do -- luacheck: no redefined
    local err
    transformed_value[key], err = json._apply_constructors(value, constructors)
    if err ~= nil then
      return nil, "unable to apply the constructors: " .. err
    end
  end

  if not checks.is_sequence(transformed_value)
    and checks.has_properties(transformed_value, {"__name"})
    and checks.has_properties(constructors, {transformed_value.__name}) then
    local err
    local constructor = constructors[transformed_value.__name]
    transformed_value, err = json._catch_error(constructor, transformed_value)
    if err ~= nil then
      return nil, "unable to call the constructor: " .. err
    end
  end

  return transformed_value
end

return json
