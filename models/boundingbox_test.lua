local luaunit = require("luaunit")
local checks = require("luatypechecks.checks")
local BoundingBox = require("luamath.models.boundingbox")
local Vector2D = require("luamath.vector2d")
local Size = require("luamath.models.size")

-- luacheck: globals TestBoundingBox
TestBoundingBox = {}

-- BoundingBox.static.from_position_and_size()
function TestBoundingBox.test_from_position_and_size_valid()
  local position = Vector2D:new(10, 20)
  local size = Size:new(30, 40)

  local result = BoundingBox.from_position_and_size(position, size)

  luaunit.assert_equals(result, BoundingBox:new(
    Vector2D:new(10, 20),
    Vector2D:new(40, 60)
  ))
end

function TestBoundingBox.test_from_position_and_size_invalid()
  local position = Vector2D:new(10, 20)
  local size = Size:new(-30, -40)

  luaunit.assert_error_msg_contains(
    "invalid bounding box: min must not be greater than max",
    function()
      BoundingBox.from_position_and_size(position, size)
    end
  )
end

-- BoundingBox.static.union()
function TestBoundingBox.test_union_multiple_values()
  local box_one = BoundingBox:new(Vector2D:new(0, 0), Vector2D:new(2, 2))
  local box_two = BoundingBox:new(Vector2D:new(3, 1), Vector2D:new(5, 4))
  local box_three = BoundingBox:new(Vector2D:new(-1, -2), Vector2D:new(1, 0))

  local result = BoundingBox.union(box_one, box_two, box_three)

  luaunit.assert_equals(result, BoundingBox:new(
    Vector2D:new(-1, -2),
    Vector2D:new(5, 4)
  ))
end

function TestBoundingBox.test_union_no_values()
  luaunit.assert_error_msg_contains(
    "at least one bounding box required",
    function()
      BoundingBox.union()
    end
  )
end

-- BoundingBox.static.intersection()
function TestBoundingBox.test_intersection_multiple_values()
  local box_one = BoundingBox:new(Vector2D:new(0, 0), Vector2D:new(5, 5))
  local box_two = BoundingBox:new(Vector2D:new(2, 1), Vector2D:new(6, 4))
  local box_three = BoundingBox:new(Vector2D:new(3, 2), Vector2D:new(4, 10))

  local result = BoundingBox.intersection(box_one, box_two, box_three)

  luaunit.assert_equals(result, BoundingBox:new(
    Vector2D:new(3, 2),
    Vector2D:new(4, 4)
  ))
end

function TestBoundingBox.test_intersection_no_overlap()
  local box_one = BoundingBox:new(Vector2D:new(0, 0), Vector2D:new(1, 1))
  local box_two = BoundingBox:new(Vector2D:new(2, 2), Vector2D:new(3, 3))
  local box_three = BoundingBox:new(Vector2D:new(4, 4), Vector2D:new(5, 5))

  local result = BoundingBox.intersection(box_one, box_two, box_three)

  luaunit.assert_nil(result)
end

function TestBoundingBox.test_intersection_no_values()
  luaunit.assert_error_msg_contains(
    "at least one bounding box required",
    function()
      BoundingBox.intersection()
    end
  )
end

-- BoundingBox:new()
function TestBoundingBox.test_new_valid()
  local min = Vector2D:new(1, 2)
  local max = Vector2D:new(5, 6)

  local result = BoundingBox:new(min, max)

  luaunit.assert_true(checks.is_instance(result, BoundingBox))
  luaunit.assert_equals(result.min, min)
  luaunit.assert_equals(result.max, max)
end

function TestBoundingBox.test_new_invalid()
  local min = Vector2D:new(10, 10)
  local max = Vector2D:new(5, 6)

  luaunit.assert_error_msg_contains(
    "invalid bounding box: min must not be greater than max",
    function()
      BoundingBox:new(min, max)
    end
  )
end

-- tostring()
function TestBoundingBox.test_tostring()
  local box = BoundingBox:new(Vector2D:new(2, 3), Vector2D:new(7, 11))

  local result = tostring(box)

  luaunit.assert_equals(result, "{"
    .. [[__name = "BoundingBox",]]
    .. "max = {"
      .. [[__name = "Vector2D",]]
      .. "x = 7,"
      .. "y = 11"
    .. "},"
    .. "min = {"
      .. [[__name = "Vector2D",]]
      .. "x = 2,"
      .. "y = 3"
    .. "}"
  .. "}")
