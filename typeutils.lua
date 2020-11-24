local typeutils = {}

function typeutils.is_positive_number(number, limit)
  limit = limit or math.huge

  assert(type(limit) == "number" and limit >= 0)

  return type(number) == "number" and number >= 0 and number <= limit
end

function typeutils.is_callable(value)
  if type(value) == "function" then
    return true
  end

  return typeutils._has_metamethod(value, "__call")
end

function typeutils.is_instance(instance, class)
  return type(instance) == "table"
    and typeutils.is_callable(instance.isInstanceOf)
    and instance:isInstanceOf(class)
end

function typeutils._has_metamethod(value, metamethod)
  local metatable = getmetatable(value)
  return metatable and typeutils.is_callable(metatable[metamethod])
end

return typeutils
