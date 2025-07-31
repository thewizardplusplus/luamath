local luaunit = require("luaunit")
local utils = require("luamath.utils")

-- luacheck: globals TestUtils
TestUtils = {}

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
