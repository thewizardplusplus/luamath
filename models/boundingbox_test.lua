local luaunit = require("luaunit")
local checks = require("luatypechecks.checks")
local json = require("luaserialization.json")
local BoundingBox = require("luamath.models.boundingbox")
local Vector2D = require("luamath.vector2d")
local Size = require("luamath.models.size")
local Range = require("luamath.models.range")

-- luacheck: globals TestBoundingBox
TestBoundingBox = {}

-- json.from_json()
function TestBoundingBox.test_from_json_success()
  local box, err = json.from_json(
    [[{
      "__name": "BoundingBox",
      "min": {"__name": "Vector2D", "x": 2, "y": 3},
      "max": {"__name": "Vector2D", "x": 7, "y": 11}
    }]],
    BoundingBox.schema(),
    { Vector2D = Vector2D.from_options, BoundingBox = BoundingBox.from_options }
  )

  luaunit.assert_is_table(box)
  luaunit.assert_true(checks.is_instance(box, BoundingBox))
  luaunit.assert_equals(box, BoundingBox:new(
    Vector2D:new(2, 3),
    Vector2D:new(7, 11)
  ))

  luaunit.assert_nil(err)
end

function TestBoundingBox.test_from_json_error()
  local box, err = json.from_json(
    [[{
      "__name": "BoundingBox",
      "min": {"__name": "Vector2D", "x": "invalid", "y": 3},
      "max": {"__name": "Vector2D", "x": 7, "y": 11}
    }]],
    BoundingBox.schema(),
    { Vector2D = Vector2D.from_options, BoundingBox = BoundingBox.from_options }
  )

  luaunit.assert_nil(box)

  luaunit.assert_is_string(err)
  luaunit.assert_str_matches(
    err,
    "^invalid data: " ..
      [[property "min" validation failed: ]] ..
      [[property "x" validation failed: ]] ..
      "wrong type: " ..
      "expected number, got string$"
  )
end

-- BoundingBox.static.from_options()
function TestBoundingBox.test_from_options_copies_inputs()
  local options = { min = Vector2D:new(2, 3), max = Vector2D:new(7, 11) }
  local result = BoundingBox.from_options(options)

  options.min.x = 20
  options.max.y = 110

  luaunit.assert_equals(result, BoundingBox:new(
    Vector2D:new(2, 3),
    Vector2D:new(7, 11)
  ))
end

-- BoundingBox.static.from_position_and_size()
function TestBoundingBox.test_from_position_and_size_valid()
  local position, size = Vector2D:new(10, 20), Size:new(30, 40)
  local result = BoundingBox.from_position_and_size(position, size)

  luaunit.assert_equals(result, BoundingBox:new(
    Vector2D:new(10, 20),
    Vector2D:new(40, 60)
  ))
end

function TestBoundingBox.test_from_position_and_size_copies_inputs()
  local position, size = Vector2D:new(10, 20), Size:new(30, 40)
  local result = BoundingBox.from_position_and_size(position, size)

  position.x = 100
  size.height = 400

  luaunit.assert_equals(result, BoundingBox:new(
    Vector2D:new(10, 20),
    Vector2D:new(40, 60)
  ))
end

function TestBoundingBox.test_from_position_and_size_invalid()
  local position, size = Vector2D:new(10, 20), Size:new(-30, -40)

  luaunit.assert_error_msg_contains(
    "`min` must be at most `max` on each axis",
    function()
      BoundingBox.from_position_and_size(position, size)
    end
  )
end

-- BoundingBox.static.from_ranges()
function TestBoundingBox.test_from_ranges()
  local x_range, y_range = Range:new(2, 7), Range:new(3, 11)
  local result = BoundingBox.from_ranges(x_range, y_range)

  luaunit.assert_equals(result, BoundingBox:new(
    Vector2D:new(2, 3),
    Vector2D:new(7, 11)
  ))
end

function TestBoundingBox.test_from_ranges_copies_inputs()
  local x_range, y_range = Range:new(2, 7), Range:new(3, 11)
  local result = BoundingBox.from_ranges(x_range, y_range)

  x_range.min = 1
  y_range.max = 12

  luaunit.assert_equals(result, BoundingBox:new(
    Vector2D:new(2, 3),
    Vector2D:new(7, 11)
  ))
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

