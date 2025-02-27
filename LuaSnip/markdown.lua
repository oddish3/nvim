-- local ls = require("luasnip")
-- return {
--   ls.snippet(
--     {
--       trig="hi1",
--       dscr="An autotriggering snippet that expands 'hi' into 'Hello, world!'",
--       regTrig=false,
--       priority=100,
--       snippetType="autosnippet"
--     },
--     {
--       ls.text_node("Hello, world!"),
--     }
--   )  -- Remove the comma here since it's the only snippet
-- }
local ls = require("luasnip")
local s = ls.s
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

-- Add autosnippets for markdown headings H1-H6 with custom tabstops
ls.add_snippets("markdown", {
  s({ trig = "H1", snippetType = "autosnippet" }, fmt("# {}\n\n{}", { i(1), i(2) })),
  s({ trig = "H2", snippetType = "autosnippet" }, fmt("## {}\n\n{}", { i(1), i(2) })),
  s({ trig = "H3", snippetType = "autosnippet" }, fmt("### {}\n\n{}", { i(1), i(2) })),
  s({ trig = "H4", snippetType = "autosnippet" }, fmt("#### {}\n\n{}", { i(1), i(2) })),
  s({ trig = "H5", snippetType = "autosnippet" }, fmt("##### {}\n\n{}", { i(1), i(2) })),
  s({ trig = "H6", snippetType = "autosnippet" }, fmt("###### {}\n\n{}", { i(1), i(2) })),
}, { type = "autosnippets" })
