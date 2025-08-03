local luaunit = require("luaunit")
local checks = require("luatypechecks.checks")
local Size = require("luamath.models.size")
local Vector2D = require("luamath.vector2d")

-- luacheck: globals TestSize
TestSize = {}

-- Size:new() / Size:__index()
function TestSize.test_new()
  local size = Size:new(128, 256)

  luaunit.assert_true(checks.is_instance(size, Vector2D))
  luaunit.assert_true(checks.is_instance(size, Size))
  luaunit.assert_equals(size.x, 128)
  luaunit.assert_equals(size.y, 256)
  luaunit.assert_equals(size.width, 128)
  luaunit.assert_equals(size.height, 256)
end

-- Size:__newindex()
function TestSize.test_set_x_y()
  local size = Size:new(10, 20)

  size.x = 30
  size.y = 40

  luaunit.assert_equals(size.x, 30)
  luaunit.assert_equals(size.y, 40)
  luaunit.assert_equals(size.width, 30)
  luaunit.assert_equals(size.height, 40)
end

function TestSize.test_set_width_height()
  local size = Size:new(5, 15)

  size.width = 25
  size.height = 35

  luaunit.assert_equals(size.x, 25)
  luaunit.assert_equals(size.y, 35)
  luaunit.assert_equals(size.width, 25)
  luaunit.assert_equals(size.height, 35)
end

-- tostring()
function TestSize.test_tostring()
  local size = Size:new(3, 4)

  local result = tostring(size)

  luaunit.assert_equals(result, "{"
    .. [[__name = "Size",]]
    .. "height = 4,"
    .. "width = 3"
  .. "}")
end

-- Size:equals()
function TestSize.test_equals_method()
  local size = Size:new(3, 4)
  local other_size = Size:new(3, 4)

  local result = size:equals(other_size)

  luaunit.assert_true(result)
end

function TestSize.test_equals_metamethod()
  local size = Size:new(3, 4)
  local other_size = Size:new(3, 4)

  local result = (size == other_size)

  luaunit.assert_true(result)
end

function TestSize.test_almost_equals()
  local size = Size:new(1.0000001, 2.0000001)
  local other_size = Size:new(1.0, 2.0)

  local result = size:almost_equals(other_size)

  luaunit.assert_true(result)
end

-- Size:length()
function TestSize.test_length_squared()
  local size = Size:new(3, 4)

  local result = size:length_squared()

  luaunit.assert_equals(result, 25)
end

function TestSize.test_length_method()
  local size = Size:new(3, 4)

  local result = size:length()

  luaunit.assert_equals(result, 5)
end

function TestSize.test_length_metamethod()
  if _VERSION == "Lua 5.1" then
    luaunit.skip(
      "Lua 5.1 doesn't support the `__len()` metamethod "
        .. "when it's defined only on the prototype (class metatable)"
    )
  end

  local size = Size:new(3, 4)

  local result = #size

  luaunit.assert_equals(result, 5)
end

-- Size:normalized()
function TestSize.test_normalized()
  local size = Size:new(3, 4)

  local result = size:normalized()

  luaunit.assert_almost_equals(result.width, 0.6, 1e-6)
  luaunit.assert_almost_equals(result.height, 0.8, 1e-6)
end

-- Size:add()
function TestSize.test_add_method()
  local size = Size:new(1, 2)
  local other_size = Size:new(3, 4)

  local result = size:add(other_size)

  luaunit.assert_equals(result, Size:new(4, 6))
end

function TestSize.test_add_metamethod()
  local size = Size:new(1, 2)
  local other_size = Size:new(3, 4)

  local result = size + other_size

  luaunit.assert_equals(result, Size:new(4, 6))
end

-- Size:sub()
function TestSize.test_sub_method()
  local size = Size:new(5, 7)
  local other_size = Size:new(3, 4)

  local result = size:sub(other_size)

  luaunit.assert_equals(result, Size:new(2, 3))
end

function TestSize.test_sub_metamethod()
  local size = Size:new(5, 7)
  local other_size = Size:new(3, 4)

  local result = size - other_size

  luaunit.assert_equals(result, Size:new(2, 3))
end

-- Size:mul()
function TestSize.test_mul_method()
  local size = Size:new(2, 3)
  local other_size = Size:new(4, 5)

  local result = size:mul(other_size)

  luaunit.assert_equals(result, Size:new(8, 15))
end

function TestSize.test_mul_metamethod()
  local size = Size:new(2, 3)
  local other_size = Size:new(4, 5)

  local result = size * other_size

  luaunit.assert_equals(result, Size:new(8, 15))
end

-- Size:neg()
function TestSize.test_neg_method()
  local size = Size:new(3, -4)

  local result = size:neg()

  luaunit.assert_equals(result, Size:new(-3, 4))
end

function TestSize.test_neg_metamethod()
  local size = Size:new(3, -4)

  local result = -size

  luaunit.assert_equals(result, Size:new(-3, 4))
end

-- Size:dot()
function TestSize.test_dot()
  local size = Size:new(1, 2)
  local other_size = Size:new(3, 4)

  local result = size:dot(other_size)

  luaunit.assert_equals(result, 11)
end

-- Size:div()
function TestSize.test_div_method()
  local size = Size:new(8, 27)
  local other_size = Size:new(2, 3)

  local result = size:div(other_size)

  luaunit.assert_equals(result, Size:new(4, 9))
end

function TestSize.test_div_metamethod()
  local size = Size:new(8, 27)
  local other_size = Size:new(2, 3)

  local result = size / other_size

  luaunit.assert_equals(result, Size:new(4, 9))
end
