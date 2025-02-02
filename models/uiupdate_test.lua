local luaunit = require("luaunit")
local UiUpdate = require("models.uiupdate")

-- luacheck: globals TestUiUpdate
TestUiUpdate = {}

function TestUiUpdate.test_tostring()
  local settings = UiUpdate:new(true)
  local text = tostring(settings)

  luaunit.assert_is_string(text)
  luaunit.assert_equals(text, "{__name = \"UiUpdate\",reset = true}")
end
