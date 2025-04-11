local ls = require 'luasnip'
local s = ls.snippet
local i = ls.insert_node
local f = ls.function_node
local t = ls.t -- text node
local fmt = require('luasnip.extras.fmt').fmt

local utils = require 'utils.luasnip-latex' -- Import your utilities

ls.add_snippets('markdown', {
  s({
    trig = '(',
    dscr = 'Parentheses Autopair',
    -- Only trigger if not in comment/string
    condition = utils.not_in_mathzone, -- use the local function
    -- Optional: Higher priority if needed to override other completions
    -- priority = 1100,
  }, {
    t { '(' },
    i(1), -- First tab stop: inside the parentheses
    t { ')' },
    t { ' ' },
    i(0), -- Second tab stop (index 0 is the final position): after the parentheses
  }),

  -- Square Brackets: [ -> [<cursor>] -> []<cursor>
  -- s({
  --   trig = '[',
  --   dscr = 'Square Brackets Autopair',
  --   condition = utils.not_in_mathzone, -- use the local function
  -- }, {
  --   t { '[' },
  --   i(1),
  --   t { ']' },
  --   t { ' ' },
  --   i(0),
  -- }),

  -- Curly Braces (Simple): { -> {<cursor>} -> {}<cursor>
  s({
    trig = '{',
    dscr = 'Curly Braces Autopair',
    condition = utils.not_in_mathzone, -- use the local function
    -- Give slightly lower priority than the block version below if both use '{'
    -- priority = 1000,
  }, {
    t { '{' },
    i(1),
    t { '}' },
    t { ' ' },
    i(0),
  }),

  -- Curly Braces (Block Style): { -> {\n  <cursor>\n} -> {}\n<cursor>
  -- This is often preferred for code blocks.
  -- Note: Triggering might need adjustment (e.g., '{<CR>' or a different trigger)
  -- if you want both simple and block styles available easily.
  -- Or use a condition based on the preceding character (e.g., trigger if '{' follows whitespace/newline)
  s(
    {
      trig = '{', -- Same trigger, rely on priority/condition or user choice in menu
      dscr = 'Curly Braces Block Autopair',
      condition = utils.not_in_mathzone, -- use the local function
      priority = 1100, -- Higher priority to suggest this first in code?
    },
    fmt( -- Use fmt to handle indentation better
      [[
      {{
        {}
      }}
      ]],
      { i(1) }, -- Content node for fmt
      { indent_at = '{' } -- Tell fmt to calculate indentation relative to the line with '{'
    )
    -- If not using fmt or needing simpler version:
    -- {
    --  t {"{"},
    --  t {"\n\t"}, -- NOTE: '\t' is a basic indent, might not respect settings
    --  i(1),      -- Cursor inside, indented
    --  t {"\n}"},
    --  i(0)       -- Cursor after the closing brace
    -- }
  ),

  -- Double Quotes: " -> "<cursor>" -> ""<cursor>
  s({
    trig = '"',
    dscr = 'Double Quotes Autopair',
    -- CRITICAL condition: Avoid triggering inside existing strings/comments
    condition = utils.not_in_mathzone, -- use the local function
  }, {
    t { '"' },
    i(1),
    t { '"' },
    t { ' ' },
    i(0),
  }),

  -- Single Quotes: ' -> '<cursor>' -> ''<cursor>
  s({
    trig = "'",
    dscr = 'Single Quotes Autopair',
    -- CRITICAL condition: Avoid triggering inside existing strings/comments
    condition = utils.not_in_mathzone, -- use the local function
  }, {
    t { "'" },
    i(1),
    t { "'" },
    t { ' ' },
    i(0),
  }),

  -- Backticks: ` -> `<cursor>` -> ``<cursor>
  s({
    trig = '`',
    dscr = 'Backticks Autopair',
    -- CRITICAL condition: Avoid triggering inside existing strings/comments/code blocks
    condition = utils.not_in_mathzone, -- use the local function
  }, {
    t { '`' },
    i(1),
    t { '`' },
    t { ' ' },
    i(0),
  }),
  s(
    {
      trig = '-cl',
      dscr = 'Obsidian Markdown Checklist',
      condition = utils.not_in_mathzone, -- Use the local function
    }, -- Trigger: "-cl", Description for snippet menu
    {
      t { '- [ ] ' }, -- Text to insert
      i(1), -- Place the cursor here (index 1) after inserting the text
    }
  ),
  s(
    {
      trig = '(%d+)pp', -- regex pattern: one or more digits followed by "pp"
      condition = utils.not_in_mathzone, -- Use the local function
      regTrig = true,
      wordTrig = true, -- ensures trigger is matched as a whole word
      name = 'Converts numeric pp to percent',
      dscr = 'Converts numeric pp to percent',
    },
    f(function(args, snip)
      local num = snip.captures[1]
      if num then
        return num .. '%'
      else
        return 'pp'
      end
    end)
  ),

  -- Additional snippet for testing
  s(
    {
      trig = 'Aanki',
      condition = utils.not_in_mathzone, -- Use the local function
      regTrig = false,
    },
    fmt(
      [[
      <!-- anki-cards -->
      {}
      ]],
      { i(1) }
    )
  ),

  s(
    {
      trig = 'Ddeck',
      condition = utils.not_in_mathzone, -- Use the local function
      regTrig = false,
    },

    fmt(
      [[
    {}/{}/{}

    {}
  ]],
      { i(1, 'Basic'), i(2, 'Default'), i(3, 'Tag'), i(4) }
    )
  ),
}, { type = 'autosnippets' })
