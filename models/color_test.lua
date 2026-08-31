local luaunit = require("luaunit")
local checks = require("luatypechecks.checks")
local json = require("luaserialization.json")
local Color = require("luamath.models.color")
local Range = require("luamath.models.range")

-- luacheck: globals TestColor
TestColor = {}

function TestColor.test_from_json_success()
  local color, err = json.from_json(
    [[{"__name":"Color","red":1,"green":0.5,"blue":0,"alpha":0.25}]],
    Color.schema(),
    { Color = Color.from_options }
  )

  luaunit.assert_is_table(color)
  luaunit.assert_true(checks.is_instance(color, Color))
  luaunit.assert_equals(color, Color:new(1, 0.5, 0, 0.25))

  luaunit.assert_nil(err)
end

function TestColor.test_from_json_uses_default_alpha()
  local color, err = json.from_json(
    [[{"__name":"Color","red":1,"green":0.5,"blue":0}]],
    Color.schema(),
    { Color = Color.from_options }
  )

  luaunit.assert_is_table(color)
  luaunit.assert_true(checks.is_instance(color, Color))
  luaunit.assert_equals(color, Color:new(1, 0.5, 0))

  luaunit.assert_nil(err)
end

function TestColor.test_from_json_accepts_hdr_color_channel()
  local color, err = json.from_json(
    [[{"__name":"Color","red":2,"green":0.5,"blue":0}]],
    Color.schema(),
    { Color = Color.from_options }
  )

  luaunit.assert_is_table(color)
  luaunit.assert_true(checks.is_instance(color, Color))
  luaunit.assert_equals(color, Color:new(2, 0.5, 0))

  luaunit.assert_nil(err)
end

function TestColor.test_from_json_error()
  local color, err = json.from_json(
    [[{"__name":"Color","red":"invalid","green":0.5,"blue":0,"alpha":0.25}]],
    Color.schema(),
    { Color = Color.from_options }
  )

  luaunit.assert_nil(color)

  luaunit.assert_is_string(err)
  luaunit.assert_str_matches(
    err,
    "^invalid data: " ..
      [[property "red" validation failed: ]] ..
      "wrong type: " ..
      "expected number, got string$"
  )
end

-- Color.from_bytes()
function TestColor.test_from_bytes()
  local color = Color.from_bytes(255, 128, 0, 64)

  luaunit.assert_is_table(color)
  luaunit.assert_true(checks.is_instance(color, Color))
  luaunit.assert_equals(color.red, 1)
  luaunit.assert_almost_equals(color.green, 0.501961, 1e-6)
  luaunit.assert_equals(color.blue, 0)
  luaunit.assert_almost_equals(color.alpha, 0.250981, 1e-6)
end

function TestColor.test_from_bytes_uses_default_alpha()
  local color = Color.from_bytes(255, 128, 0)

  luaunit.assert_is_table(color)
  luaunit.assert_true(checks.is_instance(color, Color))
  luaunit.assert_equals(color.red, 1)
  luaunit.assert_almost_equals(color.green, 0.501961, 1e-6)
  luaunit.assert_equals(color.blue, 0)
  luaunit.assert_equals(color.alpha, 1)
end

function TestColor.test_from_bytes_rejects_invalid_channel()
  luaunit.assert_error_msg_contains(
    [[byte channel "red" must be an integer between 0 and 255]],
    function()
      Color.from_bytes(256, 128, 0)
    end
  )
end

-- Color.from_hex()
function TestColor.test_from_hex_rgb()
  local expected_color = Color.from_bytes(255, 128, 0)

  luaunit.assert_equals(Color.from_hex("#FF8000"), expected_color)
  luaunit.assert_equals(Color.from_hex("ff8000"), expected_color)
end

function TestColor.test_from_hex_short_rgb()
  local expected_color = Color.from_bytes(34, 51, 255)

  luaunit.assert_equals(Color.from_hex("#23F"), expected_color)
  luaunit.assert_equals(Color.from_hex("23f"), expected_color)
end

function TestColor.test_from_hex_rgba()
  local expected_color = Color.from_bytes(255, 128, 0, 64)

  luaunit.assert_equals(Color.from_hex("#FF800040"), expected_color)
  luaunit.assert_equals(Color.from_hex("ff800040"), expected_color)
