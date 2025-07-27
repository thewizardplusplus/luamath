# luamath

[![doc:build](https://github.com/thewizardplusplus/luamath/actions/workflows/doc.yaml/badge.svg)](https://github.com/thewizardplusplus/luamath/actions/workflows/doc.yaml)
[![doc:link](https://img.shields.io/badge/doc%3Alink-link-blue?logo=github)](https://thewizardplusplus.github.io/luamath/)
[![lint](https://github.com/thewizardplusplus/luamath/actions/workflows/lint.yaml/badge.svg)](https://github.com/thewizardplusplus/luamath/actions/workflows/lint.yaml)
[![test](https://github.com/thewizardplusplus/luamath/actions/workflows/test.yaml/badge.svg)](https://github.com/thewizardplusplus/luamath/actions/workflows/test.yaml)
[![luarocks](https://img.shields.io/badge/luarocks-link-blue?logo=lua)](https://luarocks.org/modules/thewizardplusplus/luamath)

The library that implements various auxiliary math classes and functions.

_**Disclaimer:** this library was written directly on an Android smartphone with the ~~[QLua](https://play.google.com/store/apps/details?id=com.quseit.qlua5pro2)~~ [LuaDroid](https://play.google.com/store/apps/details?id=com.alif.ide.lua) IDE._

## Features

- **Classes**:
  - `Vector2D`:
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
    - **Constants**:
      - `ZERO` — zero matrix
      - `IDENTITY` — identity matrix
    - **Operations**:
      - `equals(other)` — check exact equality
      - `almost_equals(other, [epsilon])` — check approximate equality within a given epsilon
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
    - **Transformation matrix factories**:
      - `translate(delta_x, delta_y)` — translation
      - `rotate(angle)` — rotation
      - `scale(scale_x, scale_y)` — scaling
      - `shear(shear_x, shear_y)` — shear

## Installation

```
$ luarocks install luamath
```

## License

The MIT License (MIT)

Copyright &copy; 2025 thewizardplusplus
