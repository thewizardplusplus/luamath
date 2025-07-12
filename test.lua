-- to support application LuaDroid at the same time as application QLua
package.path =
  package.path
  .. ";/storage/emulated/0/qlua5/share/5.3/?.lua"
  .. ";/storage/emulated/0/qlua5/share/5.3/?/init.lua"

local luaunit = require("luaunit")

for _, module in ipairs({
  "vector2d",
}) do
  require("luamath." .. module .. "_test")
end

os.exit(luaunit.run())
