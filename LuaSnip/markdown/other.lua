local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt 

ls.add_snippets("markdown", {
  s({ 
      trig = "(%d+)pp",      -- regex pattern: one or more digits followed by "pp"
      regTrig = true,
      wordTrig = true,       -- ensures trigger is matched as a whole word
      name = "Converts numeric pp to percent", 
      dscr = "Converts numeric pp to percent" 
    },
    f(function(args, snip)
      local num = snip.captures[1]
      if num then
        return num .. "%"
      else
        return "pp"
      end
    end)
  ),
  
  -- Additional snippet for testing
  s({trig = "Aanki", regTrig = false},
    fmt(
      [[
      <!-- anki-cards -->
      {}
      ]],
      { i(1) }
    )
  ),
}, { type = "autosnippets" })
