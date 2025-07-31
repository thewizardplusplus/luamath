local luaunit = require("luaunit")
local utils = require("luamath.utils")

-- luacheck: globals TestUtils
TestUtils = {}

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
