# luamath

[![doc:build](https://github.com/thewizardplusplus/luamath/actions/workflows/doc.yaml/badge.svg)](https://github.com/thewizardplusplus/luamath/actions/workflows/doc.yaml)
[![doc:link](https://img.shields.io/badge/doc%3Alink-link-blue?logo=github)](https://thewizardplusplus.github.io/luamath/)
[![lint](https://github.com/thewizardplusplus/luamath/actions/workflows/lint.yaml/badge.svg)](https://github.com/thewizardplusplus/luamath/actions/workflows/lint.yaml)
[![test](https://github.com/thewizardplusplus/luamath/actions/workflows/test.yaml/badge.svg)](https://github.com/thewizardplusplus/luamath/actions/workflows/test.yaml)
[![luarocks](https://img.shields.io/badge/luarocks-link-blue?logo=lua)](https://luarocks.org/modules/thewizardplusplus/luamath)

The library that implements various auxiliary math classes and functions.

_**Disclaimer:** this library was written directly on an Android smartphone with the ~~[QLua](https://play.google.com/store/apps/details?id=com.quseit.qlua5pro2)~~ [LuaDroid](https://play.google.com/store/apps/details?id=com.alif.ide.lua) IDE._

## Features

- **Utility functions**:
  - `sign(value)` — return the sign of a number
  - `round(value, [precision])` — round a number to the specified number of decimal places
  - `almost_equal(left_operand, right_operand, [epsilon])` — compare two numbers approximately
  - `clamp(value, minimum, maximum)` — clamp a number to a range
  - `lerp(minimum, maximum, progress)` — interpolate between two numbers
  - `inverse_lerp(minimum, maximum, value)` — compute interpolation progress for a value
  - `wrap(value, minimum, maximum)` — wrap a number into a range
  - `random_in_range(minimum, maximum)` — generate a random number in a range
- **Classes**:
  - `Vector2D`:
    - **Serialization**:
      - `schema()` — return the JSON Schema for the class
      - `from_options(options)` — construct a vector from a table
      - `__data()` — return a table with the instance fields
      - `__tostring()` — return a string representation of the instance
    - **Constants**:
      - `ZERO` — (0, 0)
      - `BASIS_X` — (1, 0)
      - `BASIS_Y` — (0, 1)
    - **Operations**:
      - `equals(other)` — check exact equality
      - `almost_equals(other, [epsilon])` — check approximate equality within a given epsilon
      - `length_squared()` — compute the squared length
      - `length()` — compute the length
      - `normalized()` — return the normalized vector
      - `add(other)` — add another vector
      - `sub(other)` — subtract another vector
      - `mul(value)` — multiply by a scalar, matrix, or perform component-wise multiplication with another vector
      - `neg()` — unary minus
      - `dot(other)` — compute the dot product
      - `div(value)` — divide by a scalar or perform component-wise division by another vector
    - **Operators (via metamethods)**:
      - `==` — check exact equality (`__eq()`)
      - `#vector` — compute the length (`__len()`); supported only since Lua 5.2
      - `+` — add two vectors (`__add()`)
      - `-` — subtract two vectors (`__sub()`)
      - `*` — multiply by a scalar (`vector * scalar` or `scalar * vector`), matrix (`vector * matrix` or `matrix * vector`), or perform component-wise multiplication (`vector * vector`) (`__mul()`)
      - `-vector` — unary minus (`__unm()`)
      - `/` — divide by a scalar (`vector / scalar`) or perform component-wise division (`vector / vector`) (`__div()`)
  - `Matrix3x3`:
    - **Serialization**:
      - `schema()` — return the JSON Schema for the class
      - `from_options(options)` — construct a matrix from a table
      - `__data()` — return a table with the instance fields
      - `__tostring()` — return a string representation of the instance
    - **Constants**:
      - `ZERO` — zero matrix
      - `IDENTITY` — identity matrix
    - **Factories**:
      - `translate(delta)` — translation by a `Vector2D`
      - `rotate(angle)` — rotation
      - `scale(scale)` — uniform numeric or per-axis `Vector2D` scaling
      - `shear(shear)` — shear by a `Vector2D`
    - **Operations**:
      - `equals(other)` — check exact equality
      - `almost_equals(other, [epsilon])` — check approximate equality within a given epsilon
      - `inverse()` — return the inverse matrix
      - `add(other)` — add another matrix
      - `sub(other)` — subtract another matrix
      - `mul(value)` — multiply by a scalar, vector, or another matrix
      - `div(value)` — divide by a scalar
    - **Operators (via metamethods)**:
      - `==` — check exact equality (`__eq()`)
      - `+` — add two matrices (`__add()`)
      - `-` — subtract two matrices (`__sub()`)
      - `*` — multiply by a scalar (`matrix * scalar` or `scalar * matrix`), vector (`matrix * vector` or `vector * matrix`), or another matrix (`matrix * matrix`) (`__mul()`)
      - `/` — divide by a scalar (`matrix / scalar`) (`__div()`)
  - **Models**:
    - `Size` — a `Vector2D` subclass with `width` and `height` aliases for `x` and `y`:
      - **Serialization**:
        - `schema()` — return the JSON Schema for the class
        - `from_options(options)` — construct a size from a table
        - `__data()` — return a table with the instance fields
        - `__tostring()` — return a string representation of the instance
      - **Operations**:
        - `equals(other)` — check exact equality
        - `almost_equals(other, [epsilon])` — check approximate equality within a given epsilon
        - `length_squared()` — compute the squared length
        - `length()` — compute the length
        - `normalized()` — return the normalized size
        - `add(other)` — add another vector
        - `sub(other)` — subtract another vector
        - `mul(value)` — multiply by a scalar, matrix, or perform component-wise multiplication with another vector
        - `neg()` — unary minus
        - `dot(other)` — compute the dot product
        - `div(value)` — divide by a scalar or perform component-wise division by another vector
      - **Operators (via metamethods)**:
        - `==` — check exact equality (`__eq()`)
        - `#size` — compute the length (`__len()`); supported only since Lua 5.2
        - `+` — add two vectors (`__add()`)
        - `-` — subtract two vectors (`__sub()`)
        - `*` — multiply by a scalar, matrix, or another vector (`__mul()`)
        - `-size` — unary minus (`__unm()`)
        - `/` — divide by a scalar or another vector (`__div()`)
    - `Range` — a closed numeric range:
      - **Serialization**:
        - `schema()` — return the JSON Schema for the class
        - `from_options(options)` — construct a range from a table
        - `__data()` — return a table with the instance fields
        - `__tostring()` — return a string representation of the instance
      - **Factories**:
        - `union(...)` — return the smallest range containing all input ranges
        - `intersection(...)` — return the common range or `nil` if it is empty
      - **Operations**:
        - `equals(other)` — check exact equality
        - `almost_equals(other, [epsilon])` — check approximate equality within a given epsilon
        - `is_valid()` — check that the minimum is not greater than the maximum
        - `is_degenerate()` — check whether the range has zero length
        - `is_almost_degenerate([epsilon])` — check whether the range has almost zero length
        - `length()` — compute the range length
        - `center()` — compute the center
        - `overlaps(other)` — check whether the intersection has positive length
        - `contains(value)` — check whether the range contains a number or another range
        - `clamp(value)` — clamp a number to the range
        - `lerp(progress)` — interpolate between the endpoints
        - `inverse_lerp(value)` — compute interpolation progress for a value
        - `wrap(value)` — wrap a number into the range
        - `random()` — generate a random number in the range
        - `translate(delta)` — translate the range
        - `expand(delta)` — expand the range symmetrically
        - `scale(factor)` — scale the range around its center
      - **Operators (via metamethods)**:
        - `==` — check exact equality (`__eq()`)
        - `#range` — compute the range length (`__len()`); supported only since Lua 5.2
        - `range + delta` — translate the range (`__add()`)
        - `range - delta` — translate the range by the negated delta (`__sub()`)
    - `BoundingBox` — an axis-aligned bounding box with closed boundaries:
      - **Serialization**:
        - `schema()` — return the JSON Schema for the class
        - `from_options(options)` — construct a bounding box from a table
        - `__data()` — return a table with the instance fields
        - `__tostring()` — return a string representation of the instance
      - **Factories**:
        - `from_position_and_size(position, size)` — construct a box from its position and size
        - `from_ranges(x_range, y_range)` — construct a box from its horizontal and vertical ranges
        - `union(...)` — return the smallest box containing all input boxes
        - `intersection(...)` — return the common box or `nil` if it is empty
      - **Operations**:
        - `equals(other)` — check exact equality
        - `almost_equals(other, [epsilon])` — check approximate equality within a given epsilon
        - `is_valid()` — check that the minimum is not greater than the maximum on either axis
        - `is_degenerate([axis])` — check whether either or a selected axis has zero length
        - `is_almost_degenerate([epsilon], [axis])` — check whether either or a selected axis has almost zero length
        - `is_point()` — check whether both axes have zero length
        - `is_almost_point([epsilon])` — check whether both axes have almost zero length
        - `position()` — return the top-left position
        - `size()` — return the box size
        - `x_range()` — return the horizontal range
        - `y_range()` — return the vertical range
        - `center()` — compute the center
        - `top_left()` — return the top-left corner
        - `top_right()` — return the top-right corner
        - `bottom_left()` — return the bottom-left corner
        - `bottom_right()` — return the bottom-right corner
        - `overlaps(other)` — check whether the intersection has positive area
        - `contains(value)` — check whether the box contains a vector or another box
        - `clamp(value)` — clamp a vector to the box
        - `lerp(progress)` — interpolate between the corners per axis
        - `inverse_lerp(value)` — compute interpolation progress per axis
        - `wrap(value)` — wrap a vector into the box per axis
        - `random()` — generate a random point in the box
        - `translate(delta)` — translate the box by a `Vector2D`
        - `expand(delta)` — expand the box symmetrically by a number or `Vector2D`
        - `scale(scale)` — scale the box around its center by a non-negative number or `Vector2D`
      - **Operators (via metamethods)**:
        - `==` — check exact equality (`__eq()`)
        - `box + delta` — translate the box (`__add()`)
        - `box - delta` — translate the box by the negated delta (`__sub()`)
    - `Color` — an RGBA color with finite non-negative color channels and normalized alpha:
      - **Serialization**:
        - `schema()` — return the JSON Schema for the class
        - `from_options(options)` — construct a color from a table
        - `__data()` — return a table with the instance fields
        - `__tostring()` — return a string representation of the instance
      - **Constants**:
        - `TRANSPARENT` — (0, 0, 0, 0)
        - `BLACK` — (0, 0, 0, 1)
        - `WHITE` — (1, 1, 1, 1)
        - `RED` — (1, 0, 0, 1)
        - `GREEN` — (0, 1, 0, 1)
        - `BLUE` — (0, 0, 1, 1)
      - **Factories**:
        - `from_bytes(red, green, blue, [alpha])` — construct a color from byte channels
        - `from_hex(value)` — construct a color from hexadecimal notation
      - **Operations**:
        - `equals(other)` — check exact equality
        - `almost_equals(other, [epsilon])` — check approximate equality within a given epsilon
        - `is_valid()` — check that the color channels are finite and non-negative and alpha is normalized
        - `channels([include_alpha])` — return the color channels in RGB or RGBA order
        - `byte_channel(channel)` — return a selected channel as a clamped byte
        - `byte_channels([include_alpha])` — return the color channels as clamped bytes in RGB or RGBA order
        - `with_alpha(alpha)` — return a copy with the specified alpha
        - `clamped()` — return a copy with every channel clamped to the normalized range
        - `to_hex([include_alpha])` — return the color in hexadecimal notation
      - **Operators (via metamethods)**:
        - `==` — check exact equality (`__eq()`)

## Installation

```
$ luarocks install luamath
```

## License

The MIT License (MIT)

Copyright &copy; 2025-2026 thewizardplusplus
