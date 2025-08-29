-- luacheck: no max comment line length

---
-- @module jsonutils

local assertions = require("luatypechecks.assertions")
local checks = require("luatypechecks.checks")
local json = require("luaserialization.json")

local jsonutils = {}

---
-- @tparam string path
-- @tparam any value
-- @treturn bool
-- @error error message
function jsonutils.save_to_json(path, value)
  assertions.is_string(path)

  local data, err = json.to_json(value)
  if not data then
    return false, "unable to serialize data: " .. err
  end

  local ok, err = love.filesystem.write(path, data) -- luacheck: no redefined
  if not ok then
    return false, "unable to write data: " .. err
  end

  return true
end

---
-- @tparam string path
-- @tparam tab schema JSON Schema
-- @tparam[optchain] {[string]=func,...} constructors constructors for tables with the `__name` property; the values should be `func(options: tab): tab`; the constructor can either return an error as the second result or throw it as an exception
-- @treturn any
-- @error error message
function jsonutils.load_from_json(path, schema, constructors)
  assertions.is_string(path)
  assertions.is_table(schema)
  assertions.is_table_or_nil(constructors, checks.is_string, checks.is_callable)

  local data_in_json, err = love.filesystem.read(path)
  if not data_in_json then
    return nil, "unable to read data: " .. err
  end

  local data, err = json.from_json(data_in_json, schema, constructors) -- luacheck: no redefined
  if not data then
    return nil, "unable to parse data: " .. err
  end

  return data
end

return jsonutils
