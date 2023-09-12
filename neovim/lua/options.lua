vim.g.mapleader = ","

-- general options
vim.opt.autowrite = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.clipboard = "unnamedplus"  -- use system clibpoard
vim.opt.gdefault = true            -- use /g in substitute commands
vim.opt.mouse = ""                 -- disable mouse
vim.opt.scrolloff = 2              -- number of lines to show above the cursor when scrolling
vim.opt.shell = "bash"             -- for external commands run with :!
vim.opt.showtabline = 2            -- always display the tabline
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.wildmode = { "list:longest", "list:full" }

if vim.opt.modifiable:get() then
    vim.opt.fileencoding = 'utf-8'
end

if vim.fn.has('termguicolors') and os.getenv("TERM") ~= "rxvt-unicode" then
    vim.opt.termguicolors = true
end

-- search options
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.infercase = true

-- show line numbers
vim.opt.number = true
vim.api.nvim_set_hl(0, "CursorLineNr", {})
vim.api.nvim_create_autocmd("TermOpen", {
    pattern = "*",
    desc = "Disable line numbers in terminals",
    callback = function()
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
    end
})

-- indentation
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true

-- backup and temporary files
vim.opt.undofile = true
vim.opt.backup = true
vim.opt.swapfile = true
vim.opt.backupskip = "/tmp/*"  -- don't create backups for files under /tmp/
vim.opt.backupdir = vim.fn.stdpath('state') .. '/backup'

-- built in plugins
vim.g.loaded_syntastic_plugin = 1  -- disable syntastic (it's builtin to ArchLinux)

vim.g.netrw_browse_split = 3  -- open files in a new tab
vim.g.netrw_altv = 1           -- open vertical splits to the right
vim.g.netrw_alto = 1           -- open horizontal splits below
 -- vim.g.netrw_banner = 0       -- disable annoying banner
vim.g.netrw_liststyle = 3       -- tree style view

-- tags
vim.opt.tags={".tags", "tags"}
