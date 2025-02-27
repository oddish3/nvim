
-- Define an autocommand group for Markdown specific triggers
local markdown_augroup = vim.api.nvim_create_augroup('Markdown', { clear = true })

-- Autocommand that triggers when opening Markdown files
vim.api.nvim_create_autocmd('FileType', {
  group = markdown_augroup,
  pattern = 'markdown',
  callback = function()
    -- Define key mappings and other settings specific to Markdown here
    vim.api.nvim_buf_set_keymap(0, 'n', '<leader>an', ':lua create_notes()<CR>', { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(0, 'n', '<leader>ai', ':lua prepare_image()<CR>', { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(0, 'n', '<leader>aI', ':lua view_image()<CR>', { noremap = true, silent = true })
    -- You can also set other Markdown specific settings here
  end,
})

	
vim.cmd [[
function! CreateNotes() abort " {{{1
  " Create notes from list of question/answers
  "
  " <deck>/<tags>
  " Q: ...
  " A: ...
  "
  if getline('.') =~# '^\s*$' | return | endif

  " Avoid folds messing things up
  setlocal nofoldenable

  let l:template = join([
        \ '# Note',
        \ 'model: Basic',
        \ 'deck: {deck}',
        \ 'tags: {tags}',
        \ '',
        \ '## Front',
        \ '{q}',
        \ '',
        \ '## Back',
        \ '{a}',
        \], "\n")

  let l:lnum_start = search('^\n\zs\|\%^', 'ncb')
  if l:lnum_start > line('.')
    let l:lnum_start = line('.')
  endif

  let l:lnum_end = search('\n$\|\%$', 'nc')
  if l:lnum_end - 1 <= l:lnum_start | return | endif

  let l:lines = getline(l:lnum_start, l:lnum_end)

  let l:deck_tags = remove(l:lines, 0)
  let [l:deck, l:tags] = split(l:deck_tags, '/', 1)
  let l:tags = substitute(trim(l:tags), ' ', '-', '')

  let l:current = {}
  let l:list = []
  for l:line in l:lines
    if l:line =~# '^Q:'
      if !empty(l:current)
        call add(l:list, l:current)
        let l:current = {}
      endif
      let l:current.deck = l:deck
      let l:current.tags = l:tags
      let l:current.q = [matchstr(l:line, '^Q: \zs.*')]
      let l:current.pointer = l:current.q
    elseif l:line =~# '^A:'
      let l:current.a = [matchstr(l:line, '^A: \zs.*')]
      let l:current.pointer = l:current.a
    else
      let l:current.pointer += [l:line]
    endif
  endfor

  if !empty(l:current)
    call add(l:list, l:current)
  endif

  if line('$') == l:lnum_end
    call append(line('$'), '')
  endif

  " Remove existing lines
  silent execute l:lnum_start . ',' . l:lnum_end 'd'

  " Add new notes
  for l:e in l:list
    let l:q = escape(join(l:e.q, "\n"), '\')
    let l:a = escape(join(l:e.a, "\n"), '\')

    let l:new = copy(l:template)
    let l:new = substitute(l:new, '{deck}', l:e.deck, 'g')
    let l:new = substitute(l:new, '{tags}', l:e.tags, 'g')
    let l:new = substitute(l:new, '{q}', l:q, 'g')
    let l:new = substitute(l:new, '{a}', l:a, 'g')
    let l:new = substitute(l:new, "  \n", "\n\n", 'g')
    call append(line('.')-1, split(l:new, "\n") + [''])
  endfor
  silent execute line('.') . 'd'

  keepjumps call cursor(l:lnum_start, 1)

  update
endfunction
]]

vim.cmd[[
function! PrepareImage() abort " {{{1
  " Set directory for file input
  let l:dir = '/Users/user/repos/quartz/content/meta/private/'

  " Get origin file
  let l:file = fnamemodify(l:dir . expand('<cfile>'), ':p')
  let l:cursor = filereadable(l:file)
  if !l:cursor
    let l:file = input('File: ', l:dir, 'file')
    if empty(l:file) || !filereadable(l:file) | return | endif
  endif
  echo "Origin file: " . l:file

  " Specify destination file name
  let l:newname = input('Name: ', fnamemodify(l:file, ':t:r'))
  if empty(l:newname) | return | endif
  redraw!

  let l:filename = l:newname . '.' . fnamemodify(l:file, ':e')
  let l:link = printf('![%s](%s)', l:newname, l:filename)
  let l:root = !empty($APY_BASE)
        \ ? $APY_BASE
        \ : '/Users/user/Library/Application Support/Anki2/User 1/collection.media'
  let l:destination = printf('%s/%s', l:root, l:filename)
  echo "Destination file: " . l:destination

  " Check if destination already exists
  if filereadable(l:destination)
    echo 'Destination file exists!'
    echo l:destination
    if input('Overwrite? ') !~? 'y\%[es]\s*$'
      return
    endif
  endif


" Copy file to destination using system command
echo "Copying " . l:file . " to " . l:destination
let l:cmd = printf('cp %s %s', shellescape(l:file), shellescape(l:destination))
call system(l:cmd)

if !filereadable(l:destination)
  echo 'Error: File was not copied'
  echo ' ' l:destination
  return
endif


  " Add link text
  if l:cursor
    " Find next occurrence of any keyword character, enter visual mode till the next occurrence
    call search('\f\+', 'bc')
    normal! v
    call search('\f\+', 'ce')
    normal! "_x
  endif
  " Correctly insert a space followed by the link text
  execute 'silent normal! a ' . l:link . "\<Esc>"
endfunction
]]

vim.cmd [[
function! g:Choose(list) abort
  if len(a:list) == 1
    return a:list[0]
  endif

  while 1
    redraw!
    echohl ModeMsg
    unsilent echo 'Choose an option:'
    echohl None

    let i = 0
    for x in a:list
      let i += 1
      unsilent echo printf('%d: %s', i, x)
    endfor

    try
      let selected = str2nr(input('> ')) - 1
      if selected >= 0 && selected < len(a:list)
        return a:list[selected]
      else
        echom 'Invalid selection, please try again.'
      endif
    catch
      echom 'Error capturing input, please try again.'
    endtry
  endwhile
endfunction
]]

vim.cmd [[
function! ViewImage() abort
  let l:filename = expand('<cfile>')
  let l:root = '/Users/user/Library/Application Support/Anki2/User 1/collection.media'
  let l:files = filter(map([
        \   l:filename,
        \   l:root . '/' . l:filename,
        \ ],
        \ {_, v -> fnamemodify(v, ':p')}),
        \ {_, v -> filereadable(v)})

  if empty(l:files)
    echohl WarningMsg
    echo 'Image not found: '
    echohl None
    echon l:filename
    return
  endif

  let l:file = g:Choose(l:files)
  redraw!

  " Use 'open' command on macOS instead of 'feh'
  silent execute '!open' fnameescape(l:file) '&'
endfunction
]]

-- Define a global Lua function to call the VimScript function
local function create_notes()
  vim.cmd("call CreateNotes()")
end
_G.create_notes = create_notes

local function prepare_image()
  vim.cmd("call PrepareImage()")
end
_G.prepare_image = prepare_image

local function view_image()
    vim.cmd('call ViewImage()')
end
_G.view_image = view_image

-- Define the function to run `apy add-from-file` on the current file
local function RunApyAddFromFile()
    local file_path = vim.fn.expand('%:p')  -- Get the full path of the current file
    local command = 'apy add-from-file ' .. file_path
    vim.cmd('!' .. command)  -- Execute the command in the shell
end

-- Create a global function accessible in the Vim environment
_G.RunApyAddFromFile = RunApyAddFromFile

-- Map the key combination to the Lua function
vim.api.nvim_set_keymap('n', '<leader>ap', ':lua RunApyAddFromFile()<CR>', { noremap = true, silent = true })

