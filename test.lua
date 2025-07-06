local luaunit = require("luaunit")

for _, module in ipairs({
}) do
  require("luamath." .. module .. "_test")
end

os.exit(luaunit.run())
