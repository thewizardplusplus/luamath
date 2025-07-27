local luaunit = require("luaunit")
local checks = require("luatypechecks.checks")
local Matrix3x3 = require("luamath.matrix3x3")
local Vector2D = require("luamath.vector2d")

-- luacheck: globals TestMatrix3x3
TestMatrix3x3 = {}

-- Matrix3x3.static.translate()
function TestMatrix3x3.test_translate()
  local result = Matrix3x3.translate(5, 7)

  luaunit.assert_equals(result, Matrix3x3:new({
    {1, 0, 5},
    {0, 1, 7},
    {0, 0, 1},
  }))
end

-- Matrix3x3.static.rotate()
function TestMatrix3x3.test_rotate()
  local result = Matrix3x3.rotate(math.pi / 2)

  luaunit.assert_true(result:almost_equals(Matrix3x3:new({
    {0, -1, 0},
    {1, 0, 0},
    {0, 0, 1},
  })))
end

-- Matrix3x3.static.scale()
function TestMatrix3x3.test_scale()
  local result = Matrix3x3.scale(2, 3)

  luaunit.assert_equals(result, Matrix3x3:new({
    {2, 0, 0},
    {0, 3, 0},
    {0, 0, 1},
  }))
end

-- Matrix3x3.static.shear()
function TestMatrix3x3.test_shear()
  local result = Matrix3x3.shear(2, 3)

  luaunit.assert_equals(result, Matrix3x3:new({
    {1, 2, 0},
    {3, 1, 0},
    {0, 0, 1},
  }))
end

-- Matrix3x3:new()
function TestMatrix3x3.test_new()
  local matrix = Matrix3x3:new({
    {1, 2, 3},
    {4, 5, 6},
    {7, 8, 9},
  })

  luaunit.assert_true(checks.is_instance(matrix, Matrix3x3))
  luaunit.assert_equals(matrix.elements, {
    {1, 2, 3},
    {4, 5, 6},
    {7, 8, 9},
  })
end

-- tostring()
function TestMatrix3x3.test_tostring()
  local matrix = Matrix3x3:new({
    {1, 2, 3},
    {4, 5, 6},
    {7, 8, 9},
  })

  local result = tostring(matrix)

  luaunit.assert_equals(result, "{"
    .. [[__name = "Matrix3x3",]]
    .. "elements = { "
      .. "{ 1, 2, 3 }, "
      .. "{ 4, 5, 6 }, "
      .. "{ 7, 8, 9 } "
    .. "}"
  .. "}")
end

-- Matrix3x3:equals()
function TestMatrix3x3.test_equals_method_true()
  local matrix = Matrix3x3:new({
    {1, 2, 3},
    {4, 5, 6},
    {7, 8, 9},
  })
  local other_matrix = Matrix3x3:new({
    {1, 2, 3},
    {4, 5, 6},
    {7, 8, 9},
  })

  local result = matrix:equals(other_matrix)

  luaunit.assert_true(result)
end

function TestMatrix3x3.test_equals_method_false()
  local matrix = Matrix3x3:new({
    {1, 2, 3},
    {4, 5, 6},
    {7, 8, 9},
  })
  local other_matrix = Matrix3x3:new({
    {10, 20, 30},
    {40, 50, 60},
    {70, 80, 90},
  })

  local result = matrix:equals(other_matrix)

  luaunit.assert_false(result)
end

function TestMatrix3x3.test_equals_metamethod_true()
  local matrix = Matrix3x3:new({
    {1, 2, 3},
    {4, 5, 6},
    {7, 8, 9},
  })
  local other_matrix = Matrix3x3:new({
    {1, 2, 3},
    {4, 5, 6},
    {7, 8, 9},
  })

  local result = matrix == other_matrix

  luaunit.assert_true(result)
end

function TestMatrix3x3.test_equals_metamethod_false()
  local matrix = Matrix3x3:new({
    {1, 2, 3},
    {4, 5, 6},
    {7, 8, 9},
  })
  local other_matrix = Matrix3x3:new({
    {10, 20, 30},
    {40, 50, 60},
    {70, 80, 90},
  })

  local result = matrix == other_matrix

  luaunit.assert_false(result)
end

function TestMatrix3x3.test_not_equals_metamethod_true()
  local matrix = Matrix3x3:new({
    {1, 2, 3},
    {4, 5, 6},
    {7, 8, 9},
  })
  local other_matrix = Matrix3x3:new({
    {10, 20, 30},
    {40, 50, 60},
    {70, 80, 90},
  })

  local result = matrix ~= other_matrix

  luaunit.assert_true(result)
