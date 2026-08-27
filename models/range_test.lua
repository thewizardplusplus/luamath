local luaunit = require("luaunit")
local checks = require("luatypechecks.checks")
local json = require("luaserialization.json")
local Range = require("luamath.models.range")

-- luacheck: globals TestRange
TestRange = {}

-- json.from_json()
function TestRange.test_from_json_success()
  local range, err = json.from_json(
    [[{"__name":"Range","min":23,"max":42}]],
    Range.schema(),
    { Range = Range.from_options }
  )

  luaunit.assert_is_table(range)
  luaunit.assert_true(checks.is_instance(range, Range))
  luaunit.assert_equals(range, Range:new(23, 42))

  luaunit.assert_nil(err)
end

function TestRange.test_from_json_error()
  local range, err = json.from_json(
    [[{"__name":"Range","min":"invalid","max":42}]],
    Range.schema(),
    { Range = Range.from_options }
  )

  luaunit.assert_nil(range)

  luaunit.assert_is_string(err)
  luaunit.assert_str_matches(
    err,
    "^invalid data: "
      .. [[property "min" validation failed: ]]
      .. "wrong type: "
      .. "expected number, got string$"
  )
end

-- Range.union()
function TestRange.test_union_multiple_values()
  local range_one, range_two, range_three =
    Range:new(23, 42), Range:new(50, 60), Range:new(10, 30)
  local result = Range.union(range_one, range_two, range_three)

  luaunit.assert_equals(result, Range:new(10, 60))
end

function TestRange.test_union_copies_inputs()
  local range_one, range_two, range_three =
    Range:new(23, 42), Range:new(50, 60), Range:new(10, 30)
  local result = Range.union(range_one, range_two, range_three)

  range_two.max = 70
  range_three.min = 5

  luaunit.assert_equals(result, Range:new(10, 60))
end

function TestRange.test_union_no_values()
  luaunit.assert_error_msg_contains("at least one range required", function()
    Range.union()
  end)
end

-- Range.intersection()
function TestRange.test_intersection_multiple_values()
  local range_one, range_two, range_three =
    Range:new(10, 50), Range:new(23, 42), Range:new(30, 60)
  local result = Range.intersection(range_one, range_two, range_three)

  luaunit.assert_equals(result, Range:new(30, 42))
end

function TestRange.test_intersection_copies_inputs()
  local range_one, range_two, range_three =
    Range:new(10, 50), Range:new(23, 42), Range:new(30, 60)
  local result = Range.intersection(range_one, range_two, range_three)

  range_two.max = 40
  range_three.min = 35

  luaunit.assert_equals(result, Range:new(30, 42))
end

function TestRange.test_intersection_at_endpoint()
  local result = Range.intersection(Range:new(10, 23), Range:new(23, 42))

  luaunit.assert_equals(result, Range:new(23, 23))
end

function TestRange.test_intersection_no_overlap()
  local result = Range.intersection(Range:new(10, 20), Range:new(30, 40))

  luaunit.assert_nil(result)
end

function TestRange.test_intersection_no_values()
  luaunit.assert_error_msg_contains("at least one range required", function()
    Range.intersection()
  end)
end

-- Range:new()
function TestRange.test_new()
  local range = Range:new(23, 42)

  luaunit.assert_true(checks.is_instance(range, Range))
  luaunit.assert_equals(range.min, 23)
  luaunit.assert_equals(range.max, 42)
end

function TestRange.test_new_degenerate()
  local range = Range:new(23, 23)

  luaunit.assert_true(checks.is_instance(range, Range))
  luaunit.assert_equals(range.min, 23)
  luaunit.assert_equals(range.max, 23)
end

function TestRange.test_new_rejects_inverted_range()
  luaunit.assert_error_msg_contains(
    "`min` must be at most `max`",
    function()
      Range:new(42, 23)
    end
  )
end

-- tostring()
function TestRange.test_tostring()
  local result = tostring(Range:new(23, 42))

  luaunit.assert_equals(result, "{"
    .. [[__name = "Range",]]
    .. "max = 42,"
    .. "min = 23"
  .. "}")
end

-- Range:equals()
function TestRange.test_equals_method()
  luaunit.assert_true(Range:new(23, 42):equals(Range:new(23, 42)))
  luaunit.assert_false(Range:new(23, 42):equals(Range:new(23, 43)))
end

function TestRange.test_equals_metamethod()
  luaunit.assert_true(Range:new(23, 42) == Range:new(23, 42))
  luaunit.assert_false(Range:new(23, 42) == Range:new(24, 42))
end

function TestRange.test_almost_equals()
  local range = Range:new(23.0000001, 42.0000001)

  luaunit.assert_true(range:almost_equals(Range:new(23, 42)))
  luaunit.assert_false(range:almost_equals(Range:new(23, 42), 1e-12))
end

-- Range properties
function TestRange.test_is_valid_true()
  local range = Range:new(23, 42)

  luaunit.assert_true(range:is_valid())
end

function TestRange.test_is_valid_false()
  local range = Range:new(23, 42)
  range.min, range.max = 42, 23

  luaunit.assert_false(range:is_valid())
end

function TestRange.test_is_degenerate()
  luaunit.assert_true(Range:new(23, 23):is_degenerate())
  luaunit.assert_false(Range:new(23, 42):is_degenerate())
end

function TestRange.test_is_almost_degenerate()
  local range = Range:new(23, 23.0000001)

  luaunit.assert_true(range:is_almost_degenerate())
  luaunit.assert_false(range:is_almost_degenerate(1e-12))
