-- luacheck: no max comment line length

---
-- @classmod SettingsStorage

local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")
local json = require("luaserialization.json")
local GameSettings = require("models.gamesettings")

---
-- @table instance
-- @tfield string _path
-- @tfield GameSettings _settings

local SettingsStorage = middleclass("SettingsStorage")

---
-- @function new
-- @tparam string path
-- @treturn SettingsStorage
function SettingsStorage:initialize(path)
  assertions.is_string(path)

  local settings, err = json.load_from_json(
    path,
    GameSettings.schema(),
    { GameSettings = GameSettings.from_options },
    function(path) -- luacheck: no redefined
      assertions.is_string(path)

      -- `love.js` crashes when reading a non-existent file, so check it first
      -- (see https://github.com/Davidobot/love.js#notes, item 6)
      if love.filesystem.getInfo(path, "file") == nil then
        return nil, "file does not exist"
      end

      local data, err = love.filesystem.read(path)
      return data, data == nil and err or nil
    end
  )
  if not settings then
    print("unable to load the settings: " .. err)

    settings = GameSettings:new(5, false)
  end

  self._path = path
  self._settings = settings
end

---
-- @treturn GameSettings
function SettingsStorage:settings()
  return self._settings
end

---
-- @function save
function SettingsStorage:save()
  local ok, err =
    json.save_to_json(self._path, self._settings, love.filesystem.write)
  if not ok then
    print("unable to save the settings: " .. err)
  end
end

return SettingsStorage