end

-- Vector2D:equals()
function TestBoundingBox.test_equals_method_true()
  local box = BoundingBox:new(Vector2D:new(0, 0), Vector2D:new(3, 4))
  local other_box = BoundingBox:new(Vector2D:new(0, 0), Vector2D:new(3, 4))

  local result = box:equals(other_box)

  luaunit.assert_true(result)
end

function TestBoundingBox.test_equals_method_false()
  local box = BoundingBox:new(Vector2D:new(0, 0), Vector2D:new(3, 4))
  local other_box = BoundingBox:new(Vector2D:new(2, 3), Vector2D:new(5, 7))

  local result = box:equals(other_box)

  luaunit.assert_false(result)
end

function TestBoundingBox.test_equals_metamethod_true()
  local box = BoundingBox:new(Vector2D:new(0, 0), Vector2D:new(3, 4))
  local other_box = BoundingBox:new(Vector2D:new(0, 0), Vector2D:new(3, 4))

  local result = (box == other_box)

  luaunit.assert_true(result)
end

function TestBoundingBox.test_equals_metamethod_false()
  local box = BoundingBox:new(Vector2D:new(0, 0), Vector2D:new(3, 4))
  local other_box = BoundingBox:new(Vector2D:new(2, 3), Vector2D:new(5, 7))

  local result = (box == other_box)

  luaunit.assert_false(result)
end

function TestBoundingBox.test_not_equals_metamethod_true()
  local box = BoundingBox:new(Vector2D:new(0, 0), Vector2D:new(3, 4))
  local other_box = BoundingBox:new(Vector2D:new(2, 3), Vector2D:new(5, 7))

  local result = (box ~= other_box)

  luaunit.assert_true(result)
end

function TestBoundingBox.test_not_equals_metamethod_false()
  local box = BoundingBox:new(Vector2D:new(0, 0), Vector2D:new(3, 4))
  local other_box = BoundingBox:new(Vector2D:new(0, 0), Vector2D:new(3, 4))

  local result = (box ~= other_box)

  luaunit.assert_false(result)
end

function TestBoundingBox.test_almost_equals_true_with_defaults()
  local box = BoundingBox:new(
    Vector2D:new(0.0000001, 0.0000001),
    Vector2D:new(3.0000001, 4.0000001)
  )
  local other_box = BoundingBox:new(Vector2D:new(0, 0), Vector2D:new(3, 4))

  local result = box:almost_equals(other_box)

  luaunit.assert_true(result)
end

function TestBoundingBox.test_almost_equals_true_with_no_defaults()
  local box = BoundingBox:new(
    Vector2D:new(0.0000001, 0.0000001),
    Vector2D:new(3.0000001, 4.0000001)
  )
  local other_box = BoundingBox:new(Vector2D:new(0, 0), Vector2D:new(3, 4))

  local result = box:almost_equals(other_box, 1e-6)

  luaunit.assert_true(result)
end

function TestBoundingBox.test_almost_equals_false()
  local box = BoundingBox:new(
    Vector2D:new(0.0000001, 0.0000001),
    Vector2D:new(3.0000001, 4.0000001)
  )
  local other_box = BoundingBox:new(Vector2D:new(0, 0), Vector2D:new(3, 4))

  local result = box:almost_equals(other_box, 1e-12)

  luaunit.assert_false(result)
end

-- BoundingBox:is_valid()
function TestBoundingBox.test_is_valid_true()
  local box = BoundingBox:new(Vector2D:new(1, 2), Vector2D:new(5, 6))

  local result = box:is_valid()

  luaunit.assert_true(result)
end

function TestBoundingBox.test_is_valid_false()
  local box = BoundingBox:new(Vector2D:new(1, 2), Vector2D:new(5, 6))
  box.min = Vector2D:new(10, 10)

  local result = box:is_valid()

  luaunit.assert_false(result)
end

-- BoundingBox:position()
function TestBoundingBox.test_position()
  local box = BoundingBox:new(Vector2D:new(2, 3), Vector2D:new(7, 11))

  local result = box:position()

  luaunit.assert_equals(result, Vector2D:new(2, 3))
end

-- BoundingBox:size()
function TestBoundingBox.test_size()
  local box = BoundingBox:new(Vector2D:new(2, 3), Vector2D:new(7, 11))

  local result = box:size()

  luaunit.assert_equals(result, Size:new(5, 8))
