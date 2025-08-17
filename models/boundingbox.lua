-- luacheck: no max comment line length

---
-- @classmod BoundingBox

local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")
local checks = require("luatypechecks.checks")
local Nameable = require("luaserialization.nameable")
local Stringifiable = require("luaserialization.stringifiable")
local Vector2D = require("luamath.vector2d")
local Size = require("luamath.models.size")

local BoundingBox = middleclass("BoundingBox")
BoundingBox:include(Nameable)
BoundingBox:include(Stringifiable)

---
-- @tparam Vector2D position
-- @tparam Size size
-- @treturn BoundingBox
-- @raise error message
function BoundingBox.static.from_position_and_size(position, size)
  assertions.is_instance(position, Vector2D)
  assertions.is_instance(size, Size)

  return BoundingBox:new(position, position + size)
end

---
-- @tparam BoundingBox,... ... one or more boxes
-- @treturn BoundingBox the smallest box containing all input boxes
-- @raise error message
function BoundingBox.static.union(...)
  local boxes = {...}

  assertions.is_sequence(boxes, checks.make_instance_checker(BoundingBox))

  if #boxes == 0 then
    error("at least one bounding box required")
  end

  local box = boxes[1]
  local min = Vector2D:new(box.min.x, box.min.y)
  local max = Vector2D:new(box.max.x, box.max.y)
  local result = BoundingBox:new(min, max)

  for box_index = 2, #boxes do
    local box = boxes[box_index] -- luacheck: no redefined

    if box.min.x < result.min.x then
      result.min.x = box.min.x
    end
    if box.min.y < result.min.y then
      result.min.y = box.min.y
    end

    if box.max.x > result.max.x then
      result.max.x = box.max.x
    end
    if box.max.y > result.max.y then
      result.max.y = box.max.y
    end
  end

  return result
end

---
-- @tparam BoundingBox,... ... one or more boxes
-- @treturn BoundingBox|nil the overlapping region of all input boxes, or nil if empty
-- @raise error message
function BoundingBox.static.intersection(...)
  local boxes = {...}

  assertions.is_sequence(boxes, checks.make_instance_checker(BoundingBox))

  if #boxes == 0 then
    error("at least one bounding box required")
  end

  local box = boxes[1]
  local min = Vector2D:new(box.min.x, box.min.y)
  local max = Vector2D:new(box.max.x, box.max.y)
  local result = BoundingBox:new(min, max)

  for box_index = 2, #boxes do
    local box = boxes[box_index] -- luacheck: no redefined

    if box.min.x > result.min.x then
      result.min.x = box.min.x
    end
    if box.min.y > result.min.y then
      result.min.y = box.min.y
    end

    if box.max.x < result.max.x then
      result.max.x = box.max.x
    end
    if box.max.y < result.max.y then
      result.max.y = box.max.y
    end
  end

  if not result:is_valid() then
    return nil
  end

  return result
end

---
-- @table instance
-- @tfield Vector2D min top-left corner
-- @tfield Vector2D max bottom-right corner

---
-- @function new
-- @tparam Vector2D min top-left corner
-- @tparam Vector2D max bottom-right corner
-- @treturn BoundingBox
-- @raise error message
function BoundingBox:initialize(min, max)
  assertions.is_instance(min, Vector2D)
  assertions.is_instance(max, Vector2D)

  self.min = min
  self.max = max

  if not self:is_valid() then
    error("invalid bounding box: min must not be greater than max")
  end
end

---
-- @treturn table table with instance fields
function BoundingBox:__data()
  return {
    min = self.min,
    max = self.max,
  }
end

---
-- @function __tostring
-- @treturn string stringified table with instance fields

---
-- @tparam BoundingBox other
-- @treturn boolean
function BoundingBox:equals(other)
  assertions.is_instance(other, BoundingBox)

  return self.min == other.min and self.max == other.max
end

---
-- @tparam BoundingBox left_operand
-- @tparam BoundingBox right_operand
-- @treturn boolean
function BoundingBox.__eq(left_operand, right_operand)
  assertions.is_instance(left_operand, BoundingBox)
  assertions.is_instance(right_operand, BoundingBox)

  return left_operand:equals(right_operand)
end

---
-- @tparam BoundingBox other
-- @tparam[opt=1e-6] number epsilon
-- @treturn boolean
function BoundingBox:almost_equals(other, epsilon)
  epsilon = epsilon or 1e-6

  assertions.is_instance(other, BoundingBox)
  assertions.is_number(epsilon)

  return self.min:almost_equals(other.min, epsilon)
    and self.max:almost_equals(other.max, epsilon)
end

---
-- @treturn boolean
function BoundingBox:is_valid()
  return self.min.x <= self.max.x and self.min.y <= self.max.y
end

---
-- @treturn Vector2D alias for self.min
function BoundingBox:position()
  return self.min
end

---
-- @treturn Size width and height of the box
function BoundingBox:size()
  local size_vector = self.max - self.min
  return Size:new(size_vector.x, size_vector.y)
end

---
-- @treturn Vector2D center of the box
function BoundingBox:center()
  return (self.min + self.max) / 2
end

---
-- @treturn Vector2D top-left corner
function BoundingBox:top_left()
  return self.min
end

---
-- @treturn Vector2D top-right corner
function BoundingBox:top_right()
  return Vector2D:new(self.max.x, self.min.y)
end

---
-- @treturn Vector2D bottom-left corner
function BoundingBox:bottom_left()
  return Vector2D:new(self.min.x, self.max.y)
end

---
-- @treturn Vector2D bottom-right corner
function BoundingBox:bottom_right()
  return self.max
end

---
-- @tparam Vector2D|BoundingBox value
-- @treturn boolean
function BoundingBox:contains(value)
  local is_value_vector_2d = checks.is_instance(value, Vector2D)
  local is_value_bounding_box = checks.is_instance(value, BoundingBox)
  assertions.is_true(is_value_vector_2d or is_value_bounding_box)

  if is_value_vector_2d then
    return value.x >= self.min.x and value.x <= self.max.x
      and value.y >= self.min.y and value.y <= self.max.y
  end

  if is_value_bounding_box then
    return self.min.x <= value.min.x and self.max.x >= value.max.x
      and self.min.y <= value.min.y and self.max.y >= value.max.y
  end
end

---
-- @tparam number delta_x
-- @tparam number delta_y
-- @treturn BoundingBox
function BoundingBox:translate(delta_x, delta_y)
  assertions.is_number(delta_x)
  assertions.is_number(delta_y)

  local delta = Vector2D:new(delta_x, delta_y)
  return BoundingBox:new(self.min + delta, self.max + delta)
end

---
-- ⚠️. Expand the box symmetrically by per-axis amounts.
-- @tparam number delta_x
-- @tparam number delta_y
-- @treturn BoundingBox
-- @raise error message
function BoundingBox:expand(delta_x, delta_y)
  assertions.is_number(delta_x)
  assertions.is_number(delta_y)

  local delta = Vector2D:new(delta_x, delta_y)
  return BoundingBox:new(self.min - delta, self.max + delta)
end

---
-- ⚠️. Scale the box around its center by per-axis factors.
-- @tparam number scale_x
-- @tparam number scale_y
-- @treturn BoundingBox
-- @raise error message
function BoundingBox:scale(scale_x, scale_y)
  assertions.is_number(scale_x)
  assertions.is_number(scale_y)

  local center = self:center()
  local scaled_half_size = (self:size() / 2) * Vector2D:new(scale_x, scale_y)
  return BoundingBox:new(center - scaled_half_size, center + scaled_half_size)
end

return BoundingBox
