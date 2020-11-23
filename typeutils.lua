local typeutils = {}

function typeutils.is_number_with_limits(number, minimum, maximum)
  minimum = minimum or -math.huge
  maximum = maximum or math.huge

  assert(type(minimum) == "number")
  assert(type(maximum) == "number" and maximum >= minimum)

  return type(number) == "number" and number >= minimum and number <= maximum
end

return typeutils