end

function TestColor.test_from_hex_short_rgba()
  local expected_color = Color.from_bytes(34, 51, 255, 136)

  luaunit.assert_equals(Color.from_hex("#23F8"), expected_color)
  luaunit.assert_equals(Color.from_hex("23f8"), expected_color)
end

function TestColor.test_from_hex_rejects_invalid_notation()
  luaunit.assert_error_msg_contains(
    "hexadecimal color must use "
      .. "`#RGB`, `#RGBA`, `#RRGGBB`, or `#RRGGBBAA` notation",
    function()
      Color.from_hex("#XYZ")
    end
  )
end

-- Color:new()
function TestColor.test_new()
  local color = Color:new(1, 0.5, 0, 0.25)

  luaunit.assert_is_table(color)
  luaunit.assert_true(checks.is_instance(color, Color))
  luaunit.assert_equals(color.red, 1)
  luaunit.assert_equals(color.green, 0.5)
  luaunit.assert_equals(color.blue, 0)
  luaunit.assert_equals(color.alpha, 0.25)
end

function TestColor.test_new_uses_default_alpha()
  local color = Color:new(1, 0.5, 0)

  luaunit.assert_is_table(color)
  luaunit.assert_true(checks.is_instance(color, Color))
  luaunit.assert_equals(color.red, 1)
  luaunit.assert_equals(color.green, 0.5)
  luaunit.assert_equals(color.blue, 0)
  luaunit.assert_equals(color.alpha, 1)
end

function TestColor.test_new_accepts_hdr_color_channels()
  local color = Color:new(2, 0.5, 0)

  luaunit.assert_is_table(color)
  luaunit.assert_true(checks.is_instance(color, Color))
  luaunit.assert_equals(color.red, 2)
  luaunit.assert_equals(color.green, 0.5)
  luaunit.assert_equals(color.blue, 0)
  luaunit.assert_equals(color.alpha, 1)
end

function TestColor.test_new_rejects_invalid_channels()
  local expected_message =
    "color channels must be finite non-negative numbers "
    .. "and alpha must be between 0 and 1"

  for channel = 1, 4 do
    local channels = {0, 0, 0, 1}

    channels[channel] = -0.1
    luaunit.assert_error_msg_contains(
      expected_message,
      function()
        Color:new(channels[1], channels[2], channels[3], channels[4])
      end
    )

    channels[channel] = math.huge
    luaunit.assert_error_msg_contains(
      expected_message,
      function()
        Color:new(channels[1], channels[2], channels[3], channels[4])
      end
    )

    channels[channel] = 0 / 0
    luaunit.assert_error_msg_contains(
      expected_message,
      function()
        Color:new(channels[1], channels[2], channels[3], channels[4])
      end
    )
  end
end

function TestColor.test_new_rejects_alpha_above_one()
  luaunit.assert_error_msg_contains(
    "color channels must be finite non-negative numbers "
      .. "and alpha must be between 0 and 1",
    function()
      Color:new(0, 0, 0, 1.1)
    end
  )
end

-- tostring()
function TestColor.test_tostring()
  local color = Color:new(1, 0.5, 0, 0.25)

  local result = tostring(color)

  luaunit.assert_equals(result, "{"
    .. [[__name = "Color",]]
    .. "alpha = 0.25,"
    .. "blue = 0,"
    .. "green = 0.5,"
    .. "red = 1"
  .. "}")
end

-- Color:equals()
function TestColor.test_equals_method()
  luaunit.assert_true(Color:new(1, 0.5, 0):equals(Color:new(1, 0.5, 0)))
  luaunit.assert_false(Color:new(1, 0.5, 0):equals(Color:new(1, 0.5, 0, 0.5)))
end

function TestColor.test_equals_metamethod()
  luaunit.assert_true(Color:new(1, 0.5, 0) == Color:new(1, 0.5, 0))
  luaunit.assert_false(Color:new(1, 0.5, 0) == Color:new(1, 0.4, 0))
end

function TestColor.test_almost_equals()
  local color = Color:new(1, 0.5000001, 0, 1)

  luaunit.assert_true(color:almost_equals(Color:new(1, 0.5, 0, 1)))
  luaunit.assert_false(color:almost_equals(Color:new(1, 0.5, 0, 1), 1e-12))
