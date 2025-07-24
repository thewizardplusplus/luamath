-- luacheck: no max comment line length

---
-- @classmod Matrix3x3

local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")
local checks = require("luatypechecks.checks")
local Nameable = require("luaserialization.nameable")
local Stringifiable = require("luaserialization.stringifiable")
local Vector2D = require("luamath.vector2d")

local Matrix3x3 = middleclass("Matrix3x3")
Matrix3x3:include(Nameable)
Matrix3x3:include(Stringifiable)

---
-- @table static
-- @tfield Matrix3x3 ZERO
-- @tfield Matrix3x3 IDENTITY

---
-- @tparam number delta_x
-- @tparam number delta_y
-- @treturn Matrix3x3
function Matrix3x3.static.translate(delta_x, delta_y)
  assertions.is_number(delta_x)
  assertions.is_number(delta_y)

  return Matrix3x3:new({
    {1, 0, delta_x},
    {0, 1, delta_y},
    {0, 0, 1},
  })
end

---
-- @tparam number angle in radians
-- @treturn Matrix3x3
function Matrix3x3.static.rotate(angle)
  assertions.is_number(angle)

  local angle_cos = math.cos(angle)
  local angle_sin = math.sin(angle)

  return Matrix3x3:new({
    {angle_cos, -angle_sin, 0},
    {angle_sin, angle_cos, 0},
    {0, 0, 1},
  })
end

---
-- @tparam number scale_x
-- @tparam number scale_y
-- @treturn Matrix3x3
function Matrix3x3.static.scale(scale_x, scale_y)
  assertions.is_number(scale_x)
  assertions.is_number(scale_y)

  return Matrix3x3:new({
    {scale_x, 0, 0},
    {0, scale_y, 0},
    {0, 0, 1},
  })
end

---
-- @tparam number shear_x
-- @tparam number shear_y
-- @treturn Matrix3x3
function Matrix3x3.static.shear(shear_x, shear_y)
  assertions.is_number(shear_x)
  assertions.is_number(shear_y)

  return Matrix3x3:new({
    {1, shear_x, 0},
    {shear_y, 1, 0},
    {0, 0, 1},
  })
end

---
-- @table instance
-- @tfield number[3][3] elements

---
-- @function new
-- @tparam table elements 3×3 table of numbers
-- @treturn Matrix3x3
function Matrix3x3:initialize(elements)
  assertions.is_sequence(
    elements,
    checks.make_sequence_checker(
      checks.is_number
    )
  )

  self.elements = elements
end

---
-- @treturn table table with instance fields
function Matrix3x3:__data()
  return {
    elements = self.elements,
  }
end

---
-- @function __tostring
-- @treturn string stringified table with instance fields

---
-- @tparam Matrix3x3 other
-- @treturn boolean
function Matrix3x3:equals(other)
  assertions.is_instance(other, Matrix3x3)

  for row = 1, 3 do
    for column = 1, 3 do
      if self.elements[row][column] ~= other.elements[row][column] then
        return false
      end
    end
  end

  return true
end

---
-- @tparam Matrix3x3 left_operand
-- @tparam Matrix3x3 right_operand
-- @treturn boolean
function Matrix3x3.__eq(left_operand, right_operand)
  assertions.is_instance(left_operand, Matrix3x3)
  assertions.is_instance(right_operand, Matrix3x3)

  return left_operand:equals(right_operand)
end

---
-- @tparam Matrix3x3 other
-- @tparam[opt=1e-6] number epsilon
-- @treturn boolean
function Matrix3x3:almost_equals(other, epsilon)
  epsilon = epsilon or 1e-6

  assertions.is_instance(other, Matrix3x3)
  assertions.is_number(epsilon)

  for row = 1, 3 do
    for column = 1, 3 do
      if not Matrix3x3._almost_equal(
        self.elements[row][column],
        other.elements[row][column],
        epsilon
      ) then
        return false
      end
    end
  end

  return true
end

---
-- @tparam Matrix3x3 other
-- @treturn Matrix3x3
function Matrix3x3:add(other)
  assertions.is_instance(other, Matrix3x3)

  local result = {}
  for row = 1, 3 do
    result[row] = {}

    for column = 1, 3 do
      result[row][column] =
        self.elements[row][column]
        + other.elements[row][column]
    end
  end

  return Matrix3x3:new(result)
end

---
-- @tparam Matrix3x3 left_operand
-- @tparam Matrix3x3 right_operand
-- @treturn Matrix3x3
function Matrix3x3.__add(left_operand, right_operand)
  assertions.is_instance(left_operand, Matrix3x3)
  assertions.is_instance(right_operand, Matrix3x3)

  return left_operand:add(right_operand)
end

