local ls = require 'luasnip'
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local fmt = require('luasnip.extras.fmt').fmt
local rep = require('luasnip.extras').rep

return {
  -- Bold text
  s(
    { trig = 'bold', name = 'Insert bold text', dscr = 'Insert bold text' },
    fmt('**{}**{}', {
      i(1, ls.SELECTION),
      i(0),
    })
  ),

  s({ trig = 'bb', name = 'Bold', dscr = 'Insert bold text' }, { t '**', i(1), t '**', t ' ', i(0) }),

  -- Italic text
  s(
    { trig = 'italic', name = 'Insert italic text', dscr = 'Insert italic text' },
    fmt('*{}*{}', {
      i(1, ls.SELECTION),
      i(0),
    })
  ),

  s({ trig = 'i', name = 'Italic', dscr = 'Insert italic text' }, { t '*', i(1), t '*', t ' ', i(0) }),

  s({ trig = 'bold and italic', name = 'Bold and Italic', dscr = 'Insert bold and italic text' }, { t '***', i(1), t '***', t ' ', i(0) }),
  s({ trig = 'bi', name = 'Bold and Italic', dscr = 'Insert bold and italic text' }, { t '***', i(1), t '***', t ' ', i(0) }),

  -- Quoted text
  s(
    { trig = 'quote', name = 'Insert quoted text', dscr = 'Insert quoted text' },
    fmt('> {}', {
      i(1, ls.SELECTION),
    })
  ),

  -- Inline code
  s(
    { trig = 'code', name = 'Insert inline code', dscr = 'Insert inline code' },
    fmt('`{}`{}', {
      i(1, ls.SELECTION),
      i(0),
    })
  ),

  -- Shortcode
  s(
    { trig = 'shortcode', name = 'Insert shortcode', dscr = 'Insert shortcode' },
    fmt('{{< {} >}}', {
      i(0),
    })
  ),

  -- Fenced code block
  s(
    { trig = 'fenced codeblock', name = 'Insert fenced code block', dscr = 'Insert fenced code block' },
    fmt('```{}\n{}\n```', {
      c(1, {
        t 'python',
        t 'c',
        t 'c++',
        t 'c#',
        t 'ruby',
        t 'go',
        t 'java',
        t 'php',
        t 'htm',
        t 'css',
        t 'javascript',
        t 'json',
        t 'markdown',
        t 'console',
        t 'r',
      }),
      i(0, ls.SELECTION),
    })
  ),

  -- Executable code block
  s(
    { trig = 'executable codeblock', name = 'Insert executable code block', dscr = 'Insert executable code block' },
    fmt('```{{{}}}\n{}\n```', {
      c(1, {
        t 'python',
        t 'r',
        t 'julia',
        t 'ojs',
        t 'sql',
        t 'bash',
      }),
      i(0, ls.SELECTION),
    })
  ),

  -- Raw code block
  s(
    { trig = 'raw codeblock', name = 'Insert raw code block', dscr = 'Insert raw code block' },
    fmt('```{{{}}}\n{}\n```', {
      c(1, {
        t 'html',
        t 'latex',
        t 'openxml',
        t 'opendocument',
        t 'asciidoc',
        t 'docbook',
        t 'markdown',
        t 'dokuwiki',
        t 'fb2',
        t 'gfm',
        t 'haddock',
        t 'icml',
        t 'ipynb',
        t 'jats',
        t 'jira',
        t 'json',
        t 'man',
        t 'mediawiki',
        t 'ms',
        t 'muse',
        t 'opml',
        t 'org',
        t 'plain',
        t 'rst',
        t 'rtf',
        t 'tei',
        t 'texinfo',
        t 'textile',
        t 'xwiki',
        t 'zimwiki',
        t 'native',
        t 'r',
      }),
      i(0, ls.SELECTION),
    })
  ),

  -- Unordered list
  s(
    { trig = 'unordered list', name = 'Insert unordered list', dscr = 'Insert unordered list' },
    fmt(
      [[
- {}
- {}
- {}
{}]],
      {
        i(1, 'first'),
        i(2, 'second'),
        i(3, 'third'),
        i(0),
      }
    )
  ),

  -- Ordered list
  s(
    { trig = 'ordered list', name = 'Insert ordered list', dscr = 'Insert ordered list' },
    fmt(
      [[
1. {}
2. {}
3. {}
{}]],
      {
        i(1, 'first'),
        i(2, 'second'),
        i(3, 'third'),
        i(0),
      }
    )
  ),

  -- Horizontal rule
  s({ trig = 'horizontal rule', name = 'Insert horizontal rule', dscr = 'Insert horizontal rule' }, t '----------\n'),
  -- Task lists
  s({ trig = 'task', name = 'Task', dscr = 'Insert task list' }, { t '- [', c(1, { t ' ', t 'x' }), t '] ', i(2, 'text'), t { '', '' }, i(0) }),
  s({ trig = 'task2', name = 'Task List 2', dscr = 'Insert task list with 2 tasks' }, {
    t '- [',
    c(1, { t ' ', t 'x' }),
    t '] ',
    i(2, 'text'),
    t { '', '' },
    t '- [',
    c(3, { t ' ', t 'x' }),
    t '] ',
    i(4, 'text'),
    t { '', '' },
    i(0),
  }),
  s({ trig = 'task3', name = 'Task List 3', dscr = 'Insert task list with 3 tasks' }, {
    t '- [',
    c(1, { t ' ', t 'x' }),
    t '] ',
    i(2, 'text'),
    t { '', '' },
    t '- [',
    c(3, { t ' ', t 'x' }),
    t '] ',
    i(4, 'text'),
    t { '', '' },
    t '- [',
    c(5, { t ' ', t 'x' }),
    t '] ',
    i(6, 'text'),
    t { '', '' },
    i(0),
  }),
  s({ trig = 'task4', name = 'Task List 4', dscr = 'Insert task list with 4 tasks' }, {
    t '- [',
    c(1, { t ' ', t 'x' }),
    t '] ',
    i(2, 'text'),
    t { '', '' },
    t '- [',
    c(3, { t ' ', t 'x' }),
    t '] ',
    i(4, 'text'),
    t { '', '' },
    t '- [',
    c(5, { t ' ', t 'x' }),
    t '] ',
    i(6, 'text'),
    t { '', '' },
    t '- [',
    c(7, { t ' ', t 'x' }),
    t '] ',
    i(8, 'text'),
    t { '', '' },
    i(0),
  }),
  s({ trig = 'task5', name = 'Task List 5', dscr = 'Insert task list with 5 tasks' }, {
    t '- [',
    c(1, { t ' ', t 'x' }),
    t '] ',
    i(2, 'text'),
    t { '', '' },
    t '- [',
    c(3, { t ' ', t 'x' }),
    t '] ',
    i(4, 'text'),
    t { '', '' },
    t '- [',
    c(5, { t ' ', t 'x' }),
    t '] ',
    i(6, 'text'),
    t { '', '' },
    t '- [',
    c(7, { t ' ', t 'x' }),
    t '] ',
    i(8, 'text'),
    t { '', '' },
    t '- [',
    c(9, { t ' ', t 'x' }),
    t '] ',
    i(10, 'text'),
    t { '', '' },
    i(0),
  }),

  -- Link
  s(
    { trig = 'link', name = 'Insert link', dscr = 'Insert link' },
    fmt('[{}](https://{}){}', {
      i(1, ls.SELECTION),
      i(2, 'link'),
      i(0),
    })
  ),

  -- Image
  s(
    { trig = 'image', name = 'Insert image', dscr = 'Insert image' },
    fmt('![{}](https://{}){}', {
      i(1, ls.SELECTION),
      i(2, 'link'),
      i(0),
    })
  ),

  -- Strikethrough
  s(
    { trig = 'strikethrough', name = 'Insert strikethrough', dscr = 'Insert strikethrough' },
    fmt('~~{}~~', {
      i(1, ls.SELECTION),
    })
  ),

  -- Div block
  s(
    { trig = 'div', name = 'Insert div block', dscr = 'Insert div block' },
    fmt(
      [[::: {{.{}}}
{}
:::]],
      {
        i(1, 'class'),
        i(0, ls.SELECTION),
      }
    )
  ),

  -- Callout block
  s(
    { trig = 'callout', name = 'Insert callout block', dscr = 'Insert callout block' },
    fmt(
      [[::: {{.{}}}
{}
:::]],
      {
        c(1, {
          t 'callout',
          t 'callout-note',
          t 'callout-tip',
          t 'callout-important',
          t 'callout-caution',
          t 'callout-warning',
        }),
        i(0, ls.SELECTION),
      }
    )
  ),

  -- Citation
  s(
    { trig = 'cite', name = 'Insert citation', dscr = 'Insert a citation' },
    fmt('[@{}]', {
      i(1, 'city-key'),
    })
  ),

  -- Inline footnote
  s(
    { trig = 'footnote-inline', name = 'Insert an inline footnote', dscr = 'Insert an inline footnote' },
    fmt('[^{}]', {
      i(1, 'note text'),
    })
  ),

  -- Footnote
  s(
    { trig = 'footnote', name = 'Insert a footnote', dscr = 'Insert an inline footnote' },
    fmt(
      [[
[^{}]
[^{}]: {}]],
      {
        i(1, 'note identifier'),
        rep(1),
        i(2, 'note text'),
      }
    )
  ),

  -- iframe
  s(
    { trig = 'iframe', name = 'Insert iframe', dscr = 'Insert iframe' },
    fmt(
      [[::: {{#fig-{}}}

{}

{}
:::]],
      {
        i(1, 'cap'),
        i(2, 'paste embed info'),
        i(3, 'Caption'),
      }
    )
  ),

  -- tabset
  s(
    { trig = 'tabset', name = 'Insert tabset', dscr = 'Insert tabset' },
    fmt(
      [[:::: {{.panel-tabset}}

### {}

{}

### {}

{}

::::]],
      {
        i(1),
        i(2),
        i(3),
        i(4),
      }
    )
  ),
  -- rcode
  s(
    { trig = 'rco', name = 'Insert R code block', dscr = 'Insert R code block' },
    fmt(
      [[```{{r}}
{}
```]],
      {
        i(1),
      }
    )
  ),
  -- div
  s(
    { trig = 'div', name = 'Insert div', dscr = 'Insert div' },
    fmt(
      [[
::: {{{}}}
{}
:::
    ]],
      {
        i(1),
        i(0),
      }
    )
  ),

  -- figref
  s(
    { trig = 'figref', name = 'Reference figure', dscr = 'Reference figure' },
    fmt('@fig-{}', {
      i(1),
    })
  ),
  s({ trig = 'table', name = 'Table 2x3', dscr = 'Insert table with 2 rows and 3 columns. First row is heading.' }, {
    t '| ',
    i(1, 'Column1'),
    t ' | ',
    i(2, 'Column2'),
    t ' | ',
    i(3, 'Column3'),
    t ' |',
    t { '', '' },
    t '| ------------- | -------------- | -------------- |',
    t { '', '' },
    t '| ',
    i(4, 'Item1'),
    t ' | ',
    i(5, 'Item1'),
    t ' | ',
    i(6, 'Item1'),
    t ' |',
    t { '', '' },
    i(0),
  }),
  s({ trig = 'sub', name = 'Subscript', dscr = 'Create a subscript.' }, { i(1), t '<sub>', i(0) }),
  s({ trig = 'sup', name = 'Superscript', dscr = 'Create a superscript.' }, { i(1), t '<sup>', i(0) }),
  s({ trig = 'note', name = 'Note', dscr = 'Insert Note' }, { t '> [!NOTE]', t { '', '> ' } }),

  s({ trig = 'nn', name = 'Note', dscr = 'Insert Note' }, { t '> [!NOTE]', t { '', '> ' } }),

  s({ trig = 'tip', name = 'Tip', dscr = 'Insert Tip' }, { t '> [!TIP]', t { '', '> ' } }),

  s({ trig = 'tt', name = 'Tip', dscr = 'Insert Tip' }, { t '> [!TIP]', t { '', '> ' } }),

  s({ trig = 'important', name = 'Important', dscr = 'Insert Important' }, { t '> [!IMPORTANT]', t { '', '> ' } }),

  s({ trig = 'imp', name = 'Important', dscr = 'Insert Important' }, { t '> [!IMPORTANT]', t { '', '> ' } }),

  s({ trig = 'warning', name = 'Warning', dscr = 'Insert Warning' }, { t '> [!WARNING]', t { '', '> ' } }),

  s({ trig = 'ww', name = 'Warning', dscr = 'Insert Warning' }, { t '> [!WARNING]', t { '', '> ' } }),

  s({ trig = 'caution', name = 'Caution', dscr = 'Insert Caution' }, { t '> [!CAUTION]', t { '', '> ' } }),

  s({ trig = 'cc', name = 'Caution', dscr = 'Insert Caution' }, { t '> [!CAUTION]', t { '', '> ' } }),

  -- tblref
  s(
    { trig = 'tblref', name = 'Reference table', dscr = 'Reference table' },
    fmt('@tbl-{}', {
      i(1),
    })
  ),

  -- eqnref
  s(
    { trig = 'eqnref', name = 'Reference equation', dscr = 'Reference equation' },
    fmt('@eq-{}', {
      i(1),
    })
  ),

  -- secref
  s(
    { trig = 'secref', name = 'Reference section', dscr = 'Reference section' },
    fmt('@sec-{}', {
      i(1),
    })
  ),

  -- crossref
  s(
    { trig = 'crossref', name = 'Insert crossref YAML', dscr = 'Insert crossref YAML' },
    t [[crossref:
  fig-title: Figure
  tbl-title: Table
  title-delim: .
  fig-prefix: Figure
  tbl-prefix: Table
  eq-prefix: Eq.]]
  ),

  -- fig
  s(
    { trig = 'fig', name = 'Insert figure', dscr = 'Insert figure' },
    fmt('![{}]({}){{\\#fig-{}}}', {
      i(1, 'cap1'),
      i(2, 'figure'),
      i(3),
    })
  ),

  -- background image
  s(
    { trig = 'bgimg', name = 'Insert background image', dscr = 'Insert background image' },
    fmt([[{{data-background-image="{}" background-position=center background-size=contain}}]], {
      i(1),
    })
  ),

  -- background video
  s(
    { trig = 'bgvid', name = 'Insert background video', dscr = 'Insert background video' },
    fmt([[{{background-video="{}" background-size=contain}}]], {
      i(1),
    })
  ),

  -- background iframe
  s(
    { trig = 'bgiframe', name = 'Insert background iframe', dscr = 'Insert background iframe' },
    fmt([[{{background-iframe="{}" background-interactive=true}}]], {
      i(1),
    })
  ),

  -- background color
  s(
    { trig = 'bgcol', name = 'Insert background color', dscr = 'Insert background color' },
    fmt([[{{background-color="{}"}}]], {
      i(1),
    })
  ),

  -- autoanimate
  s({ trig = 'anim', name = 'Insert autoanimate', dscr = 'Insert autoanimate' }, t [[{auto-animate=true}]]),

  -- pull-left
  s(
    { trig = 'pl', name = 'Insert pull-left', dscr = 'Insert pull-left' },
    fmt(
      [[
::: {{.pull-left}}
{}
:::
    ]],
      {
        i(0),
      }
    )
  ),

  -- pull-right
  s(
    { trig = 'pr', name = 'Insert pull-right', dscr = 'Insert pull-right' },
    fmt(
      [[
::: {{.pull-right}}
{}
:::
    ]],
      {
        i(0),
      }
    )
  ),

  -- container
  s(
    { trig = 'con', name = 'Insert container', dscr = 'Insert container' },
    fmt(
      [[
::: {{.container}}
{}
:::
    ]],
      {
        i(1),
      }
    )
  ),

  -- incremental
  s(
    { trig = 'inc', name = 'Insert incremental', dscr = 'Insert incremental' },
    fmt(
      [[
::: {{.incremental}}
-{}
:::
    ]],
      {
        i(1),
      }
    )
  ),

  -- nonincremental
  s(
    { trig = 'noninc', name = 'Insert nonincremental', dscr = 'Insert nonincremental' },
    fmt(
      [[
::: {{.nonincremental}}
-{}
:::
    ]],
      {
        i(1),
      }
    )
  ),

  -- pause
  s({ trig = 'pause', name = 'Insert pause', dscr = 'Insert pause' }, t '. . .'),

  -- 2col
  s(
    { trig = '2col', name = 'Insert 2-column layout', dscr = 'Insert 2-column layout' },
    fmt(
      [[
::: {{.columns}}
::: {{.column width=50%}}
{}
:::
::: {{.column width=50%}}
{}
:::
:::
    ]],
      {
        i(1),
        i(2),
      }
    )
  ),

  -- cols
  s(
    { trig = 'cols', name = 'Insert custom columns', dscr = 'Insert custom columns' },
    fmt(
      [[
::: {{.columns}}
::: {{.column width="{}"}}
{}
:::
::: {{.column width="{}"}}
{}
:::
:::
    ]],
      {
        i(1),
        i(2),
        i(3),
        i(4),
      }
    )
  ),

  -- lay
  s(
    { trig = 'lay', name = 'Insert layout', dscr = 'Insert layout' },
    fmt(
      [[
::: {{layout="[{}]"}}
{}
:::
    ]],
      {
        i(1),
        i(0),
      }
    )
  ),

  -- layout-valign
  s(
    { trig = 'valign', name = 'Insert layout-valign', dscr = 'Insert layout-valign' },
    fmt([[layout-valign="{}"]], {
      i(0),
    })
  ),

  -- callout
  s(
    { trig = 'call', name = 'Insert callout', dscr = 'Insert callout' },
    fmt(
      [[
::: {{.callout-{}}}
{}
:::
    ]],
      {
        i(1),
        i(0),
      }
    )
  ),

  -- col2
  s(
    { trig = 'col2', name = 'Insert 2-column layout', dscr = 'Insert 2-column layout' },
    fmt(
      [[
::: {{layout-ncol=2}}
{}
:::
    ]],
      {
        i(0),
      }
    )
  ),

  -- col3
  s(
    { trig = 'col3', name = 'Insert 3-column layout', dscr = 'Insert 3-column layout' },
    fmt(
      [[
::: {{layout-ncol=3}}
{}
:::
    ]],
      {
        i(0),
      }
    )
  ),

  -- absolute
  s(
    { trig = 'absolute', name = 'Insert absolute positioning', dscr = 'Insert absolute positioning' },
    fmt([[{{.absolute top={} left={} width="{}" height="{}"}}]], {
      i(1),
      i(2),
      i(3),
      i(4),
    })
  ),

  -- width
  s(
    { trig = 'width', name = 'Insert width attribute', dscr = 'Insert width attribute' },
    fmt([[{{width="{}"}}]], {
      i(3),
    })
  ),

  -- hidden
  s({ trig = 'hidden', name = 'Insert hidden attribute', dscr = 'Insert hidden attribute' }, t [[{visibility="hidden"}]]),

  -- uncount
  s({ trig = 'uncount', name = 'Insert uncounted attribute', dscr = 'Insert uncounted attribute' }, t [[{visibility="uncounted"}]]),

  -- align
  s({ trig = 'align', name = 'Insert figure alignment', dscr = 'Insert figure alignment' }, t [[{fig-align="center"}]]),

  -- fragment
  s(
    { trig = 'frag', name = 'Insert fragment', dscr = 'Insert fragment' },
    fmt(
      [[
::: {{.fragment}}
{}
:::
    ]],
      {
        i(0),
      }
    )
  ),

  -- notes
  s(
    { trig = 'notes', name = 'Insert notes', dscr = 'Insert notes' },
    fmt(
      [[
::: {{.notes}}
{}
:::
    ]],
      {
        i(0),
      }
    )
  ),

  -- aside
  s(
    { trig = 'aside', name = 'Insert aside', dscr = 'Insert aside' },
    fmt(
      [[
::: {{.aside}}
{}
:::
    ]],
      {
        i(0),
      }
    )
  ),

  -- alert
  s(
    { trig = 'alert', name = 'Insert alert', dscr = 'Insert alert' },
    fmt([[[{}]{{.alert}}]], {
      i(0),
    })
  ),

  -- importmarkdown
  s({ trig = 'importmd', name = 'Import markdown in Python', dscr = 'Import markdown in Python' }, t 'from IPython.display import display, Markdown'),

  -- pymarkdown
  s(
    { trig = 'pymd', name = 'Python markdown', dscr = 'Python markdown' },
    fmt(
      [[display(Markdown("""
{{{}}}
""".format({} = {})))
    ]],
      {
        i(1),
        rep(1),
        rep(1),
      }
    )
  ),

  -- bibliography
  s({ trig = 'bib', name = 'Insert bibliography', dscr = 'add bibliography yaml' }, t 'bibliography: references.bib'),

  -- diary header
  s(
    { trig = 'diary', name = 'Insert diary header', dscr = 'Add minimal yaml header' },
    fmt(
      [[---
title: "{}"
date: "{}"
categories: [{}]
---]],
      {
        i(1),
        i(2),
        i(3),
      }
    )
  ),

  -- yaml header
  s(
    { trig = 'yml', name = 'Insert YAML header', dscr = 'Add minimal yaml header' },
    fmt(
      [[---
title: {}
format: {}
---]],
      {
        i(1),
        i(2),
      }
    )
  ),

  -- ref a wrap figure
  s(
    { trig = '@wrap', name = 'Reference wrap figure', dscr = 'refer to a label for a wrap figure' },
    fmt('Fig. \\ref{{fig-{}}}', {
      i(1),
    })
  ),
}
