local ls = require 'luasnip'
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local d = ls.dynamic_node
local c = ls.choice_node
local f = ls.function_node
local fmt = require('luasnip.extras.fmt').fmt

local utils = require 'utils.luasnip-latex' -- Import your utilities
-- ls.filetype_extend('quarto', { 'markdown' })

-- This is the key function that creates our recursive structure
local function qa_pair(args, parent, old_state)
  -- Define a snippetNode for a single Q&A pair
  local nodes = {
    t { '', 'Q: ' },
    i(1),
    t { '', 'A: ' },
    i(2),
  }
  -- Add the next dynamic node for continuation
  table.insert(
    nodes,
    d(3, function(args_inner, parent_inner, old_state_inner)
      -- The choice: either stop or continue with another pair
      return sn(nil, {
        c(1, {
          t '', -- Option 1: End recursion
          sn(nil, { -- Option 2: Add another Q&A pair
            d(1, qa_pair, {}),
          }),
        }),
      })
    end, {})
  )
  -- The snippetNode that contains our Q&A pair
  return sn(nil, nodes)
end
ls.add_snippets('markdown', {
  -- Your heading snippets with the condition added
  s('H1', fmt('# {}\n\n{}', { i(1), i(2) }), {
    condition = function()
      return utils.not_in_mathzone()
    end,
  }),
  s('H2', fmt('## {}\n\n{}', { i(1), i(2) }), {
    condition = function()
      return utils.not_in_mathzone()
    end,
  }),
  s('H3', fmt('### {}\n\n{}', { i(1), i(2) }), {
    condition = function()
      return utils.not_in_mathzone()
    end,
  }),
  s('H4', fmt('#### {}\n\n{}', { i(1), i(2) }), {
    condition = function()
      return utils.not_in_mathzone()
    end,
  }),
  s('H5', fmt('##### {}\n\n{}', { i(1), i(2) }), {
    condition = function()
      return utils.not_in_mathzone()
    end,
  }),
  s('H6', fmt('###### {}\n\n{}', { i(1), i(2) }), {
    condition = function()
      return utils.not_in_mathzone()
    end,
  }),
  -- Main Q&A snippet with condition
  s('Aq', {
    t 'Q: ',
    i(1),
    t { '', 'A: ' },
    i(2),
    -- Start the recursion with a dynamic node
    d(3, function(args, parent, old_state)
      return sn(nil, {
        c(1, {
          t '', -- Option 1: Just one Q&A pair
          sn(nil, { -- Option 2: Add more Q&A pairs
            d(1, qa_pair, {}),
          }),
        }),
      })
    end, {}),
  }, {
    condition = function()
      return utils.not_in_mathzone()
    end,
  }),
  s({ trig = '1aq', regTrig = false }, {
    t 'Q: ',
    i(1),
    t '\n',
    t 'A: ',
    i(2),
    t '\n',
    i(0),
  }, {
    condition = function()
      return utils.not_in_mathzone()
    end,
  }),
  s({ trig = '2aq', regTrig = false }, {
    t 'Q: ',
    i(1),
    t '\n',
    t 'A: ',
    i(2),
    t '\n',
    t 'Q: ',
    i(3),
    t '\n',
    t 'A: ',
    i(4),
    t '\n',
    i(0),
  }, {
    condition = function()
      return utils.not_in_mathzone()
    end,
  }),
  s({ trig = '3aq', regTrig = false }, {
    t 'Q: ',
    i(1),
    t '\n',
    t 'A: ',
    i(2),
    t '\n',
    t 'Q: ',
    i(3),
    t '\n',
    t 'A: ',
    i(4),
    t '\n',
    t 'Q: ',
    i(5),
    t '\n',
    t 'A: ',
    i(6),
    t '\n',
    i(0),
  }, {
    condition = function()
      return utils.not_in_mathzone()
    end,
  }),
}, { type = 'autosnippets' })
