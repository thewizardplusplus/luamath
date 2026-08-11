local luaunit = require("luaunit")
local checks = require("luatypechecks.checks")
local json = require("luaserialization.json")
local Color = require("luamath.models.color")

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

  luaunit.assert_equals(color, Color:new(1, 0.5, 0))
  luaunit.assert_nil(err)
end

function TestColor.test_from_json_rejects_invalid_channel()
  local color, err = json.from_json(
    [[{"__name":"Color","red":2,"green":0.5,"blue":0}]],
    Color.schema(),
    { Color = Color.from_options }
  )

  luaunit.assert_nil(color)
  luaunit.assert_is_string(err)
end

-- Color.from_bytes()
function TestColor.test_from_bytes()
  local color = Color.from_bytes(255, 128, 0, 64)

  luaunit.assert_equals(color.red, 1)
  luaunit.assert_almost_equals(color.green, 128 / 255, 1e-12)
  luaunit.assert_equals(color.blue, 0)
  luaunit.assert_almost_equals(color.alpha, 64 / 255, 1e-12)
  luaunit.assert_equals(color:to_bytes(), {255, 128, 0, 64})
  luaunit.assert_equals(color:byte_channels(), {255, 128, 0, 64})
end

function TestColor.test_from_bytes_uses_default_alpha()
  luaunit.assert_equals(Color.from_bytes(255, 128, 0).alpha, 1)
end

function TestColor.test_from_bytes_rejects_invalid_channel()
  luaunit.assert_error_msg_contains(
    "byte color channels must be integers between 0 and 255",
    function()
      Color.from_bytes(256, 128, 0)
    end
  )
  luaunit.assert_error_msg_contains(
    "byte color channels must be integers between 0 and 255",
    function()
      Color.from_bytes(1.5, 128, 0)
    end
  )
end

-- Color.from_hex()
function TestColor.test_from_hex_rgb()
  local expected = Color.from_bytes(255, 128, 0)

  luaunit.assert_equals(Color.from_hex("#FF8000"), expected)
  luaunit.assert_equals(Color.from_hex("ff8000"), expected)
end

function TestColor.test_from_hex_rgba()
  luaunit.assert_equals(
    Color.from_hex("#FF800040"),
    Color.from_bytes(255, 128, 0, 64)
  )
end

function TestColor.test_from_hex_rejects_invalid_notation()
  luaunit.assert_error_msg_contains(
    "hex color must use RRGGBB or RRGGBBAA notation",
    function()
      Color.from_hex("#XYZ")
    end
  )
end

-- Color:new()
function TestColor.test_new()
  local color = Color:new(1, 0.5, 0, 0.25)

  luaunit.assert_true(checks.is_instance(color, Color))
  luaunit.assert_equals(color:channels(), {1, 0.5, 0, 0.25})
end

function TestColor.test_new_uses_default_alpha()
  luaunit.assert_equals(Color:new(1, 0.5, 0).alpha, 1)
end

function TestColor.test_new_rejects_each_invalid_channel()
  for channel = 1, 4 do
    local channels = {0, 0, 0, 0}
    channels[channel] = 1.1

    luaunit.assert_error_msg_contains(
      "color channels must be between 0 and 1",
      function()
        Color:new(channels[1], channels[2], channels[3], channels[4])
      end
    )
  end
end

-- tostring()
function TestColor.test_tostring()
  local result = tostring(Color:new(1, 0.5, 0, 0.25))

  luaunit.assert_equals(result, "{"
    .. [[__name = "Color",]]
    .. "alpha = 0.25,"
    .. "blue = 0,"
    .. "green = 0.5,"
    .. "red = 1"
  .. "}")
end

-- Color equality
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

-- Color:to_hex()
function TestColor.test_to_hex()
  luaunit.assert_equals(Color.from_bytes(255, 128, 0):to_hex(), "#FF8000")
  luaunit.assert_equals(Color.from_bytes(255, 128, 0):to_hex(true), "#FF8000FF")
  luaunit.assert_equals(Color.from_bytes(255, 128, 0, 64):to_hex(), "#FF800040")
end

-- Color constants
function TestColor.test_constants()
  luaunit.assert_true(Color.TRANSPARENT == Color:new(0, 0, 0, 0))
  luaunit.assert_true(Color.BLACK == Color:new(0, 0, 0))
  luaunit.assert_true(Color.WHITE == Color:new(1, 1, 1))
  luaunit.assert_true(Color.RED == Color:new(1, 0, 0))
  luaunit.assert_true(Color.GREEN == Color:new(0, 1, 0))
  luaunit.assert_true(Color.BLUE == Color:new(0, 0, 1))
end

-- Color operations
function TestColor.test_with_alpha()
  luaunit.assert_equals(Color.RED:with_alpha(0.25), Color:new(1, 0, 0, 0.25))
end

function TestColor.test_clamp()
  local color = Color:new(0, 0, 0)
  color.red = 1.5
  color.green = -0.5

  luaunit.assert_false(color:is_valid())
  luaunit.assert_equals(color:clamp(), Color:new(1, 0, 0))
end

function TestColor.test_lerp()
  local result = Color:new(1, 0, 0, 0.25):lerp(Color:new(0, 0, 1, 0.75), 0.5)

  luaunit.assert_equals(result, Color:new(0.5, 0, 0.5, 0.5))
end

function TestColor.test_composite_opaque_foreground()
  luaunit.assert_true(Color.RED:composite(Color.BLUE) == Color.RED)
end

function TestColor.test_composite_transparent_foreground()
  luaunit.assert_true(Color.TRANSPARENT:composite(Color.BLUE) == Color.BLUE)
end

function TestColor.test_composite_translucent_colors()
  local foreground = Color:new(1, 0, 0, 0.5)
  local background = Color:new(0, 0, 1, 0.5)

  local result = foreground:composite(background)

  luaunit.assert_true(result:almost_equals(Color:new(2 / 3, 0, 1 / 3, 0.75)))
  luaunit.assert_equals(foreground:composite_over(background), result)
end

function TestColor.test_composite_two_transparent_colors()
  local result = Color.TRANSPARENT:composite(Color.TRANSPARENT)

  luaunit.assert_true(result == Color.TRANSPARENT)
  luaunit.assert_false(rawequal(result, Color.TRANSPARENT))
end
