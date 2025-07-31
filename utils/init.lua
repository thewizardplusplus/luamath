---
-- @module utils

local assertions = require("luatypechecks.assertions")

local utils = {}

---
-- @tparam number left_operand
-- @tparam number right_operand
-- @tparam[opt=1e-6] number epsilon
-- @treturn boolean
function utils.almost_equal(left_operand, right_operand, epsilon)
  epsilon = epsilon or 1e-6

  assertions.is_number(left_operand)
  assertions.is_number(right_operand)
  assertions.is_number(epsilon)

  return math.abs(left_operand - right_operand) <= epsilon
end

---
-- @tparam number value
-- @tparam number minimum
-- @tparam number maximum
-- @treturn number
function utils.clamp(value, minimum, maximum)
  assertions.is_number(value)
  assertions.is_number(minimum)
  assertions.is_number(maximum)

  if value < minimum then
    value = minimum
  elseif value > maximum then
    value = maximum
  end

  return value
end

---
-- @tparam number minimum
-- @tparam number maximum
-- @tparam number progress
-- @treturn number
function utils.lerp(minimum, maximum, progress)
  assertions.is_number(minimum)
  assertions.is_number(maximum)
  assertions.is_number(progress)

  return (maximum - minimum) * progress + minimum
end

return utils
