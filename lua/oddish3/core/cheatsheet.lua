local cheatsheet = {}

cheatsheet['vimtex'] = {
  {
    mode = 'n',
    keys = 'cim',
    action = [==[:lua _G.my_custom_mappings.ci_dollar()<CR>]==],
    description = 'Various actions'
  },
  {
    mode = 'n',
    keys = 'cam',
    action = [==[:lua _G.my_custom_mappings.ca_dollar()<CR>]==],
    description = 'Various actions'
  },
  {
    mode = 'n',
    keys = 'vim',
    action = [==[:lua _G.my_custom_mappings.vi_dollar()<CR>]==],
    description = 'Various actions'
  },
  {
    mode = 'n',
    keys = 'vam',
    action = [==[:lua _G.my_custom_mappings.va_dollar()<CR>]==],
    description = 'Various actions'
  },
  {
    mode = 'n',
    keys = 'csm',
    action = [==['<Plug>(vimtex-env-change-math)']==],
    description = 'Various actions'
  },
  {
    mode = 'n',
    keys = 'dsm',
    action = [==['<Plug>(vimtex-env-delete-math)']==],
    description = 'Various actions'
  },
  {
    mode = 'n',
    keys = 'dam',
    action = [==['<Plug>(vimtex-delim-delete-math)']==],
    description = 'Various actions'
  },
  {
    mode = 'n',
    keys = 'dim',
    action = [==['<Plug>(vimtex-delim-change-math)']==],
    description = 'Various actions'
  },
  {
    mode = 'n',
    keys = 'tsm',
    action = [==['<Plug>(vimtex-env-toggle-math)']==],
    description = 'Various actions'
  },
  {
    mode = 'v',
    keys = 'J',
    action = [==[":m '>+1<CR>gv=gv"]==],
    description = 'Various actions'
  },
  {
    mode = 'v',
    keys = 'K',
    action = [==[":m '<-2<CR>gv=gv"]==],
    description = 'Various actions'
  },
  {
    mode = 'n',
    keys = 'J',
    action = [==["mzJ`z"]==],
    description = 'Various actions'
  },
  {
    mode = 'n',
    keys = '<C-d>',
    action = [==["<C-d>zz"]==],
    description = 'Various actions'
  },
  {
    mode = 'n',
    keys = '<C-u>',
    action = [==["<C-u>zz"]==],
    description = 'Various actions'
  },
  {
    mode = 'n',
    keys = 'n',
    action = [==["nzzzv"]==],
    description = 'Various actions'
  },
  {
    mode = 'n',
    keys = 'N',
    action = [==["Nzzzv"]==],
    description = 'Various actions'
  },
  {
    mode = 'n',
    keys = 'Q',
    action = [==["<nop>"]==],
    description = 'Various actions'
  },
  {
    mode = 'n',
    keys = '<C-d>',
    action = [==["<C-d>zz"]==],
    description = 'Various actions'
  },
  {
    mode = 'n',
    keys = '<C-u>',
    action = [==["<C-u>zz"]==],
    description = 'Various actions'
  },
  {
    mode = 'n',
    keys = 'n',
    action = [==["nzzzv"]==],
    description = 'Various actions'
  },
  {
    mode = 'n',
    keys = 'N',
    action = [==["Nzzzv"]==],
    description = 'Various actions'
  },
  {
    mode = 'x',
    keys = '<leader>p',
    action = [==[[["_dP]]]==],
    description = 'Various actions'
  },
  {
    mode = 'n',
    keys = '<leader>Y',
    action = [==[[["+Y]]]==],
    description = 'Various actions'
  },
  {
    mode = 'i',
    keys = '<C-c>',
    action = [==["<Esc>"]==],
    description = 'Various actions'
  },
  {
    mode = 'n',
    keys = '<leader>x',
    action = [==["<cmd>!chmod +x %<CR>"]==],
    description = 'Various actions'
  },
  {
    mode = 'n',
    keys = '<C-k>',
    action = [==["<cmd>cnext<CR>zz"]==],
    description = 'Various actions'
  },
  {
    mode = 'n',
    keys = '<C-j>',
    action = [==["<cmd>cprev<CR>zz"]==],
    description = 'Various actions'
  },
  {
    mode = 'n',
    keys = '<leader>k',
    action = [==["<cmd>lnext<CR>zz"]==],
    description = 'Various actions'
  },
  {
    mode = 'n',
    keys = '<leader>j',
    action = [==["<cmd>lprev<CR>zz"]==],
    description = 'Various actions'
  },
  {
    mode = 'n',
    keys = '<leader>s',
    action = [==[[[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]]]==],
    description = 'Various actions'
  },
  {
    mode = 'n',
    keys = '<leader>r',
    action = [==[[[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gci<Left><Left><Left>]]]==],
    description = 'Various actions'
  },
}

cheatsheet['Telescope Mappings'] = {
  {
    mode = 'n',
    keys = '<leader>ff',
    action = [==["<cmd>Telescope find_files<cr>"]==],
    description = 'Fuzzy find files in cwd'
  },
  {
    mode = 'n',
    keys = '<leader>fr',
    action = [==["<cmd>Telescope oldfiles<cr>"]==],
    description = 'Fuzzy find recent files'
  },
  {
    mode = 'n',
    keys = '<leader>fs',
    action = [==["<cmd>Telescope live_grep<cr>"]==],
    description = 'Find string in cwd'
  },
  {
    mode = 'n',
    keys = '<leader>fc',
    action = [==["<cmd>Telescope grep_string<cr>"]==],
    description = 'Find string under cursor in cwd'
  },
  {
    mode = 'n',
    keys = '<leader>fg',
    action = [==[customTelescope.CustomLiveGrep]==],
    description = 'Custom Live Grep'
  },
}

cheatsheet['harpoon'] = {
  {
    mode = 'n',
    keys = '<ffb>',
    action = [==['<cmd>lua require("oddish3.utils.harpoon-telescope").search_marks()<CR>']==],
    description = 'Various actions'
  },
  {
    mode = 'n',
    keys = '<leader>hn',
    action = [==["<cmd>lua require('harpoon.ui').nav_next()<cr>"]==],
    description = 'Go to next harpoon mark'
  },
}

cheatsheet['tab navigation '] = {
  {
    mode = 'n',
    keys = '<leader>tn',
    action = [==[':tabnew<CR>']==],
    description = 'Open a new tab'
  },
  {
    mode = 'n',
    keys = '<leader>tc',
    action = [==[':tabclose<CR>']==],
    description = 'Close the current tab'
  },
  {
    mode = 'n',
    keys = '<leader>tl',
    action = [==[':tabnext<CR>']==],
    description = 'Go to the next tab'
  },
  {
    mode = 'n',
    keys = '<leader>th',
    action = [==[':tabprev<CR>']==],
    description = 'Go to the previous tab'
  },
}

cheatsheet['spelling'] = {
  {
    mode = 'i',
    keys = '<C-l>',
    action = [==[<c-g>u<Esc>[s1z=`]a<c-g>u]==],
    description = 'Various actions'
  },
  {
    mode = 'i',
    keys = '<C-f>',
    action = [==[<ESC>:lua _G.spell_suggest_last_error()<CR>]==],
    description = 'Various actions'
  },
  {
    mode = 'n',
    keys = '<C-i>',
    action = [==[telescope_spell_suggest]==],
    description = 'Spelling Suggestions'
  },
}

cheatsheet['autocapitalisation '] = {
  {
    mode = 'v',
    keys = '<leader>c',
    action = [==[<Esc>:lua _G.capitalizeSelection()<CR>]==],
    description = 'Various actions'
  },
  {
    mode = 'n',
    keys = 'CC',
    action = [==[:lua capitalizeTitlesAndItems()<CR>]==],
    description = 'Various actions'
  },
}

cheatsheet['misc'] = {
  {
    mode = 'n',
    keys = '<leader>tc',
    action = [==[:VimtexTocToggle<CR>]==],
    description = 'Various actions'
  },
}

cheatsheet['nvim tree'] = {
  {
    mode = 'n',
    keys = '<leader>pv',
    action = [==[:NvimTreeToggle<CR>]==],
    description = 'Various actions'
  },
  {
    mode = 'n',
    keys = '<C-t>',
    action = [==["<cmd>silent !tmux neww ~/scripts/nvim/tmux-sessionizer.sh<CR>"]==],
    description = 'Various actions'
  },
}

cheatsheet['Alpha dashboard'] = {
  {
    mode = 'n',
    keys = 'zz',
    action = [==[:Alpha<CR>]==],
    description = 'Various actions'
  },
}

cheatsheet['toggle term'] = {
  {
    mode = 'n',
    keys = '<C-Enter>',
    action = [==[:ToggleTermSendCurrentLine<CR>:execute "normal! j"<CR>]==],
    description = 'Various actions'
  },
  {
    mode = 'v',
    keys = '<C-A-Enter>',
    action = [==[:ToggleTermSendVisualLines<CR>]==],
    description = 'Various actions'
  },
  {
    mode = 'x',
    keys = '<Leader>ts',
    action = [==[:ToggleTermSendVisualSelection<CR>]==],
    description = 'Various actions'
  },
  {
    mode = 'n',
    keys = '<Leader>tr',
    action = [==[<cmd>lua _R_TOGGLE()<CR>]==],
    description = 'Various actions'
  },
  {
    mode = 'n',
    keys = '<Leader>tp',
    action = [==[<cmd>lua _PYTHON_TOGGLE()<CR>]==],
    description = 'Various actions'
  },
}

return cheatsheet