---
-- @tparam Matrix3x3 other
-- @treturn Matrix3x3
function Matrix3x3:sub(other)
  assertions.is_instance(other, Matrix3x3)

  local result = {}
  for row = 1, 3 do
    result[row] = {}

    for column = 1, 3 do
      result[row][column] =
        self.elements[row][column]
        - other.elements[row][column]
    end
  end

  return Matrix3x3:new(result)
end

---
-- @tparam Matrix3x3 left_operand
-- @tparam Matrix3x3 right_operand
-- @treturn Matrix3x3
function Matrix3x3.__sub(left_operand, right_operand)
  assertions.is_instance(left_operand, Matrix3x3)
  assertions.is_instance(right_operand, Matrix3x3)

  return left_operand:sub(right_operand)
end

---
-- @tparam number|Vector2D|Matrix3x3 value
-- @treturn Vector2D|Matrix3x3
function Matrix3x3:mul(value)
  local is_value_number = checks.is_number(value)
  local is_value_vector_2d = checks.is_instance(value, Vector2D)
  local is_value_matrix_3x3 = checks.is_instance(value, Matrix3x3)
  assertions.is_true(
    is_value_number
    or is_value_vector_2d
    or is_value_matrix_3x3
  )

  if is_value_number then
    local result = {}
    for row = 1, 3 do
      result[row] = {}

      for column = 1, 3 do
        result[row][column] = self.elements[row][column] * value
      end
    end

    return Matrix3x3:new(result)
  end

  if is_value_vector_2d then
    local x =
      self.elements[1][1] * value.x
      + self.elements[1][2] * value.y
      + self.elements[1][3]
    local y =
      self.elements[2][1] * value.x
      + self.elements[2][2] * value.y
      + self.elements[2][3]
    return Vector2D:new(x, y)
  end

  if is_value_matrix_3x3 then
    local result = {}
    for row = 1, 3 do
      result[row] = {}

      for column = 1, 3 do
        result[row][column] = 0

        for k = 1, 3 do
          result[row][column] =
            result[row][column]
            + self.elements[row][k] * value.elements[k][column]
        end
      end
    end

    return Matrix3x3:new(result)
  end
end

---
-- @tparam number|Vector2D|Matrix3x3 left_operand
-- @tparam number|Vector2D|Matrix3x3 right_operand
-- @treturn Vector2D|Matrix3x3
function Matrix3x3.__mul(left_operand, right_operand)
  local is_left_operand_number = checks.is_number(left_operand)
  local is_left_operand_vector_2d = checks.is_instance(left_operand, Vector2D)
  local is_left_operand_matrix_3x3 = checks.is_instance(left_operand, Matrix3x3)

  local is_right_operand_number = checks.is_number(right_operand)
  local is_right_operand_vector_2d = checks.is_instance(right_operand, Vector2D)
  local is_right_operand_matrix_3x3 =
    checks.is_instance(right_operand, Matrix3x3)

  assertions.is_true(
    (is_left_operand_matrix_3x3 and (
      is_right_operand_number
      or is_right_operand_vector_2d
      or is_right_operand_matrix_3x3
    ))
    or (is_right_operand_matrix_3x3 and (
      is_left_operand_number
      or is_left_operand_vector_2d
      or is_left_operand_matrix_3x3
    ))
  )

  if is_left_operand_matrix_3x3 then
    return left_operand:mul(right_operand)
  end

  if is_right_operand_matrix_3x3 then
    return right_operand:mul(left_operand)
  end
end

---
-- @tparam number value
-- @treturn Matrix3x3
-- @raise error message
function Matrix3x3:div(value)
  assertions.is_number(value)

  if value == 0 then
    error("division by zero")
  end

  local result = {}
  for row = 1, 3 do
    result[row] = {}

    for column = 1, 3 do
      result[row][column] = self.elements[row][column] / value
    end
  end

  return Matrix3x3:new(result)
end

---
-- @tparam Matrix3x3 left_operand
-- @tparam number right_operand
-- @treturn Matrix3x3
-- @raise error message
function Matrix3x3.__div(left_operand, right_operand)
  assertions.is_instance(left_operand, Matrix3x3)
  assertions.is_number(right_operand)

  return left_operand:div(right_operand)
end

-- we cannot declare the constants at the beginning since the method `initialize()` isn't defined there yet
Matrix3x3.static.ZERO = Matrix3x3:new{
  {0, 0, 0},
  {0, 0, 0},
  {0, 0, 0}
}
Matrix3x3.static.IDENTITY = Matrix3x3:new{
  {1, 0, 0},
  {0, 1, 0},
  {0, 0, 1}
}

function Matrix3x3.static._almost_equal(left_operand, right_operand, epsilon)
  assertions.is_number(left_operand)
  assertions.is_number(right_operand)
  assertions.is_number(epsilon)

  return math.abs(left_operand - right_operand) <= epsilon
end

return Matrix3x3
