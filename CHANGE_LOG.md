# Change Log

## [v1.2.1](https://github.com/thewizardplusplus/luamath/tree/v1.2.1) (2026-08-30)

Add colors and the `sign()` utility function.

- Add the `Color` class
- Add the `sign()` utility function
- Perform refactoring:
  - Add the `Matrix3x3:inverse()` method
  - Copy mutable inputs passed to constructors and factories
  - Make equality methods return false for incompatible types

## [v1.2.0](https://github.com/thewizardplusplus/luamath/tree/v1.2.0) (2026-08-22)

Add sizes, numeric ranges, bounding boxes, and utility functions.

- Add the `Size`, `Range`, and `BoundingBox` classes
- Add the `round()`, `almost_equal()`, `clamp()`, `lerp()`, `inverse_lerp()`, `wrap()`, and `random_in_range()` utility functions
- Perform refactoring:
  - Add `schema()` and `from_options()` to `Vector2D` and `Matrix3x3`
  - Validate dimensions passed to the `Matrix3x3` constructor

## [v1.1.0](https://github.com/thewizardplusplus/luamath/tree/v1.1.0) (2025-07-27)

Add the `Matrix3x3` class.

- Add the `Matrix3x3` class
- Perform refactoring:
  - Support multiplication by the `Matrix3x3` in the `Vector2D` class

## [v1.0.0](https://github.com/thewizardplusplus/luamath/tree/v1.0.0) (2025-07-12)

Major version. Add the `Vector2D` class.

- Add the `Vector2D` class