end

function TestMatrix3x3.test_not_equals_metamethod_false()
  local matrix = Matrix3x3:new({
    {1, 2, 3},
    {4, 5, 6},
    {7, 8, 9},
  })
  local other_matrix = Matrix3x3:new({
    {1, 2, 3},
    {4, 5, 6},
    {7, 8, 9},
  })

  local result = matrix ~= other_matrix

  luaunit.assert_false(result)
end

function TestMatrix3x3.test_almost_equals_true_with_defaults()
  local matrix = Matrix3x3:new({
    {1.0000001, 2.0000001, 3.0000001},
    {4.0000001, 5.0000001, 6.0000001},
    {7.0000001, 8.0000001, 9.0000001},
  })
  local other_matrix = Matrix3x3:new({
    {1, 2, 3},
    {4, 5, 6},
    {7, 8, 9},
  })

  local result = matrix:almost_equals(other_matrix)

  luaunit.assert_true(result)
end

function TestMatrix3x3.test_almost_equals_true_with_no_defaults()
  local matrix = Matrix3x3:new({
    {1.0000001, 2.0000001, 3.0000001},
    {4.0000001, 5.0000001, 6.0000001},
    {7.0000001, 8.0000001, 9.0000001},
  })
  local other_matrix = Matrix3x3:new({
    {1, 2, 3},
    {4, 5, 6},
    {7, 8, 9},
  })

  local result = matrix:almost_equals(other_matrix, 1e-6)

  luaunit.assert_true(result)
end

function TestMatrix3x3.test_almost_equals_false()
  local matrix = Matrix3x3:new({
    {1.0000001, 2.0000001, 3.0000001},
    {4.0000001, 5.0000001, 6.0000001},
    {7.0000001, 8.0000001, 9.0000001},
  })
  local other_matrix = Matrix3x3:new({
    {1, 2, 3},
    {4, 5, 6},
    {7, 8, 9},
  })

  local result = matrix:almost_equals(other_matrix, 1e-12)

  luaunit.assert_false(result)
end

-- Matrix3x3:add()
function TestMatrix3x3.test_add_method()
  local matrix = Matrix3x3:new({
    {1, 2, 3},
    {4, 5, 6},
    {7, 8, 9},
  })

  local other_matrix = Matrix3x3:new({
    {10, 20, 30},
    {40, 50, 60},
    {70, 80, 90},
  })

  local result = matrix:add(other_matrix)

  luaunit.assert_equals(result, Matrix3x3:new({
    {11, 22, 33},
    {44, 55, 66},
    {77, 88, 99},
  }))
end

function TestMatrix3x3.test_add_metamethod()
  local matrix = Matrix3x3:new({
    {1, 2, 3},
    {4, 5, 6},
    {7, 8, 9},
  })
  local other_matrix = Matrix3x3:new({
    {10, 20, 30},
    {40, 50, 60},
    {70, 80, 90},
  })

  local result = matrix + other_matrix

  luaunit.assert_equals(result, Matrix3x3:new({
    {11, 22, 33},
    {44, 55, 66},
    {77, 88, 99},
  }))
end

-- Matrix3x3:sub()
function TestMatrix3x3.test_sub_method()
  local matrix = Matrix3x3:new({
    {10, 20, 30},
    {40, 50, 60},
    {70, 80, 90},
  })
  local other_matrix = Matrix3x3:new({
    {1, 2, 3},
    {4, 5, 6},
    {7, 8, 9},
  })

  local result = matrix:sub(other_matrix)

  luaunit.assert_equals(result, Matrix3x3:new({
    {9, 18, 27},
    {36, 45, 54},
    {63, 72, 81},
  }))
end

function TestMatrix3x3.test_sub_metamethod()
  local matrix = Matrix3x3:new({
    {10, 20, 30},
    {40, 50, 60},
    {70, 80, 90},
  })
  local other_matrix = Matrix3x3:new({
    {1, 2, 3},
    {4, 5, 6},
    {7, 8, 9},
  })

  local result = matrix - other_matrix

  luaunit.assert_equals(result, Matrix3x3:new({
    {9, 18, 27},
    {36, 45, 54},
    {63, 72, 81},
  }))
end