end

-- BoundingBox:center()
function TestBoundingBox.test_center()
  local box = BoundingBox:new(Vector2D:new(2, 4), Vector2D:new(8, 10))

  local result = box:center()

  luaunit.assert_equals(result, Vector2D:new(5, 7))
end

-- BoundingBox:top_left()
function TestBoundingBox.test_top_left()
  local box = BoundingBox:new(Vector2D:new(2, 3), Vector2D:new(7, 11))

  local result = box:top_left()

  luaunit.assert_equals(result, Vector2D:new(2, 3))
end

-- BoundingBox:top_right()
function TestBoundingBox.test_top_right()
  local box = BoundingBox:new(Vector2D:new(2, 3), Vector2D:new(7, 11))

  local result = box:top_right()

  luaunit.assert_equals(result, Vector2D:new(7, 3))
end

-- BoundingBox:bottom_left()
function TestBoundingBox.test_bottom_left()
  local box = BoundingBox:new(Vector2D:new(2, 3), Vector2D:new(7, 11))

  local result = box:bottom_left()

  luaunit.assert_equals(result, Vector2D:new(2, 11))
end

-- BoundingBox:bottom_right()
function TestBoundingBox.test_bottom_right()
  local box = BoundingBox:new(Vector2D:new(2, 3), Vector2D:new(7, 11))

  local result = box:bottom_right()

  luaunit.assert_equals(result, Vector2D:new(7, 11))
end

-- BoundingBox:contains()
function TestBoundingBox.test_contains_point_true()
  local box = BoundingBox:new(Vector2D:new(0, 0), Vector2D:new(10, 10))

  local result = box:contains(Vector2D:new(5, 5))

  luaunit.assert_true(result)
end

function TestBoundingBox.test_contains_point_false()
  local box = BoundingBox:new(Vector2D:new(0, 0), Vector2D:new(10, 10))

  local result = box:contains(Vector2D:new(15, 5))

  luaunit.assert_false(result)
end

function TestBoundingBox.test_contains_box_true()
  local box = BoundingBox:new(Vector2D:new(0, 0), Vector2D:new(10, 10))
  local other_box = BoundingBox:new(Vector2D:new(2, 2), Vector2D:new(8, 8))

  local result = box:contains(other_box)

  luaunit.assert_true(result)
end

function TestBoundingBox.test_contains_box_false()
  local box = BoundingBox:new(Vector2D:new(0, 0), Vector2D:new(10, 10))
  local other_box = BoundingBox:new(Vector2D:new(8, 8), Vector2D:new(12, 12))

  local result = box:contains(other_box)

  luaunit.assert_false(result)
end

-- BoundingBox:translate()
function TestBoundingBox.test_translate()
  local box = BoundingBox:new(Vector2D:new(1, 2), Vector2D:new(5, 6))

  local result = box:translate(3, 4)

  luaunit.assert_equals(result, BoundingBox:new(
    Vector2D:new(4, 6),
    Vector2D:new(8, 10)
  ))
end

-- BoundingBox:expand()
function TestBoundingBox.test_expand_valid()
  local box = BoundingBox:new(Vector2D:new(3, 4), Vector2D:new(7, 8))

  local result = box:expand(2, 1)

  luaunit.assert_equals(result, BoundingBox:new(
    Vector2D:new(1, 3),
    Vector2D:new(9, 9)
  ))
end

function TestBoundingBox.test_expand_invalid()
  local box = BoundingBox:new(Vector2D:new(3, 4), Vector2D:new(7, 8))

  luaunit.assert_error_msg_contains(
    "invalid bounding box: min must not be greater than max",
    function()
      box:expand(-10, -10)
    end
  )
end

-- BoundingBox:scale()
function TestBoundingBox.test_scale_valid()
  local box = BoundingBox:new(Vector2D:new(0, 0), Vector2D:new(10, 20))

  local result = box:scale(2, 3)

  luaunit.assert_equals(result, BoundingBox:new(
    Vector2D:new(-5, -20),
    Vector2D:new(15, 40)
  ))
end

function TestBoundingBox.test_scale_invalid()
  local box = BoundingBox:new(Vector2D:new(0, 0), Vector2D:new(10, 20))

  luaunit.assert_error_msg_contains(
    "invalid bounding box: min must not be greater than max",
    function()
      box:scale(-10, -10)
    end
  )
end
