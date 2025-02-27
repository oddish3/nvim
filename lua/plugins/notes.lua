-- plugins for notetaking and knowledge management

return {
  {
    "ggandor/leap.nvim",
        -- enabled = false,
    lazy = false
  },
  {
    "OXY2DEV/markview.nvim",
      -- enabled = false,
    lazy = false
  },
{
  'preservim/vim-markdown',
      enabled = false,
},
  {
  "iamcco/markdown-preview.nvim",
            -- enabled = false,
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  build = "cd app && yarn install",
  init = function()
    vim.g.mkdp_filetypes = { "markdown" }
  end,
  ft = { "markdown" },
},
  {
  "jalvesaq/zotcite",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-telescope/telescope.nvim",
  },
  lazy = false,
  config = function()
    vim.defer_fn(function()
      require("zotcite").setup({})
    end, 100) -- Delay setup slightly
  end,
},
  {
    'jakewvincent/mkdnflow.nvim',
    enabled = false,
    config = function()
      local mkdnflow = require 'mkdnflow'
      mkdnflow.setup {}
    end,
  },
  {
    "epwalsh/obsidian.nvim",
    -- enabled = false, 
    version = "*", -- recommended, use latest release instead of latest commit
    lazy = true,
    ft = { "markdown", "quarto" },
    -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
    -- event = {
    --   -- If you want to use the home shortcut '~', here you need to call 'vim.fn.expand'.
    --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
    --   -- refer to `:h file-pattern` for more examples
    --   "BufReadPre path/to/my-vault/*.md",
    --   "BufNewFile path/to/my-vault/*.md",
    -- },
    dependencies = {
      -- Required.
      "nvim-lua/plenary.nvim",
      "hrsh7th/nvim-cmp",
      "nvim-telescope/telescope.nvim",
      "nvim-treesitter/nvim-treesitter"
      -- see below for full list of optional dependencies 👇
    },
    config = function(_, opts)
      -- Setup obsidian.nvim
      require("obsidian").setup(opts)
    end, 
    opts = {
      workspaces = {
        {
          name = "Digital Garden",
          path = "/Users/user/repos/quartz/content",
        },
      },
      -- see below for full list of options 👇
      daily_notes = {
        folder = "daily/",
      },
      completion = {
        -- Set to false to disable completion.
        nvim_cmp = true,
        -- Trigger completion at 2 chars.
        min_chars = 2,
      },
      templates = {
        folder = "/Users/user/vault/templates",
      },
      ui = {
    enable = false,
      },
      -- Optional, configure key mappings. These are the defaults. If you don't want to set any keymappings this
      -- way then set 'mappings = {}'.
      mappings = {
        -- Overrides the 'gf' mapping to work on markdown/wiki links within your vault.
        ["gf"] = {
          action = function()
            return require("obsidian").util.gf_passthrough()
          end,
          opts = { noremap = false, expr = true, buffer = true },
        },
        -- Toggle check-boxes.
        ["<leader>ch"] = {
          action = function()
            return require("obsidian").util.toggle_checkbox()
          end,
          opts = { buffer = true },
        },
        -- Smart action depending on context, either follow link or toggle checkbox.
        -- ["<cr>"] = {
        --   action = function()
        --     return require("obsidian").util.smart_action()
        --   end,
        --   opts = { buffer = true, expr = true },
        -- }
      },

      -- Optional, customize how note IDs are generated given an optional title.
      ---@param title string|nil
      ---@return string
      note_id_func = function(title)
        if title ~= nil then
          -- Transform the title into a valid, slugified file name.
          local slug = title
            :gsub("%s+", "-")              -- Replace spaces with hyphens
            :gsub("[^A-Za-z0-9%-]", "")    -- Remove non-alphanumeric characters except hyphens
            :lower()
          return slug
        else
          -- If no title is provided, generate a unique identifier using a UUID or random string.
          local suffix = ""
          for _ = 1, 6 do  -- Increased length for better uniqueness
            suffix = suffix .. string.char(math.random(97, 122))  -- a-z
          end
          return "note-" .. suffix
        end
      end,

      -- Optional, customize how note file names are generated given the ID, target directory, and title.
      ---@param spec { id: string, dir: obsidian.Path, title: string|nil }
      ---@return string|obsidian.Path The full path to the new note.
      note_path_func = function(spec)
        local base_dir = spec.dir
        
        -- Optional: Determine subdirectories based on categories or other metadata.
        -- For simplicity, we'll assume all notes go into a 'Evergreen' folder.
        local evergreen_dir = base_dir 
        
        -- Ensure the Evergreen directory exists.
        -- You might need to add code here to create the directory if it doesn't exist.
        
        -- Create the full path with the slugified ID and .md extension.
        local path = evergreen_dir / tostring(spec.id)
        
        return path:with_suffix(".md")
      end,

      -- Optional, customize how note file names are generated given the ID, target directory, and title.
      --@param spec { id: string, dir: obsidian.Path, title: string|? }
      --@return string|obsidian.Path The full path to the new note.
      -- note_path_func = function(spec)
      --   -- This is equivalent to the default behavior.
      --   local path = spec.dir / tostring(spec.id)
      --   return path:with_suffix(".md")
      -- end,
      --
      -- -- Optional, customize how wiki links are formatted. You can set this to one of:
      -- --  * "use_alias_only", e.g. '[[Foo Bar]]'
      -- --  * "prepend_note_id", e.g. '[[foo-bar|Foo Bar]]'
      -- --  * "prepend_note_path", e.g. '[[foo-bar.md|Foo Bar]]'
      -- --  * "use_path_only", e.g. '[[foo-bar.md]]'
      -- -- Or you can set it to a function that takes a table of options and returns a string, like this:
      -- wiki_link_func = function(opts)
      --   return require("obsidian.util").wiki_link_id_prefix(opts)
      -- end,
      --
      -- -- Optional, customize how markdown links are formatted.
      -- markdown_link_func = function(opts)
      --   return require("obsidian.util").markdown_link(opts)
      -- end,
      -- Optional, boolean or a function that takes a filename and returns a boolean.
      -- `true` indicates that you don't want obsidian.nvim to manage frontmatter.
      disable_frontmatter = false,

      -- Optional, alternatively you can customize the frontmatter data.
      ---@return table
      note_frontmatter_func = function(note)
        -- Add the title of the note as an alias if it exists
        if note.title then
          note:add_alias(note.title)
        end

        -- Get file stats using the correct path
        local file_info = vim.loop.fs_stat(note.path.filename)
        -- Get the seconds from the timestamp tables
        local current_time = (file_info and file_info.mtime and file_info.mtime.sec) or os.time()

        -- Create a normalized title from the ID
        local normalized_title = note.id:gsub("-", " "):gsub("^%l", string.upper):gsub("%s%l", string.upper)

        -- Initialize with core fields
        local out = {
          id = note.id,
          title = normalized_title,  -- Add the normalized title here
          aliases = note.aliases,
          tags = note.tags,
          draft = true
        }

        -- Add any custom metadata fields from the note
        if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
          for k, v in pairs(note.metadata) do
            out[k] = v
          end
        end

        -- Check if Creation Date already exists in metadata
        if note.metadata and note.metadata["Creation Date"] then
          -- Use existing Creation Date
          out["Creation Date"] = note.metadata["Creation Date"]
        else
          -- Set new Creation Date only if it doesn't exist
          out["Creation Date"] = os.date("%Y-%m-%dT%H:%M:%S", current_time)
        end

        -- Always update Last Date
        out["Last Date"] = os.date("%Y-%m-%dT%H", current_time)

        return out
      end,

      -- Optional, by default when you use `:ObsidianFollowLink` on a link to an external
      -- URL it will be ignored but you can customize this behavior here.
      -- @param url string
      -- follow_url_func = function(url)
      --   -- Open the URL in the default web browser.
      --   vim.fn.jobstart({"open", url})  -- Mac OS
      --   -- vim.fn.jobstart({"xdg-open", url})  -- linux
      --   -- vim.cmd(':silent exec "!start ' .. url .. '"') -- Windows
      --   -- vim.ui.open(url) -- need Neovim 0.10.0+
      -- end,

      -- Optional, by default when you use `:ObsidianFollowLink` on a link to an image
      -- file it will be ignored but you can customize this behavior here.
      ---@param img string
      follow_img_func = function(img)
        print("Image path: " .. img)
        vim.fn.jobstart { "qlmanage", "-p", img }  -- Mac OS quick look preview
        -- vim.fn.jobstart({"xdg-open", url})  -- linux
        -- vim.cmd(':silent exec "!start ' .. url .. '"') -- Windows
      end,

      -- picker = {
      --   -- Set your preferred picker. Can be one of 'telescope.nvim', 'fzf-lua', or 'mini.pick'.
      --   name = "telescope.nvim",
      --   -- Optional, configure key mappings for the picker. These are the defaults.
      --   -- Not all pickers support all mappings.
      --   note_mappings = {
      --     -- Create a new note from your query.
      --     new = "<C-x>",
      --     -- Insert a link to the selected note.
      --     insert_link = "<C-l>",
      --   },
      --   tag_mappings = {
      --     -- Add tag(s) to current note.
      --     tag_note = "<C-x>",
      --     -- Insert a tag at the current location.
      --     insert_tag = "<C-l>",
      --   },
      -- },

      -- Specify how to handle attachments.
      attachments = {
    -- The default folder to place images in via `:ObsidianPasteImg`.
    -- If this is a relative path it will be interpreted as relative to the vault root.
    -- You can always override this per image by passing a full path to the command instead of just a filename.
    img_folder = "assets/imgs",  -- This is the default

    -- Optional, customize the default name or prefix when pasting images via `:ObsidianPasteImg`.
    ---@return string
    img_name_func = function()
      -- Prefix image names with timestamp.
      return string.format("%s-", os.time())
    end,

    -- A function that determines the text to insert in the note when pasting an image.
    -- It takes two arguments, the `obsidian.Client` and an `obsidian.Path` to the image file.
    -- This is the default implementation.
    ---@param client obsidian.Client
    ---@param path obsidian.Path the absolute path to the image file
    ---@return string
    img_text_func = function(client, path)
      path = client:vault_relative_path(path) or path
      return string.format("![%s](%s)", path.name, path)
    end,
  },
    }
  }
}
