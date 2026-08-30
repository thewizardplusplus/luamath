local luaunit = require("luaunit")
local Vector2D = require("luamath.vector2d")
local Matrix3x3 = require("luamath.matrix3x3")
local Size = require("luamath.models.size")
local Range = require("luamath.models.range")
local BoundingBox = require("luamath.models.boundingbox")
local Color = require("luamath.models.color")

-- luacheck: globals TestEqualityPredicates
TestEqualityPredicates = {}

local comparisons = {
  {
    value = Vector2D:new(1, 2),
    class = Vector2D,
    unrelated = Range:new(1, 2),
  },
  {
    value = Matrix3x3:new({{1, 0, 0}, {0, 1, 0}, {0, 0, 1}}),
    class = Matrix3x3,
    unrelated = Vector2D:new(1, 2),
  },
  {
    value = Size:new(1, 2),
    class = Vector2D,
    unrelated = Range:new(1, 2),
  },
  {
    value = Range:new(1, 2),
    class = Range,
    unrelated = Vector2D:new(1, 2),
  },
  {
    value = BoundingBox:new(Vector2D:new(1, 2), Vector2D:new(3, 4)),
    class = BoundingBox,
    unrelated = Range:new(1, 2),
  },
  {
    value = Color:new(0.1, 0.2, 0.3, 0.4),
    class = Color,
    unrelated = Vector2D:new(1, 2),
  },
}

local function assert_incompatible(comparison, other)
  luaunit.assert_false(comparison.value:equals(other))
  luaunit.assert_false(comparison.value:almost_equals(other))
  luaunit.assert_false(comparison.class.__eq(comparison.value, other))
  luaunit.assert_false(comparison.class.__eq(other, comparison.value))
end

function TestEqualityPredicates.test_incompatible_values_return_false()
  for _, comparison in ipairs(comparisons) do
    assert_incompatible(comparison, nil)
    for _, other in ipairs({1, "value", {}, comparison.unrelated}) do
      assert_incompatible(comparison, other)
    end
  end
end

function TestEqualityPredicates.test_equality_operator_is_non_throwing()
  for _, comparison in ipairs(comparisons) do
    local success, result = pcall(function()
      return comparison.value == {}
    end)
    luaunit.assert_true(success)
    luaunit.assert_false(result)

    success, result = pcall(function()
      return {} == comparison.value
    end)
    luaunit.assert_true(success)
    luaunit.assert_false(result)
  end
end

function TestEqualityPredicates.test_invalid_epsilon_still_raises()
  for _, comparison in ipairs(comparisons) do
    luaunit.assert_error(function()
      comparison.value:almost_equals(nil, "invalid")
    end)
  end
end

function TestEqualityPredicates.test_vector_and_size_are_compatible()
  local vector = Vector2D:new(1, 2)
  local size = Size:new(1, 2)

  luaunit.assert_true(vector:equals(size))
  luaunit.assert_true(size:equals(vector))
  luaunit.assert_true(Vector2D.__eq(vector, size))
  luaunit.assert_true(Vector2D.__eq(size, vector))
  luaunit.assert_true(vector:almost_equals(size))
  luaunit.assert_true(size:almost_equals(vector))
end
