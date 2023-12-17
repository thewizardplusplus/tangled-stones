-- luacheck: no max comment line length

---
-- @module assertions

local checks = require("luatypechecks.checks")

local _ASSERTION_STACK_TRACE_LEVEL = 3

local _assertions_mode = "with_assertions"

local assertions = {}
local _assertions_backup = {}

--- ⚠️. Check if all the package assertions are switched on/off. If an assertion is switched off, it's always successful.
-- @treturn "without_assertions"|"with_assertions"
function assertions.get_assertions_mode()
  return _assertions_mode
end

--- ⚠️. Switch on/off all the package assertions. If an assertion is switched off, it's always successful.
-- @tparam "without_assertions"|"with_assertions" value
function assertions.set_assertions_mode(value)
  assertions.is_assertions_mode(value)

  _assertions_mode = value

  -- switch on/off functions that start with "is_" or "has_"
  for key, value in pairs(_assertions_backup) do -- luacheck: no redefined
    if string.match(key, "^is_") or string.match(key, "^has_") then
      if _assertions_mode == "with_assertions" then
        assertions[key] = value
      else
        assertions[key] = function() end
      end
    end
  end
end

--- ⚠️. Checks that the value is "without\_deep\_checks" or "with\_deep\_checks".
-- @tparam any value
-- @raise "assertion failed!"
function assertions.is_deep_checks_mode(value)
  assertions._assert_with_custom_level(checks.is_deep_checks_mode(value))
end

--- ⚠️. Checks that the value is "without\_deep\_checks", "with\_deep\_checks", or nil.
-- @tparam any value
-- @raise "assertion failed!"
function assertions.is_deep_checks_mode_or_nil(value)
  assertions._assert_with_custom_level(checks.is_deep_checks_mode_or_nil(value))
end

--- ⚠️. Checks that the value is "without\_assertions" or "with\_assertions".
-- @tparam any value
-- @raise "assertion failed!"
function assertions.is_assertions_mode(value)
  assertions._assert_with_custom_level(checks.is_assertions_mode(value))
end

--- ⚠️. Checks that the value is "without\_assertions", "with\_assertions", or nil.
-- @tparam any value
-- @raise "assertion failed!"
function assertions.is_assertions_mode_or_nil(value)
  assertions._assert_with_custom_level(checks.is_assertions_mode_or_nil(value))
end

--- ⚠️. This is a switchable analogue of the @{assert|assert()} function. See the @{set_assertions_mode|set_assertions_mode()} function for details.
-- @tparam any value
-- @raise "assertion failed!"
function assertions.is_true(value)
  assertions._assert_with_custom_level(value)
end

--- ⚠️. This is a switchable analogue of the @{assert|assert()} function with an inverted parameter. See the @{set_assertions_mode|set_assertions_mode()} function for details.
-- @tparam any value
-- @raise "assertion failed!"
function assertions.is_false(value)
  assertions._assert_with_custom_level(not value)
end

---
-- @tparam any value
-- @raise "assertion failed!"
function assertions.is_boolean(value)
  assertions._assert_with_custom_level(checks.is_boolean(value))
end

---
-- @tparam any value
-- @raise "assertion failed!"
function assertions.is_boolean_or_nil(value)
  assertions._assert_with_custom_level(checks.is_boolean_or_nil(value))
end

---
-- @tparam any value
-- @raise "assertion failed!"
function assertions.is_number(value)
  assertions._assert_with_custom_level(checks.is_number(value))
end

---
-- @tparam any value
-- @raise "assertion failed!"
function assertions.is_number_or_nil(value)
  assertions._assert_with_custom_level(checks.is_number_or_nil(value))
end

--- ⚠️. Checks that the value is a number and equals to its integral part. Note that it doesn't use the @{math.type|math.type()} function from Lua 5.3.
-- @tparam any value
-- @raise "assertion failed!"
function assertions.is_integer(value)
  assertions._assert_with_custom_level(checks.is_integer(value))
end

--- ⚠️. Checks that the value is a number and equals to its integral part or is nil. Note that it doesn't use the @{math.type|math.type()} function from Lua 5.3.
-- @tparam any value
-- @raise "assertion failed!"
function assertions.is_integer_or_nil(value)
  assertions._assert_with_custom_level(checks.is_integer_or_nil(value))
end

---
-- @tparam any value
-- @raise "assertion failed!"
function assertions.is_string(value)
  assertions._assert_with_custom_level(checks.is_string(value))
end

---
-- @tparam any value
-- @raise "assertion failed!"
function assertions.is_string_or_nil(value)
  assertions._assert_with_custom_level(checks.is_string_or_nil(value))
end

---
-- @tparam any value
-- @raise "assertion failed!"
function assertions.is_function(value)
  assertions._assert_with_custom_level(checks.is_function(value))
end

