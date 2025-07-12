local luaunit = require("luaunit")
local checks = require("luatypechecks.checks")
local Vector2D = require("luamath.vector2d")

-- luacheck: globals TestVector2D
TestVector2D = {}

-- Vector2D:new()
function TestVector2D.test_new()
  local vector = Vector2D:new(3, 4)

  luaunit.assert_true(checks.is_instance(vector, Vector2D))
  luaunit.assert_equals(vector.x, 3)
  luaunit.assert_equals(vector.y, 4)
end

-- tostring()
function TestVector2D.test_tostring()
  local vector = Vector2D:new(3, 4)

  local result = tostring(vector)

  luaunit.assert_equals(result, "{"
    .. [[__name = "Vector2D",]]
    .. "x = 3,"
    .. "y = 4"
  .. "}")
end

-- Vector2D:equals()
function TestVector2D.test_equals_method_true()
  local vector = Vector2D:new(1, 2)
  local other_vector = Vector2D:new(1, 2)

  local result = vector:equals(other_vector)

  luaunit.assert_true(result)
end

function TestVector2D.test_equals_method_false()
  local vector = Vector2D:new(1, 2)
  local other_vector = Vector2D:new(2, 1)

  local result = vector:equals(other_vector)

  luaunit.assert_false(result)
end

function TestVector2D.test_equals_metamethod_true()
  local vector = Vector2D:new(1, 2)
  local other_vector = Vector2D:new(1, 2)

  local result = (vector == other_vector)

  luaunit.assert_true(result)
end

function TestVector2D.test_equals_metamethod_false()
  local vector = Vector2D:new(1, 2)
  local other_vector = Vector2D:new(2, 1)

  local result = (vector == other_vector)

  luaunit.assert_false(result)
end

function TestVector2D.test_not_equals_metamethod_true()
  local vector = Vector2D:new(1, 2)
  local other_vector = Vector2D:new(2, 1)

  local result = (vector ~= other_vector)

  luaunit.assert_true(result)
end

function TestVector2D.test_not_equals_metamethod_false()
  local vector = Vector2D:new(1, 2)
  local other_vector = Vector2D:new(1, 2)

  local result = (vector ~= other_vector)

  luaunit.assert_false(result)
end

function TestVector2D.test_almost_equals_true_with_defaults()
  local vector = Vector2D:new(1.0000001, 2.0000001)
  local other_vector = Vector2D:new(1.0, 2.0)

  local result = vector:almost_equals(other_vector)

  luaunit.assert_true(result)
end

function TestVector2D.test_almost_equals_true_with_no_defaults()
  local vector = Vector2D:new(1.0000001, 2.0000001)
  local other_vector = Vector2D:new(1.0, 2.0)

  local result = vector:almost_equals(other_vector, 1e-6)

  luaunit.assert_true(result)
end

function TestVector2D.test_almost_equals_false()
  local vector = Vector2D:new(1.0000001, 2.0000001)
  local other_vector = Vector2D:new(1.0, 2.0)

  local result = vector:almost_equals(other_vector, 1e-12)

  luaunit.assert_false(result)
end

-- Vector2D:length()
function TestVector2D.test_length_squared()
  local vector = Vector2D:new(3, 4)

  local result = vector:length_squared()

  luaunit.assert_equals(result, 25)
end

function TestVector2D.test_length_method()
  local vector = Vector2D:new(3, 4)

  local result = vector:length()

  luaunit.assert_equals(result, 5)
end

function TestVector2D.test_length_metamethod()
  if _VERSION == "Lua 5.1" then
    luaunit.skip(
      "Lua 5.1 doesn't support the `__len()` metamethod "
        .. "when it's defined only on the prototype (class metatable)"
    )
  end

  local vector = Vector2D:new(3, 4)

  local result = #vector

  luaunit.assert_equals(result, 5)
end

-- Vector2D:normalized()
function TestVector2D.test_normalized_method()
  local vector = Vector2D:new(3, 4)

  local result = vector:normalized()

  luaunit.assert_almost_equals(result.x, 0.6, 1e-6)
  luaunit.assert_almost_equals(result.y, 0.8, 1e-6)
end

function TestVector2D.test_normalized_zero()
  local vector = Vector2D:new(0, 0)

  luaunit.assert_error_msg_contains(
    "cannot normalize zero-length vector",
    function()
      vector:normalized()
    end
  )
end

-- Vector2D:add()
function TestVector2D.test_add_method()
  local vector = Vector2D:new(1, 2)
  local other_vector = Vector2D:new(3, 4)

  local result = vector:add(other_vector)

  luaunit.assert_equals(result, Vector2D:new(4, 6))