end

function TestColor.test_incompatible_comparisons()
  local color = Color:new(1, 0.5, 0)

  luaunit.assert_false(color:equals(nil))
  luaunit.assert_false(color:almost_equals(nil))
  luaunit.assert_false(Color.__eq(color, nil))
  luaunit.assert_false(Color.__eq(nil, color))

  local incompatible_values = {1, "value", {}, Range:new(1, 2)}
  for _, value in ipairs(incompatible_values) do
    luaunit.assert_false(color:equals(value))
    luaunit.assert_false(color:almost_equals(value))
    luaunit.assert_false(Color.__eq(color, value))
    luaunit.assert_false(Color.__eq(value, color))
  end

  luaunit.assert_false(color == {})
  luaunit.assert_false({} == color)
end

-- Color:is_valid()
function TestColor.test_is_valid()
  luaunit.assert_true(Color:new(1, 0.5, 0, 0.25):is_valid())
end

function TestColor.test_is_valid_rejects_invalid_channels()
  for _, channel in ipairs({"red", "green", "blue", "alpha"}) do
    local color = Color:new(0, 0, 0)

    color[channel] = -0.1
    luaunit.assert_false(color:is_valid())

    color[channel] = math.huge
    luaunit.assert_false(color:is_valid())

    color[channel] = 0 / 0
    luaunit.assert_false(color:is_valid())
  end
end

function TestColor.test_is_valid_rejects_alpha_above_one()
  local color = Color:new(0, 0, 0)
  color.alpha = 1.1

  luaunit.assert_false(color:is_valid())
end

-- Color:byte_channel()
function TestColor.test_channels()
  local color = Color:new(1, 0.5, 0, 0.25)

  luaunit.assert_equals(color:channels(), {1, 0.5, 0, 0.25})
  luaunit.assert_equals(color:channels(false), {1, 0.5, 0})
  luaunit.assert_equals(color:channels(true), {1, 0.5, 0, 0.25})
end

function TestColor.test_byte_channel()
  local color = Color:new(1, 0.5, 0, 0.25)

  luaunit.assert_equals(color:byte_channel("red"), 255)
  luaunit.assert_equals(color:byte_channel("green"), 128)
  luaunit.assert_equals(color:byte_channel("blue"), 0)
  luaunit.assert_equals(color:byte_channel("alpha"), 64)
end

function TestColor.test_byte_channel_clamps_hdr_color_channel()
  local color = Color:new(2, 0.5, 0, 0.25)

  luaunit.assert_equals(color:byte_channel("red"), 255)
  luaunit.assert_equals(color:byte_channel("green"), 128)
  luaunit.assert_equals(color:byte_channel("blue"), 0)
  luaunit.assert_equals(color:byte_channel("alpha"), 64)
end

function TestColor.test_byte_channels()
  local color = Color:new(1, 0.5, 0, 0.25)

  luaunit.assert_equals(color:byte_channels(), {255, 128, 0, 64})
  luaunit.assert_equals(color:byte_channels(false), {255, 128, 0})
  luaunit.assert_equals(color:byte_channels(true), {255, 128, 0, 64})
end

-- Color operations
function TestColor.test_with_alpha()
  luaunit.assert_equals(Color.RED:with_alpha(0.25), Color:new(1, 0, 0, 0.25))
end

function TestColor.test_clamped()
  luaunit.assert_equals(
    Color:new(2, 0.5, 0, 0.25):clamped(),
    Color:new(1, 0.5, 0, 0.25)
  )
end

-- Color:to_hex()
function TestColor.test_to_hex()
  luaunit.assert_equals(Color.from_bytes(255, 128, 0):to_hex(), "#ff8000")
  luaunit.assert_equals(Color.from_bytes(255, 128, 0):to_hex(true), "#ff8000ff")
  luaunit.assert_equals(Color.from_bytes(255, 128, 0, 64):to_hex(), "#ff800040")
  luaunit.assert_equals(Color:new(1, 0.5, 0, 254.6 / 255):to_hex(), "#ff8000")
  luaunit.assert_equals(Color:new(2, 0.5, 0):to_hex(), "#ff8000")
end