---
-- @tparam any value
-- @raise "assertion failed!"
function assertions.is_function_or_nil(value)
  assertions._assert_with_custom_level(checks.is_function_or_nil(value))
end

---
-- @tparam any value
-- @raise "assertion failed!"
function assertions.is_callable(value)
  assertions._assert_with_custom_level(checks.is_callable(value))
end

---
-- @tparam any value
-- @raise "assertion failed!"
function assertions.is_callable_or_nil(value)
  assertions._assert_with_custom_level(checks.is_callable_or_nil(value))
end

---
-- @tparam any value
-- @tparam[opt] func key_checker `func(value: any): bool`
-- @tparam[optchain] func value_checker `func(value: any): bool`
-- @tparam[optchain="with_deep_checks"] "without_deep_checks"|"with_deep_checks" deep_checks_mode ignore or not the key and value checkers
-- @raise "assertion failed!"
function assertions.is_table(
  value,
  key_checker,
  value_checker,
  deep_checks_mode
)
  assertions._assert_with_custom_level(checks.is_table(
    value,
    key_checker,
    value_checker,
    deep_checks_mode
  ))
end

---
-- @tparam any value
-- @tparam[opt] func key_checker `func(value: any): bool`
-- @tparam[optchain] func value_checker `func(value: any): bool`
-- @tparam[optchain="with_deep_checks"] "without_deep_checks"|"with_deep_checks" deep_checks_mode ignore or not the key and value checkers
-- @raise "assertion failed!"
function assertions.is_table_or_nil(
  value,
  key_checker,
  value_checker,
  deep_checks_mode
)
  assertions._assert_with_custom_level(checks.is_table_or_nil(
    value,
    key_checker,
    value_checker,
    deep_checks_mode
  ))
end

---
-- @tparam any value
-- @tparam[opt] func value_checker `func(value: any): bool`
-- @tparam[optchain="with_deep_checks"] "without_deep_checks"|"with_deep_checks" deep_checks_mode ignore or not the value checker
-- @raise "assertion failed!"
function assertions.is_sequence(value, value_checker, deep_checks_mode)
  assertions._assert_with_custom_level(checks.is_sequence(
    value,
    value_checker,
    deep_checks_mode
  ))
end

---
-- @tparam any value
-- @tparam[opt] func value_checker `func(value: any): bool`
-- @tparam[optchain="with_deep_checks"] "without_deep_checks"|"with_deep_checks" deep_checks_mode ignore or not the value checker
-- @raise "assertion failed!"
function assertions.is_sequence_or_nil(value, value_checker, deep_checks_mode)
  assertions._assert_with_custom_level(checks.is_sequence_or_nil(
    value,
    value_checker,
    deep_checks_mode
  ))
end

---
-- @tparam any value
-- @tparam {any,...} enumeration
-- @raise "assertion failed!"
function assertions.is_enumeration(value, enumeration)
  assertions._assert_with_custom_level(checks.is_enumeration(
    value,
    enumeration
  ))
end

---
-- @tparam any value
-- @tparam {any,...} enumeration
-- @raise "assertion failed!"
function assertions.is_enumeration_or_nil(value, enumeration)
  assertions._assert_with_custom_level(checks.is_enumeration_or_nil(
    value,
    enumeration
  ))
end

---
-- @tparam any value
-- @tparam {string,...} metaproperty_names
-- @raise "assertion failed!"
function assertions.has_metaproperties(value, metaproperty_names)
  assertions._assert_with_custom_level(checks.has_metaproperties(
    value,
    metaproperty_names
  ))
end

---
-- @tparam any value
-- @tparam {string,...} metaproperty_names
-- @raise "assertion failed!"
function assertions.has_metaproperties_or_is_nil(value, metaproperty_names)
  assertions._assert_with_custom_level(checks.has_metaproperties_or_is_nil(
    value,
    metaproperty_names
  ))
end

--- ⚠️. Checks that the value has the specified properties. Note that it tries to get properties by regular indexing, it doesn't touch the value metatable.
-- @tparam any value
-- @tparam {string,...} property_names
-- @raise "assertion failed!"
function assertions.has_properties(value, property_names)
  assertions._assert_with_custom_level(checks.has_properties(
    value,
    property_names
  ))
end

--- ⚠️. Checks that the value has the specified properties or is nil. Note that it tries to get properties by regular indexing, it doesn't touch the value metatable.
-- @tparam any value
-- @tparam {string,...} property_names
-- @raise "assertion failed!"
function assertions.has_properties_or_is_nil(value, property_names)
  assertions._assert_with_custom_level(checks.has_properties_or_is_nil(
    value,
    property_names
  ))
end

