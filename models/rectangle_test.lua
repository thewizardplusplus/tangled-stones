local luaunit = require("luaunit")
local Rectangle = require("models.rectangle")

-- luacheck: globals TestRectangle
TestRectangle = {}

function TestRectangle.test_tostring()
  local settings = Rectangle:new(10, 20, 30, 40)
  local text = tostring(settings)

  luaunit.assert_is_string(text)
  luaunit.assert_equals(text, "{" ..
    "__name = \"Rectangle\"," ..
    "height = 40," ..
    "width = 30," ..
    "x = 10," ..
    "y = 20" ..
  "}")
end
