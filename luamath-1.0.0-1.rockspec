rockspec_format = "3.0"
package = "luamath"
version = "1.0.0-1"
description = {
  summary="The library that implements various auxiliary math classes and functions.",
  license = "MIT",
  maintainer = "thewizardplusplus <thewizardplusplus@yandex.ru>",
  homepage = "https://github.com/thewizardplusplus/luamath",
}
source = {
  url = "git+https://github.com/thewizardplusplus/luamath.git",
  tag = "v1.0.0",
}
dependencies = {
  "lua >= 5.1",
  "middleclass >= 4.1.1, < 5.0",
  "luatypechecks >= 1.3.4, < 2.0",
  "luaserialization >= 1.2.0, < 2.0",
}
test_dependencies = {
  "luaunit >= 3.4, < 4.0",
}
build = {
  type = "builtin",
  modules = {
    ["luamath.vector2d"] = "vector2d.lua",
    ["luamath.vector2d_test"] = "vector2d_test.lua",
    ["luamath.matrix3x3"] = "matrix3x3.lua",
  },
  copy_directories = {
    "doc",
  },
}