--- ⚠️. Unions the @{has_metaproperties|has_metaproperties()} and @{has_properties|has_properties()} functions. The property names are separated by prefix: if a property name starts with two underscores, it's passed to the @{has_metaproperties|has_metaproperties()} function, otherwise to the @{has_properties|has_properties()} function.
-- @tparam any value
-- @tparam {string,...} property_names
-- @raise "assertion failed!"
function assertions.has_properties_anywhere(value, property_names)
  assertions._assert_with_custom_level(checks.has_properties_anywhere(
    value,
    property_names
  ))
end

--- ⚠️. Unions the @{has_metaproperties_or_is_nil|has_metaproperties_or_is_nil()} and @{has_properties_or_is_nil|has_properties_or_is_nil()} functions. The property names are separated by prefix: if a property name starts with two underscores, it's passed to the @{has_metaproperties_or_is_nil|has_metaproperties_or_is_nil()} function, otherwise to the @{has_properties_or_is_nil|has_properties_or_is_nil()} function.
-- @tparam any value
-- @tparam {string,...} property_names
-- @raise "assertion failed!"
function assertions.has_properties_anywhere_or_is_nil(value, property_names)
  assertions._assert_with_custom_level(checks.has_properties_anywhere_or_is_nil(
    value,
    property_names
  ))
end

---
-- @tparam any value
-- @tparam {string,...} metamethod_names
-- @raise "assertion failed!"
function assertions.has_metamethods(value, metamethod_names)
  assertions._assert_with_custom_level(checks.has_metamethods(
    value,
    metamethod_names
  ))
end

---
-- @tparam any value
-- @tparam {string,...} metamethod_names
-- @raise "assertion failed!"
function assertions.has_metamethods_or_is_nil(value, metamethod_names)
  assertions._assert_with_custom_level(checks.has_metamethods_or_is_nil(
    value,
    metamethod_names
  ))
end

--- ⚠️. Checks that the value has the specified methods. Note that it tries to get methods by regular indexing, it doesn't touch the value metatable.
-- @tparam any value
-- @tparam {string,...} method_names
-- @raise "assertion failed!"
function assertions.has_methods(value, method_names)
  assertions._assert_with_custom_level(checks.has_methods(value, method_names))
end

--- ⚠️. Checks that the value has the specified methods or is nil. Note that it tries to get methods by regular indexing, it doesn't touch the value metatable.
-- @tparam any value
-- @tparam {string,...} method_names
-- @raise "assertion failed!"
function assertions.has_methods_or_is_nil(value, method_names)
  assertions._assert_with_custom_level(checks.has_methods_or_is_nil(
    value,
    method_names
  ))
end

--- ⚠️. Unions the @{has_metamethods|has_metamethods()} and @{has_methods|has_methods()} functions. The method names are separated by prefix: if a method name starts with two underscores, it's passed to the @{has_metamethods|has_metamethods()} function, otherwise to the @{has_methods|has_methods()} function.
-- @tparam any value
-- @tparam {string,...} method_names
-- @raise "assertion failed!"
function assertions.has_methods_anywhere(value, method_names)
  assertions._assert_with_custom_level(checks.has_methods_anywhere(
    value,
    method_names
  ))
end

--- ⚠️. Unions the @{has_metamethods_or_is_nil|has_metamethods_or_is_nil()} and @{has_methods_or_is_nil|has_methods_or_is_nil()} functions. The method names are separated by prefix: if a method name starts with two underscores, it's passed to the @{has_metamethods_or_is_nil|has_metamethods_or_is_nil()} function, otherwise to the @{has_methods_or_is_nil|has_methods_or_is_nil()} function.
-- @tparam any value
-- @tparam {string,...} method_names
-- @raise "assertion failed!"
function assertions.has_methods_anywhere_or_is_nil(value, method_names)
  assertions._assert_with_custom_level(checks.has_methods_anywhere_or_is_nil(
    value,
    method_names
  ))
end

--- ⚠️. Checks that the value is an instance of a class created by library [middleclass](https://github.com/kikito/middleclass).
-- @tparam any value
-- @tparam tab class a class created by library [middleclass](https://github.com/kikito/middleclass)
-- @raise "assertion failed!"
function assertions.is_instance(value, class)
  assertions._assert_with_custom_level(checks.is_instance(value, class))
end

--- ⚠️. Checks that the value is an instance of a class created by library [middleclass](https://github.com/kikito/middleclass) or is nil.
-- @tparam any value
-- @tparam tab class a class created by library [middleclass](https://github.com/kikito/middleclass)
-- @raise "assertion failed!"
function assertions.is_instance_or_nil(value, class)
  assertions._assert_with_custom_level(checks.is_instance_or_nil(value, class))
end

function assertions._assert_with_custom_level(value)
  if not value then
    error("assertion failed!", _ASSERTION_STACK_TRACE_LEVEL)
  end
end

-- we cannot check right away because at that moment the check function isn't defined
assertions.is_assertions_mode(_assertions_mode)

-- after filling module `assertions`, we make a backup of it
for key, value in pairs(assertions) do
  _assertions_backup[key] = value
end

return assertions