function TestBoundingBox.test_union_copies_inputs()
  local box_one = BoundingBox:new(Vector2D:new(0, 0), Vector2D:new(2, 2))
  local box_two = BoundingBox:new(Vector2D:new(3, 1), Vector2D:new(5, 4))

  local result = BoundingBox.union(box_one, box_two)

  box_one.min.x = -1
  box_two.max.y = 5

  luaunit.assert_equals(result, BoundingBox:new(
    Vector2D:new(0, 0),
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

function TestBoundingBox.test_intersection_copies_inputs()
  local box_one = BoundingBox:new(Vector2D:new(0, 0), Vector2D:new(5, 5))
  local box_two = BoundingBox:new(Vector2D:new(2, 1), Vector2D:new(6, 4))

  local result = BoundingBox.intersection(box_one, box_two)

  box_one.max.x = 4
  box_two.min.y = 2

  luaunit.assert_equals(result, BoundingBox:new(
    Vector2D:new(2, 1),
    Vector2D:new(5, 4)
  ))
end

function TestBoundingBox.test_intersection_at_edge()
  local box_one = BoundingBox:new(Vector2D:new(0, 0), Vector2D:new(2, 2))
  local box_two = BoundingBox:new(Vector2D:new(2, 1), Vector2D:new(4, 3))

  local result = BoundingBox.intersection(box_one, box_two)

  luaunit.assert_equals(result, BoundingBox:new(
    Vector2D:new(2, 1),
    Vector2D:new(2, 2)
  ))
end

function TestBoundingBox.test_intersection_at_corner()
  local box_one = BoundingBox:new(Vector2D:new(0, 0), Vector2D:new(2, 2))
  local box_two = BoundingBox:new(Vector2D:new(2, 2), Vector2D:new(4, 4))

  local result = BoundingBox.intersection(box_one, box_two)

  luaunit.assert_equals(result, BoundingBox:new(
    Vector2D:new(2, 2),
    Vector2D:new(2, 2)
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
  local min, max = Vector2D:new(1, 2), Vector2D:new(5, 6)
  local result = BoundingBox:new(min, max)

  luaunit.assert_true(checks.is_instance(result, BoundingBox))
  luaunit.assert_equals(result.min, min)
  luaunit.assert_equals(result.max, max)
end

function TestBoundingBox.test_new_copies_inputs()
  local min, max = Vector2D:new(1, 2), Vector2D:new(5, 6)
  local result = BoundingBox:new(min, max)

  min.x = 10
  max.y = 60

  luaunit.assert_true(checks.is_instance(result, BoundingBox))
  luaunit.assert_equals(result.min, Vector2D:new(1, 2))
  luaunit.assert_equals(result.max, Vector2D:new(5, 6))
end

function TestBoundingBox.test_new_invalid()
  local min, max = Vector2D:new(10, 10), Vector2D:new(5, 6)

  luaunit.assert_error_msg_contains(
    "`min` must be at most `max` on each axis",
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

-- BoundingBox:equals()
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

-- BoundingBox:is_degenerate()
function TestBoundingBox.test_is_degenerate()
  local zero_width_box = BoundingBox:new(Vector2D:new(1, 2), Vector2D:new(1, 6))
  local zero_height_box = BoundingBox:new(
    Vector2D:new(1, 2),
    Vector2D:new(5, 2)
  )
  local non_degenerate_box = BoundingBox:new(
    Vector2D:new(1, 2),
    Vector2D:new(5, 6)
  )

  luaunit.assert_true(zero_width_box:is_degenerate())
  luaunit.assert_true(zero_height_box:is_degenerate())
  luaunit.assert_false(non_degenerate_box:is_degenerate())
end

function TestBoundingBox.test_is_degenerate_by_axis()
  local box = BoundingBox:new(Vector2D:new(1, 2), Vector2D:new(1, 6))

  luaunit.assert_true(box:is_degenerate("x"))
  luaunit.assert_false(box:is_degenerate("y"))
end

-- BoundingBox:is_almost_degenerate()
function TestBoundingBox.test_is_almost_degenerate()
  local almost_zero_width_box = BoundingBox:new(
    Vector2D:new(1, 2),
    Vector2D:new(1.0000001, 6)
  )
  local almost_zero_height_box = BoundingBox:new(
    Vector2D:new(1, 2),
    Vector2D:new(5, 2.0000001)
  )

  luaunit.assert_true(almost_zero_width_box:is_almost_degenerate())
  luaunit.assert_true(almost_zero_height_box:is_almost_degenerate())
  luaunit.assert_false(almost_zero_width_box:is_almost_degenerate(1e-12))
  luaunit.assert_false(almost_zero_height_box:is_almost_degenerate(1e-12))
end

function TestBoundingBox.test_is_almost_degenerate_by_axis()
  local box = BoundingBox:new(Vector2D:new(1, 2), Vector2D:new(1.0000001, 6))

  luaunit.assert_true(box:is_almost_degenerate(1e-6, "x"))
  luaunit.assert_false(box:is_almost_degenerate(1e-6, "y"))
end

-- BoundingBox:is_point()
function TestBoundingBox.test_is_point()
  local point_box = BoundingBox:new(Vector2D:new(1, 2), Vector2D:new(1, 2))
  local non_point_box = BoundingBox:new(Vector2D:new(1, 2), Vector2D:new(1, 6))

  luaunit.assert_true(point_box:is_point())
  luaunit.assert_false(non_point_box:is_point())
end

-- BoundingBox:is_almost_point()
function TestBoundingBox.test_is_almost_point()
  local box = BoundingBox:new(
    Vector2D:new(1, 2),
    Vector2D:new(1.0000001, 2.0000001)
  )

  luaunit.assert_true(box:is_almost_point())
  luaunit.assert_false(box:is_almost_point(1e-12))
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

-- BoundingBox:x_range() and BoundingBox:y_range()
function TestBoundingBox.test_axis_ranges()
  local box = BoundingBox:new(Vector2D:new(2, 3), Vector2D:new(7, 11))

  luaunit.assert_equals(box:x_range(), Range:new(2, 7))
  luaunit.assert_equals(box:y_range(), Range:new(3, 11))
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

-- BoundingBox:overlaps()
function TestBoundingBox.test_overlaps_with_positive_area()
  local box = BoundingBox:new(Vector2D:new(0, 0), Vector2D:new(3, 3))
  local other_box = BoundingBox:new(Vector2D:new(2, 1), Vector2D:new(4, 2))

  luaunit.assert_true(box:overlaps(other_box))
  luaunit.assert_true(other_box:overlaps(box))
end

function TestBoundingBox.test_does_not_overlap_disjoint_box()
  local box = BoundingBox:new(Vector2D:new(0, 0), Vector2D:new(2, 2))
  local other_box = BoundingBox:new(Vector2D:new(3, 3), Vector2D:new(4, 4))

  luaunit.assert_false(box:overlaps(other_box))
  luaunit.assert_false(other_box:overlaps(box))
end

function TestBoundingBox.test_does_not_overlap_at_edge()
  local box = BoundingBox:new(Vector2D:new(0, 0), Vector2D:new(2, 2))
  local other_box = BoundingBox:new(Vector2D:new(2, 1), Vector2D:new(4, 3))

  luaunit.assert_false(box:overlaps(other_box))
  luaunit.assert_false(other_box:overlaps(box))
end

function TestBoundingBox.test_does_not_overlap_at_corner()
  local box = BoundingBox:new(Vector2D:new(0, 0), Vector2D:new(2, 2))
  local other_box = BoundingBox:new(Vector2D:new(2, 2), Vector2D:new(4, 4))

  luaunit.assert_false(box:overlaps(other_box))
  luaunit.assert_false(other_box:overlaps(box))
end

function TestBoundingBox.test_does_not_overlap_degenerate_box()
  local box = BoundingBox:new(Vector2D:new(0, 0), Vector2D:new(4, 4))
  local other_box = BoundingBox:new(Vector2D:new(2, 1), Vector2D:new(2, 3))

  luaunit.assert_false(box:overlaps(other_box))
  luaunit.assert_false(other_box:overlaps(box))
end

-- BoundingBox:contains()
function TestBoundingBox.test_contains_point_true()
  local box = BoundingBox:new(Vector2D:new(0, 0), Vector2D:new(10, 10))

  local result = box:contains(Vector2D:new(5, 5))

  luaunit.assert_true(result)
end

function TestBoundingBox.test_contains_point_on_boundary()
  local box = BoundingBox:new(Vector2D:new(0, 0), Vector2D:new(10, 10))

  luaunit.assert_true(box:contains(Vector2D:new(0, 5)))
  luaunit.assert_true(box:contains(Vector2D:new(10, 10)))
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

function TestBoundingBox.test_contains_box_on_boundary()
  local box = BoundingBox:new(Vector2D:new(0, 0), Vector2D:new(10, 10))
  local other_box = BoundingBox:new(Vector2D:new(0, 2), Vector2D:new(10, 8))

  luaunit.assert_true(box:contains(other_box))
end

function TestBoundingBox.test_contains_box_false()
  local box = BoundingBox:new(Vector2D:new(0, 0), Vector2D:new(10, 10))
  local other_box = BoundingBox:new(Vector2D:new(8, 8), Vector2D:new(12, 12))

  local result = box:contains(other_box)

  luaunit.assert_false(result)
end

-- BoundingBox vector value operations
function TestBoundingBox.test_clamp()
  local box = BoundingBox:new(Vector2D:new(2, 3), Vector2D:new(7, 11))

  luaunit.assert_equals(box:clamp(Vector2D:new(1, 12)), Vector2D:new(2, 11))
  luaunit.assert_equals(box:clamp(Vector2D:new(4, 8)), Vector2D:new(4, 8))
end

function TestBoundingBox.test_lerp()
  local box = BoundingBox:new(Vector2D:new(2, 3), Vector2D:new(7, 11))

  luaunit.assert_equals(box:lerp(Vector2D:new(0.4, 0.75)), Vector2D:new(4, 9))
  luaunit.assert_equals(box:lerp(Vector2D:new(-1, 2)), Vector2D:new(-3, 19))
end

function TestBoundingBox.test_inverse_lerp()
  local box = BoundingBox:new(Vector2D:new(2, 3), Vector2D:new(7, 11))

  luaunit.assert_equals(
    box:inverse_lerp(Vector2D:new(4, 9)),
    Vector2D:new(0.4, 0.75)
  )
  luaunit.assert_equals(
    box:inverse_lerp(Vector2D:new(-3, 19)),
    Vector2D:new(-1, 2)
  )
end

function TestBoundingBox.test_inverse_lerp_rejects_degenerate_axis()
  luaunit.assert_error_msg_contains(
    "cannot inverse lerp a bounding box with a degenerate axis",
    function()
      BoundingBox:new(Vector2D:new(2, 3), Vector2D:new(2, 11))
        :inverse_lerp(Vector2D:new(2, 9))
    end
  )
end

function TestBoundingBox.test_wrap()
  local box = BoundingBox:new(Vector2D:new(2, 3), Vector2D:new(7, 11))

  luaunit.assert_equals(box:wrap(Vector2D:new(8, 1)), Vector2D:new(3, 9))
  luaunit.assert_equals(box:wrap(Vector2D:new(7, 11)), Vector2D:new(2, 3))
end

function TestBoundingBox.test_wrap_rejects_degenerate_axis()
  luaunit.assert_error_msg_contains(
    "cannot wrap in a bounding box with a degenerate axis",
    function()
      BoundingBox:new(Vector2D:new(2, 3), Vector2D:new(7, 3))
        :wrap(Vector2D:new(4, 3))
    end
  )
end

function TestBoundingBox.test_random()
  local box = BoundingBox:new(Vector2D:new(2, 3), Vector2D:new(7, 11))
  for _ = 1, 100 do
    local result = box:random()

    luaunit.assert_true(result.x >= box.min.x and result.x < box.max.x)
    luaunit.assert_true(result.y >= box.min.y and result.y < box.max.y)
  end
end

function TestBoundingBox.test_random_rejects_degenerate_axis()
  luaunit.assert_error_msg_contains(
    "cannot generate a random point in a bounding box with a degenerate axis",
    function()
      BoundingBox:new(Vector2D:new(2, 3), Vector2D:new(2, 11)):random()
    end
  )
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
    "`min` must be at most `max` on each axis",
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

function TestBoundingBox.test_scale_to_point()
  local box = BoundingBox:new(Vector2D:new(0, 0), Vector2D:new(10, 20))

  local result = box:scale(0, 0)

  luaunit.assert_equals(result, BoundingBox:new(
    Vector2D:new(5, 10),
    Vector2D:new(5, 10)
  ))
end

function TestBoundingBox.test_scale_to_zero_width()
  local box = BoundingBox:new(Vector2D:new(0, 0), Vector2D:new(10, 20))

  local result = box:scale(0, 1)

  luaunit.assert_equals(result, BoundingBox:new(
    Vector2D:new(5, 0),
    Vector2D:new(5, 20)
  ))
end

function TestBoundingBox.test_scale_to_zero_height()
  local box = BoundingBox:new(Vector2D:new(0, 0), Vector2D:new(10, 20))

  local result = box:scale(1, 0)

  luaunit.assert_equals(result, BoundingBox:new(
    Vector2D:new(0, 10),
    Vector2D:new(10, 10)
  ))
end

function TestBoundingBox.test_scale_rejects_negative_x_factor()
  local box = BoundingBox:new(Vector2D:new(0, 0), Vector2D:new(10, 20))

  luaunit.assert_error_msg_contains(
    "`scale_x` and `scale_y` must be non-negative",
    function()
      box:scale(-1, 1)
    end
  )
end

function TestBoundingBox.test_scale_rejects_negative_y_factor()
  local box = BoundingBox:new(Vector2D:new(0, 0), Vector2D:new(10, 20))

  luaunit.assert_error_msg_contains(
    "`scale_x` and `scale_y` must be non-negative",
    function()
      box:scale(1, -1)
    end
  )
end