end

function TestVector2D.test_add_metamethod()
  local vector = Vector2D:new(1, 2)
  local other_vector = Vector2D:new(3, 4)

  local result = vector + other_vector

  luaunit.assert_equals(result, Vector2D:new(4, 6))
end

-- Vector2D:sub()
function TestVector2D.test_sub_method()
  local vector = Vector2D:new(5, 7)
  local other_vector = Vector2D:new(3, 4)

  local result = vector:sub(other_vector)

  luaunit.assert_equals(result, Vector2D:new(2, 3))
end

function TestVector2D.test_sub_metamethod()
  local vector = Vector2D:new(5, 7)
  local other_vector = Vector2D:new(3, 4)

  local result = vector - other_vector

  luaunit.assert_equals(result, Vector2D:new(2, 3))
end

-- Vector2D:mul()
function TestVector2D.test_mul_method_scalar()
  local vector = Vector2D:new(2, 3)

  local result = vector:mul(5)

  luaunit.assert_equals(result, Vector2D:new(10, 15))
end

function TestVector2D.test_mul_method_vector()
  local vector = Vector2D:new(2, 3)
  local other_vector = Vector2D:new(4, 5)

  local result = vector:mul(other_vector)

  luaunit.assert_equals(result, Vector2D:new(8, 15))
end

function TestVector2D.test_mul_metamethod_vector_scalar()
  local vector = Vector2D:new(2, 3)

  local result = vector * 5

  luaunit.assert_equals(result, Vector2D:new(10, 15))
end

function TestVector2D.test_mul_metamethod_scalar_vector()
  local vector = Vector2D:new(2, 3)

  local result = 5 * vector

  luaunit.assert_equals(result, Vector2D:new(10, 15))
end

function TestVector2D.test_mul_metamethod_vector_vector()
  local vector = Vector2D:new(2, 3)
  local other_vector = Vector2D:new(4, 5)

  local result = vector * other_vector

  luaunit.assert_equals(result, Vector2D:new(8, 15))
end

-- Vector2D:neg()
function TestVector2D.test_neg_method()
  local vector = Vector2D:new(3, -4)

  local result = vector:neg()

  luaunit.assert_equals(result, Vector2D:new(-3, 4))
end

function TestVector2D.test_neg_metamethod()
  local vector = Vector2D:new(3, -4)

  local result = -vector

  luaunit.assert_equals(result, Vector2D:new(-3, 4))
end

-- Vector2D:dot()
function TestVector2D.test_dot()
  local vector = Vector2D:new(1, 2)
  local other_vector = Vector2D:new(3, 4)

  local result = vector:dot(other_vector)

  luaunit.assert_equals(result, 11)
end

-- Vector2D:div()
function TestVector2D.test_div_method_scalar()
  local vector = Vector2D:new(10, 20)

  local result = vector:div(2)

  luaunit.assert_equals(result, Vector2D:new(5, 10))
end

function TestVector2D.test_div_method_vector()
  local vector = Vector2D:new(8, 27)
  local other_vector = Vector2D:new(2, 3)

  local result = vector:div(other_vector)

  luaunit.assert_equals(result, Vector2D:new(4, 9))
end

function TestVector2D.test_div_metamethod_vector_scalar()
  local vector = Vector2D:new(10, 20)

  local result = vector / 2

  luaunit.assert_equals(result, Vector2D:new(5, 10))
end

function TestVector2D.test_div_metamethod_vector_vector()
  local vector = Vector2D:new(8, 27)
  local other_vector = Vector2D:new(2, 3)

  local result = vector / other_vector

  luaunit.assert_equals(result, Vector2D:new(4, 9))
end

function TestVector2D.test_div_by_zero_scalar()
  local vector = Vector2D:new(1, 1)

  luaunit.assert_error_msg_contains("division by zero", function()
    vector:div(0)
  end)
end

function TestVector2D.test_div_by_vector_with_zero_x()
  local vector = Vector2D:new(1, 1)
  local other_vector = Vector2D:new(0, 1)

  luaunit.assert_error_msg_contains(
    "component-wise division by zero",
    function()
      vector:div(other_vector)
    end
  )
end

function TestVector2D.test_div_by_vector_with_zero_y()
  local vector = Vector2D:new(1, 1)
  local other_vector = Vector2D:new(1, 0)

  luaunit.assert_error_msg_contains(
    "component-wise division by zero",
    function()
      vector:div(other_vector)
    end
  )
end

return TestVector2D