end

function TestRange.test_length_method()
  luaunit.assert_equals(Range:new(23, 42):length(), 19)
end

function TestRange.test_length_metamethod()
  if _VERSION == "Lua 5.1" then
    luaunit.skip(
      "Lua 5.1 doesn't support the `__len()` metamethod "
        .. "when it's defined only on the prototype (class metatable)"
    )
  end

  luaunit.assert_equals(#Range:new(23, 42), 19)
end

function TestRange.test_center()
  luaunit.assert_equals(Range:new(23, 42):center(), 32.5)
end

-- Range:overlaps()
function TestRange.test_overlaps_with_positive_length()
  local range = Range:new(23, 42)
  local other_range = Range:new(30, 50)

  luaunit.assert_true(range:overlaps(other_range))
  luaunit.assert_true(other_range:overlaps(range))
end

function TestRange.test_does_not_overlap_disjoint_range()
  local range = Range:new(23, 42)
  local other_range = Range:new(43, 50)

  luaunit.assert_false(range:overlaps(other_range))
  luaunit.assert_false(other_range:overlaps(range))
end

function TestRange.test_does_not_overlap_at_endpoint()
  local range = Range:new(23, 42)
  local other_range = Range:new(42, 50)

  luaunit.assert_false(range:overlaps(other_range))
  luaunit.assert_false(other_range:overlaps(range))
end

function TestRange.test_does_not_overlap_degenerate_range()
  local range = Range:new(23, 42)
  local other_range = Range:new(30, 30)

  luaunit.assert_false(range:overlaps(other_range))
  luaunit.assert_false(other_range:overlaps(range))
end

-- Range:contains()
function TestRange.test_contains_number()
  local range = Range:new(23, 42)

  luaunit.assert_true(range:contains(23))
  luaunit.assert_true(range:contains(32))
  luaunit.assert_true(range:contains(42))
  luaunit.assert_false(range:contains(22))
  luaunit.assert_false(range:contains(43))
end

function TestRange.test_contains_range()
  local range = Range:new(23, 42)

  luaunit.assert_true(range:contains(Range:new(24, 41)))
  luaunit.assert_true(range:contains(Range:new(23, 42)))
  luaunit.assert_false(range:contains(Range:new(22, 41)))
  luaunit.assert_false(range:contains(Range:new(24, 43)))
  luaunit.assert_false(range:contains(Range:new(22, 43)))
end

-- Range value operations
function TestRange.test_clamp()
  local range = Range:new(23, 42)

  luaunit.assert_equals(range:clamp(22), 23)
  luaunit.assert_equals(range:clamp(32), 32)
  luaunit.assert_equals(range:clamp(43), 42)
end

function TestRange.test_lerp()
  local range = Range:new(23, 42)

  luaunit.assert_equals(range:lerp(0), 23)
  luaunit.assert_equals(range:lerp(1), 42)
  luaunit.assert_equals(range:lerp(2), 61)
end

function TestRange.test_inverse_lerp()
  local range = Range:new(23, 42)

  luaunit.assert_almost_equals(range:inverse_lerp(26.8), 0.2, 1e-12)
  luaunit.assert_equals(range:inverse_lerp(61), 2)
end

function TestRange.test_inverse_lerp_rejects_degenerate_range()
  luaunit.assert_error_msg_contains(
    "`minimum` and `maximum` must be different",
    function()
      Range:new(23, 23):inverse_lerp(23)
    end
  )
end

function TestRange.test_wrap()
  local range = Range:new(23, 42)

  luaunit.assert_equals(range:wrap(42), 23)
  luaunit.assert_equals(range:wrap(45), 26)
  luaunit.assert_equals(range:wrap(20), 39)
end

function TestRange.test_wrap_rejects_degenerate_range()
  luaunit.assert_error_msg_contains(
    "`minimum` must be less than `maximum`",
    function()
      Range:new(23, 23):wrap(23)
    end
  )
end

function TestRange.test_random()
  local range = Range:new(23, 42)
  for _ = 1, 100 do
    local result = range:random()

    luaunit.assert_true(result >= range.min)
    luaunit.assert_true(result < range.max)
  end
end

function TestRange.test_random_rejects_degenerate_range()
  luaunit.assert_error_msg_contains(
    "`minimum` must be less than `maximum`",
    function()
      Range:new(23, 23):random()
    end
  )
end

-- Range range operations
function TestRange.test_translate()
  local result = Range:new(23, 42):translate(10)

  luaunit.assert_equals(result, Range:new(33, 52))
end

function TestRange.test_expand()
  local result = Range:new(23, 42):expand(5)

  luaunit.assert_equals(result, Range:new(18, 47))
end

function TestRange.test_expand_rejects_inversion()
  luaunit.assert_error_msg_contains(
    "`min` must be at most `max`",
    function()
      Range:new(23, 42):expand(-10)
    end
  )
end

function TestRange.test_scale_valid()
  local result = Range:new(20, 40):scale(2)

  luaunit.assert_equals(result, Range:new(10, 50))
end

function TestRange.test_scale_to_zero()
  local result = Range:new(20, 40):scale(0)

  luaunit.assert_equals(result, Range:new(30, 30))
end

function TestRange.test_scale_rejects_negative_factor()
  luaunit.assert_error_msg_contains(
    "`factor` must be non-negative",
    function()
      Range:new(20, 40):scale(-1)
    end
  )
end
