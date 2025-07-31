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

return utils
