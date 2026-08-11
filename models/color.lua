-- luacheck: no max comment line length

---
-- @classmod Color

local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")
local Nameable = require("luaserialization.nameable")
local Stringifiable = require("luaserialization.stringifiable")
local utils = require("luamath.utils")

local Color = middleclass("Color")
Color:include(Nameable)
Color:include(Stringifiable)

local function is_normalized_channel(value)
  return value >= 0 and value <= 1
end

local function assert_byte_channel(value)
  assertions.is_number(value)

  if value % 1 ~= 0 or value < 0 or value > 255 then
    error("byte color channels must be integers between 0 and 255")
  end
end

---
-- @function schema
-- @static
-- @treturn tab JSON Schema for this class
--   (see the [luaserialization](https://github.com/thewizardplusplus/luaserialization) library)
function Color.static.schema()
  local channel_schema = { type = "number", minimum = 0, maximum = 1 }

  return {
    type = "object",
    required = {"red", "green", "blue"},
    properties = {
      red = channel_schema,
      green = channel_schema,
      blue = channel_schema,
      alpha = { type = "number", minimum = 0, maximum = 1, default = 1 },
    },
  }
end

---
-- @function from_options
-- @static
-- @tparam tab options constructor options conforming to the JSON Schema
--   returned by @{Color.schema|Color.schema()}
--   (see the [luaserialization](https://github.com/thewizardplusplus/luaserialization) library)
-- @treturn Color
function Color.static.from_options(options)
  assertions.is_table(options)

  return Color:new(options.red, options.green, options.blue, options.alpha)
end

---
-- @function from_bytes
-- @static
-- @tparam int red
-- @tparam int green
-- @tparam int blue
-- @tparam[opt=255] int alpha
-- @treturn Color
-- @raise error message
function Color.static.from_bytes(red, green, blue, alpha)
  alpha = alpha or 255

  assert_byte_channel(red)
  assert_byte_channel(green)
  assert_byte_channel(blue)
  assert_byte_channel(alpha)

  return Color:new(red / 255, green / 255, blue / 255, alpha / 255)
end

---
-- @function from_hex
-- @static
-- @tparam string value hexadecimal color in `#RRGGBB` or `#RRGGBBAA` notation
-- @treturn Color
-- @raise error message
function Color.static.from_hex(value)
  assertions.is_string(value)

  local hexadecimal = value:match("^#?(%x%x%x%x%x%x)$")
  local has_alpha = false
  if not hexadecimal then
    hexadecimal = value:match("^#?(%x%x%x%x%x%x%x%x)$")
    has_alpha = hexadecimal ~= nil
  end

  if not hexadecimal then
    error("hex color must use RRGGBB or RRGGBBAA notation")
  end

  local red = tonumber(hexadecimal:sub(1, 2), 16)
  local green = tonumber(hexadecimal:sub(3, 4), 16)
  local blue = tonumber(hexadecimal:sub(5, 6), 16)
  local alpha = has_alpha and tonumber(hexadecimal:sub(7, 8), 16) or 255

  return Color.from_bytes(red, green, blue, alpha)
end

---
-- @table class
-- @tfield Color TRANSPARENT
-- @tfield Color BLACK
-- @tfield Color WHITE
-- @tfield Color RED
-- @tfield Color GREEN
-- @tfield Color BLUE

---
-- @table instance
-- @tfield number red normalized red channel
-- @tfield number green normalized green channel
-- @tfield number blue normalized blue channel
-- @tfield number alpha normalized alpha channel

---
-- @function new
-- @tparam number red
-- @tparam number green
-- @tparam number blue
-- @tparam[opt=1] number alpha
-- @treturn Color
-- @raise error message
function Color:initialize(red, green, blue, alpha)
  alpha = alpha or 1

  assertions.is_number(red)
  assertions.is_number(green)
  assertions.is_number(blue)
  assertions.is_number(alpha)

  self.red = red
  self.green = green
  self.blue = blue
  self.alpha = alpha

  if not self:is_valid() then
    error("color channels must be between 0 and 1")
  end
end

---
-- @treturn table table with instance fields
function Color:__data()
  return {
    red = self.red,
    green = self.green,
    blue = self.blue,
    alpha = self.alpha,
  }
end

---
-- @function __tostring
-- @treturn string stringified table with instance fields

---
-- @tparam Color other
-- @treturn boolean
function Color:equals(other)
  assertions.is_instance(other, Color)

  return self.red == other.red
    and self.green == other.green
    and self.blue == other.blue
    and self.alpha == other.alpha
end

---
-- @tparam Color left_operand
-- @tparam Color right_operand
-- @treturn boolean
function Color.__eq(left_operand, right_operand)
  assertions.is_instance(left_operand, Color)
  assertions.is_instance(right_operand, Color)

  return left_operand:equals(right_operand)
end

---
-- @tparam Color other
-- @tparam[opt=1e-6] number epsilon
-- @treturn boolean
function Color:almost_equals(other, epsilon)
  epsilon = epsilon or 1e-6

  assertions.is_instance(other, Color)
  assertions.is_number(epsilon)

  return utils.almost_equal(self.red, other.red, epsilon)
    and utils.almost_equal(self.green, other.green, epsilon)
    and utils.almost_equal(self.blue, other.blue, epsilon)
    and utils.almost_equal(self.alpha, other.alpha, epsilon)
end

---
-- @treturn boolean whether every channel is normalized
function Color:is_valid()
  return is_normalized_channel(self.red)
    and is_normalized_channel(self.green)
    and is_normalized_channel(self.blue)
    and is_normalized_channel(self.alpha)
end

---
-- @treturn tab normalized channels in RGBA order
function Color:channels()
  return {self.red, self.green, self.blue, self.alpha}
end

---
-- @treturn tab integer channels in RGBA order
function Color:to_bytes()
  return {
    utils.round(self.red * 255),
    utils.round(self.green * 255),
    utils.round(self.blue * 255),
    utils.round(self.alpha * 255),
  }
end

---
-- @treturn tab integer channels in RGBA order
Color.byte_channels = Color.to_bytes

---
-- @tparam[opt] boolean include_alpha include alpha even for opaque colors
-- @treturn string hexadecimal color in `#RRGGBB` or `#RRGGBBAA` notation
function Color:to_hex(include_alpha)
  if include_alpha ~= nil then
    assertions.is_boolean(include_alpha)
  else
    include_alpha = self.alpha ~= 1
  end

  local channels = self:byte_channels()
  local result = string.format(
    "#%02X%02X%02X",
    channels[1],
    channels[2],
    channels[3]
  )
  if include_alpha then
    result = result .. string.format("%02X", channels[4])
  end

  return result
end

---
-- @tparam number alpha
-- @treturn Color
-- @raise error message
function Color:with_alpha(alpha)
  assertions.is_number(alpha)

  return Color:new(self.red, self.green, self.blue, alpha)
end

---
-- @treturn Color
function Color:clamp()
  return Color:new(
    utils.clamp(self.red, 0, 1),
    utils.clamp(self.green, 0, 1),
    utils.clamp(self.blue, 0, 1),
    utils.clamp(self.alpha, 0, 1)
  )
end

---
-- @tparam Color other
-- @tparam number progress
-- @treturn Color
function Color:lerp(other, progress)
  assertions.is_instance(other, Color)
  assertions.is_number(progress)

  return Color:new(
    utils.lerp(self.red, other.red, progress),
    utils.lerp(self.green, other.green, progress),
    utils.lerp(self.blue, other.blue, progress),
    utils.lerp(self.alpha, other.alpha, progress)
  )
end

---
-- ⚠️. Composite this straight-alpha foreground over a straight-alpha background.
-- @tparam Color background
-- @treturn Color straight-alpha result
function Color:composite(background)
  assertions.is_instance(background, Color)

  local alpha = self.alpha + background.alpha * (1 - self.alpha)
  if alpha == 0 then
    return Color:new(0, 0, 0, 0)
  end

  local background_factor = background.alpha * (1 - self.alpha)
  return Color:new(
    (self.red * self.alpha + background.red * background_factor) / alpha,
    (self.green * self.alpha + background.green * background_factor) / alpha,
    (self.blue * self.alpha + background.blue * background_factor) / alpha,
    alpha
  )
end

---
-- @tparam Color background
-- @treturn Color straight-alpha result
Color.composite_over = Color.composite

Color.static.TRANSPARENT = Color:new(0, 0, 0, 0)
Color.static.BLACK = Color:new(0, 0, 0)
Color.static.WHITE = Color:new(1, 1, 1)
Color.static.RED = Color:new(1, 0, 0)
Color.static.GREEN = Color:new(0, 1, 0)
Color.static.BLUE = Color:new(0, 0, 1)

return Color
