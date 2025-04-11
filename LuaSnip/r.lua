local ls = require 'luasnip'
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local d = ls.dynamic_node
local c = ls.choice_node
local fmt = require('luasnip.extras.fmt').fmt

return {
  -- Basic R functions
  s({ trig = 'lib', name = 'library', dscr = 'Load a package with library()' }, fmt('library({})', { i(1, 'package') })),

  s({ trig = 'req', name = 'require', dscr = 'Load a package with require()' }, fmt('require({})', { i(1, 'package') })),

  s({ trig = 'src', name = 'source', dscr = 'Source an R file' }, fmt('source("{}")', { i(1, 'file.R') })),

  s({ trig = 'ret', name = 'return', dscr = 'Return a value' }, fmt('return({})', { i(1, 'code') })),

  s(
    { trig = 'mat', name = 'matrix', dscr = 'Create a matrix' },
    fmt('matrix({}, nrow = {}, ncol = {})', {
      i(1, 'data'),
      i(2, 'rows'),
      i(3, 'cols'),
    })
  ),

  -- S4 methods
  s(
    { trig = 'sg', name = 'setGeneric', dscr = 'Define a generic S4 method' },
    fmt(
      [[
setGeneric("{}", function({}) {{
    standardGeneric("{}")
}})
]],
      {
        i(1, 'generic'),
        i(2, 'x, ...'),
        f(function(args)
          return args[1][1]
        end, { 1 }),
      }
    )
  ),

  s(
    { trig = 'sm', name = 'setMethod', dscr = 'Implement an S4 method' },
    fmt(
      [[
setMethod("{}", {}, function({}) {{
    {}
}})
]],
      {
        i(1, 'generic'),
        i(2, 'class'),
        i(3, 'x, ...'),
        i(0),
      }
    )
  ),

  s(
    { trig = 'sc', name = 'setClass', dscr = 'Define an S4 class' },
    fmt(
      [[
setClass("{}", slots = c({}))
]],
      {
        i(1, 'Class'),
        i(2, 'name = "type"'),
      }
    )
  ),

  -- Control structures
  s(
    { trig = 'if', name = 'if statement', dscr = 'Create an if statement' },
    fmt(
      [[
if ({}) {{
    {}
}}
]],
      {
        i(1, 'condition'),
        i(0),
      }
    )
  ),

  s(
    { trig = 'el', name = 'else statement', dscr = 'Create an else statement' },
    fmt(
      [[
else {{
    {}
}}
]],
      {
        i(0),
      }
    )
  ),

  s(
    { trig = 'ei', name = 'else if statement', dscr = 'Create an else if statement' },
    fmt(
      [[
else if ({}) {{
    {}
}}
]],
      {
        i(1, 'condition'),
        i(0),
      }
    )
  ),

  -- Functions
  s(
    { trig = 'fun', name = 'function', dscr = 'Create a function' },
    fmt(
      [[
{} <- function({}) {{
    {}
}}
]],
      {
        i(1, 'name'),
        i(2, 'variables'),
        i(0),
      }
    )
  ),

  -- Loops
  s(
    { trig = 'for', name = 'for loop', dscr = 'Create a for loop' },
    fmt(
      [[
for ({} in {}) {{
    {}
}}
]],
      {
        i(1, 'variable'),
        i(2, 'vector'),
        i(0),
      }
    )
  ),

  s(
    { trig = 'while', name = 'while loop', dscr = 'Create a while loop' },
    fmt(
      [[
while ({}) {{
    {}
}}
]],
      {
        i(1, 'condition'),
        i(0),
      }
    )
  ),

  -- Other structures
  s(
    { trig = 'switch', name = 'switch statement', dscr = 'Create a switch statement' },
    fmt(
      [[
switch({},
    {} = {}
)
]],
      {
        i(1, 'object'),
        i(2, 'case'),
        i(3, 'action'),
      }
    )
  ),

  -- Apply functions
  s(
    { trig = 'apply', name = 'apply', dscr = 'Apply function over array margins' },
    fmt('apply({}, {}, {})', {
      i(1, 'array'),
      i(2, 'margin'),
      i(3, '...'),
    })
  ),

  s(
    { trig = 'lapply', name = 'lapply', dscr = 'Apply function over a list' },
    fmt('lapply({}, {})', {
      i(1, 'list'),
      i(2, 'function'),
    })
  ),

  s(
    { trig = 'sapply', name = 'sapply', dscr = 'Apply function over a list and simplify' },
    fmt('sapply({}, {})', {
      i(1, 'list'),
      i(2, 'function'),
    })
  ),

  s(
    { trig = 'mapply', name = 'mapply', dscr = 'Apply function to multiple lists' },
    fmt('mapply({}, {})', {
      i(1, 'function'),
      i(2, '...'),
    })
  ),

  s(
    { trig = 'tapply', name = 'tapply', dscr = 'Apply function over a ragged array' },
    fmt('tapply({}, {}, {})', {
      i(1, 'vector'),
      i(2, 'index'),
      i(3, 'function'),
    })
  ),

  s(
    { trig = 'vapply', name = 'vapply', dscr = 'Apply function with value checking' },
    fmt('vapply({}, {}, FUN.VALUE = {}, {})', {
      i(1, 'list'),
      i(2, 'function'),
      i(3, 'type'),
      i(4, '...'),
    })
  ),

  s(
    { trig = 'rapply', name = 'rapply', dscr = 'Apply function recursively to a list' },
    fmt('rapply({}, {})', {
      i(1, 'list'),
      i(2, 'function'),
    })
  ),

  -- Misc
  s(
    { trig = 'ts', name = 'timestamp', dscr = 'Insert timestamp comment' },
    f(function()
      local date = os.date '# %a %b %d %H:%M:%S %Y'
      return date .. ' ------------------------------\n'
    end, {})
  ),

  -- Shiny
  s(
    { trig = 'shinyapp', name = 'shinyapp', dscr = 'Create Shiny app template' },
    fmt(
      [[
library(shiny)

ui <- fluidPage(
  {}
)

server <- function(input, output, session) {{
  
}}

shinyApp(ui, server)
]],
      {
        i(0),
      }
    )
  ),

  s(
    { trig = 'shinymod', name = 'shinymod', dscr = 'Create Shiny module template' },
    fmt(
      [[
{}UI <- function(id) {{
  ns <- NS(id)
  tagList(
    {}
  )
}}

{}Server <- function(id) {{
  moduleServer(id, function(input, output, session) {{
    {}
  }})
}}
]],
      {
        i(1, 'name'),
        i(2),
        f(function(args)
          return args[1][1]
        end, { 1 }),
        i(3),
      }
    )
  ),
}