-- Matrix3x3:mul()
function TestMatrix3x3.test_mul_method_scalar()
  local matrix = Matrix3x3:new({
    {1, 2, 3},
    {4, 5, 6},
    {7, 8, 9},
  })

  local result = matrix:mul(2)

  luaunit.assert_equals(result, Matrix3x3:new({
    {2, 4, 6},
    {8, 10, 12},
    {14, 16, 18},
  }))
end

function TestMatrix3x3.test_mul_method_vector()
  local matrix = Matrix3x3:new({
    {1, 0, 5},
    {0, 1, 6},
    {0, 0, 1},
  })
  local vector = Vector2D:new(2, 3)

  local result = matrix:mul(vector)

  luaunit.assert_equals(result, Vector2D:new(7, 9))
end

function TestMatrix3x3.test_mul_method_matrix()
  local matrix = Matrix3x3:new({
    {1, 2, 3},
    {4, 5, 6},
    {7, 8, 9},
  })
  local other_matrix = Matrix3x3:new({
    {10, 20, 30},
    {40, 50, 60},
    {70, 80, 90},
  })

  local result = matrix:mul(other_matrix)

  luaunit.assert_equals(result, Matrix3x3:new({
    {300, 360, 420},
    {660, 810, 960},
    {1020, 1260, 1500},
  }))
end

function TestMatrix3x3.test_mul_metamethod_matrix_scalar()
  local matrix = Matrix3x3:new({
    {1, 2, 3},
    {4, 5, 6},
    {7, 8, 9},
  })

  local result = matrix * 2

  luaunit.assert_equals(result, Matrix3x3:new({
    {2, 4, 6},
    {8, 10, 12},
    {14, 16, 18},
  }))
end

function TestMatrix3x3.test_mul_metamethod_scalar_matrix()
  local matrix = Matrix3x3:new({
    {1, 2, 3},
    {4, 5, 6},
    {7, 8, 9},
  })

  local result = 2 * matrix

  luaunit.assert_equals(result, Matrix3x3:new({
    {2, 4, 6},
    {8, 10, 12},
    {14, 16, 18},
  }))
end

function TestMatrix3x3.test_mul_metamethod_matrix_vector()
  local matrix = Matrix3x3:new({
    {1, 0, 5},
    {0, 1, 6},
    {0, 0, 1},
  })
  local vector = Vector2D:new(2, 3)

  local result = matrix * vector

  luaunit.assert_equals(result, Vector2D:new(7, 9))
end

function TestMatrix3x3.test_mul_metamethod_vector_matrix()
  local vector = Vector2D:new(2, 3)
  local matrix = Matrix3x3:new({
    {1, 0, 5},
    {0, 1, 6},
    {0, 0, 1},
  })

  local result = vector * matrix

  luaunit.assert_equals(result, Vector2D:new(7, 9))
end

function TestMatrix3x3.test_mul_metamethod_matrix_matrix()
  local matrix = Matrix3x3:new({
    {1, 2, 3},
    {4, 5, 6},
    {7, 8, 9},
  })
  local other_matrix = Matrix3x3:new({
    {10, 20, 30},
    {40, 50, 60},
    {70, 80, 90},
  })

  local result = matrix * other_matrix

  luaunit.assert_equals(result, Matrix3x3:new({
    {300, 360, 420},
    {660, 810, 960},
    {1020, 1260, 1500},
  }))
end

-- Matrix3x3:div()
function TestMatrix3x3.test_div_method()
  local matrix = Matrix3x3:new({
    {2, 4, 6},
    {8, 10, 12},
    {14, 16, 18},
  })

  local result = matrix:div(2)

  luaunit.assert_equals(result, Matrix3x3:new({
    {1, 2, 3},
    {4, 5, 6},
    {7, 8, 9},
  }))
end

function TestMatrix3x3.test_div_metamethod()
  local matrix = Matrix3x3:new({
    {2, 4, 6},
    {8, 10, 12},
    {14, 16, 18},
  })

  local result = matrix / 2

  luaunit.assert_equals(result, Matrix3x3:new({
    {1, 2, 3},
    {4, 5, 6},
    {7, 8, 9},
  }))
end

function TestMatrix3x3.test_div_by_zero()
  local matrix = Matrix3x3:new({
    {2, 4, 6},
    {8, 10, 12},
    {14, 16, 18},
  })

  luaunit.assert_error_msg_contains("division by zero", function()
    matrix:div(0)
  end)
end
