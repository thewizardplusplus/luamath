local luaunit = require("luaunit")
local checks = require("luatypechecks.checks")
local utils = require("luamath.utils")

-- luacheck: globals TestUtils
TestUtils = {}

-- utils.round()
function TestUtils.test_round_to_integer_by_default()
  luaunit.assert_equals(utils.round(23.4), 23)
  luaunit.assert_equals(utils.round(23.6), 24)
end

function TestUtils.test_round_to_decimal_precision()
  luaunit.assert_equals(utils.round(23.454, 2), 23.45)
  luaunit.assert_equals(utils.round(23.456, 2), 23.46)
end

function TestUtils.test_round_to_negative_precision()
  luaunit.assert_equals(utils.round(2345, -2), 2300)
  luaunit.assert_equals(utils.round(2355, -2), 2400)
end

function TestUtils.test_round_halfway_away_from_zero()
  luaunit.assert_equals(utils.round(23.5), 24)
  luaunit.assert_equals(utils.round(-23.5), -24)
  luaunit.assert_equals(utils.round(2.345, 2), 2.35)
  luaunit.assert_equals(utils.round(-2.345, 2), -2.35)
end

function TestUtils.test_round_floating_point_edge_cases()
  luaunit.assert_equals(utils.round(0.49999999999999994), 0)

  local large_odd_integer = 2.0 ^ 52 + 1
  luaunit.assert_equals(utils.round(large_odd_integer), large_odd_integer)
end

function TestUtils.test_round_integer_result_subtype()
  if _VERSION == "Lua 5.1" or _VERSION == "Lua 5.2" then
    luaunit.skip("Lua 5.1 and Lua 5.2 don't support integer subtypes")
  end

  luaunit.assert_equals(math.type(utils.round(23.4)), "integer")
  luaunit.assert_equals(math.type(utils.round(23.001, 2)), "integer")
  luaunit.assert_equals(math.type(utils.round(2345, -2)), "integer")
end

-- utils.almost_equal()
function TestUtils.test_almost_equal_true_with_defaults()
  local result = utils.almost_equal(1.0000001, 1.0)

  luaunit.assert_true(result)
end

function TestUtils.test_almost_equal_true_with_no_defaults()
  local result = utils.almost_equal(1.0000001, 1.0, 1e-6)

  luaunit.assert_true(result)
end

function TestUtils.test_almost_equal_false()
  local result = utils.almost_equal(1.0000001, 1.0, 1e-12)

  luaunit.assert_false(result)
end

-- utils.clamp()
function TestUtils.test_clamp_middle()
  local result = utils.clamp(32, 23, 42)

  luaunit.assert_equals(result, 32)
end

function TestUtils.test_clamp_minimum()
  local result = utils.clamp(23, 23, 42)

  luaunit.assert_equals(result, 23)
end

function TestUtils.test_clamp_before_minimum()
  local result = utils.clamp(22, 23, 42)

  luaunit.assert_equals(result, 23)
end

function TestUtils.test_clamp_maximum()
  local result = utils.clamp(42, 23, 42)

  luaunit.assert_equals(result, 42)
end

function TestUtils.test_clamp_after_maximum()
  local result = utils.clamp(43, 23, 42)

  luaunit.assert_equals(result, 42)
end

-- utils.lerp()
function TestUtils.test_lerp_middle()
  local result = utils.lerp(23, 42, 0.2)

  luaunit.assert_equals(result, 26.8)
end

function TestUtils.test_lerp_minimum()
  local result = utils.lerp(23, 42, 0)

  luaunit.assert_equals(result, 23)
end

function TestUtils.test_lerp_maximum()
  local result = utils.lerp(23, 42, 1)

  luaunit.assert_equals(result, 42)
end

-- utils.random_in_range()
function TestUtils.test_random_in_range()
  math.randomseed(1)

  local results = {}
  for _ = 1, 10 do
    local result = utils.random_in_range(23, 42)
    table.insert(results, result)
  end

  local wanted_results
  if _VERSION == "Lua 5.5" or _VERSION == "Lua 5.4" then
    wanted_results = {
      38.496168,
      41.744973,
      24.507284,
      32.474321,
      34.244394,
      38.845409,
      25.936408,
      28.019722,
      27.905971,
      37.831421,
    }
  elseif _VERSION == "Lua 5.3" or _VERSION == "Lua 5.2" then
    wanted_results = {
      30.493276,
      37.878885,
      38.170361,
      40.321300,
      26.753476,
      29.369232,
      37.596362,
      28.277720,
      33.525429,
      32.070544,
    }
  elseif _VERSION == "Lua 5.1" then
    if checks.is_table(jit) then -- check for LuaJIT
      wanted_results = {
        29.152401,
        23.258655,
        40.341720,
        28.675371,
        25.056512,
        25.001620,
        27.543950,
        38.933066,
        41.363617,
        29.867614,
      }
    else
      wanted_results = {
        38.963567,
        30.493276,
        37.878885,
        38.170361,
        40.321300,
        26.753476,
        29.369232,
        37.596362,
        28.277720,
        33.525429,
      }
    end
  end

  luaunit.assert_equals(#results, #wanted_results)
  for index, result in ipairs(results) do
    luaunit.assert_almost_equals(result, wanted_results[index], 1e-6)
  end
end

function TestUtils.test_random_in_range_rejects_degenerate_range()
  luaunit.assert_error_msg_contains(
    "`minimum` must be less than `maximum`",
    function()
      utils.random_in_range(23, 23)
    end
  )
end

function TestUtils.test_random_in_range_rejects_inverted_range()
  luaunit.assert_error_msg_contains(
    "`minimum` must be less than `maximum`",
    function()
      utils.random_in_range(42, 23)
    end
  )
end
