local typeutils = {}

function typeutils.is_number_with_limits(number, minimum, maximum)
  minimum = minimum or -math.huge
  maximum = maximum or math.huge

  assert(type(minimum) == "number")
  assert(type(maximum) == "number" and maximum >= minimum)

  return type(number) == "number" and number >= minimum and number <= maximum
end

function typeutils.is_callable(value)
  if type(value) == "function" then
    return true
  end

  return typeutils.has_metamethod(value, "__call")
end

function typeutils.is_instance(instance, class)
  return type(instance) == "table"
    and typeutils.is_callable(instance.isInstanceOf)
    and instance:isInstanceOf(class)
end

function typeutils.has_metamethod(value, metamethod)
  local metatable = getmetatable(value)
  return metatable and typeutils.is_callable(metatable[metamethod])
end

return typeutils
