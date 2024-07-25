local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    {'wbthomason/packer.nvim'},
    {
        'alvan/vim-closetag',
        ft = { 'html', 'xml' },
        config = function()
            vim.g.closetag_filenames = "*.html,*.xml"
        end
    },
    {'jiangmiao/auto-pairs'},
    {
        'skywind3000/asyncrun.vim',
        cmd = 'AsyncRun',
        config = function()
            vim.g.asyncrun_exit='echo "Async Run job completed"'
        end
    },
    {'tpope/vim-commentary'},
    {'tpope/vim-fugitive', cmd = 'Git' },
    {'tpope/vim-repeat'},
    {'tpope/vim-surround'},
    {
        'nvim-tree/nvim-web-devicons',
        lazy = true,
        config = function()
            require('nvim-web-devicons').setup()
        end
    },
    {
        'vim-airline/vim-airline',
        dependencies = { 'vim-airline/vim-airline-themes' },
        init = function()
            vim.g.airline_highlighting_cache = 1
            vim.g.airline_detect_modified = 1
            vim.g.airline_detect_paste = 1
            vim.g.airline_theme = 'tomorrow'
            vim.g.airline_powerline_fonts = 1
        end
    },
    {
        'szw/vim-maximizer',
        cmd = 'MaximizerToggle',
        config = function()
            vim.g.maximizer_default_mapping_key = '<leader>fu'
            vim.g.maximizer_set_mapping_with_bang = 1
        end
    },
    {
        'pappasam/nvim-repl',
        keys = {
            {"<leader>rt", "<cmd>silent ReplOpen<CR>"},
            {"<leader>rc", "<cmd>ReplRunCell<CR>"},
            {"<leader>rr", "<Plug>ReplSendLine"},
            {"<leader>rr", "<Plug>ReplSendLine"},
            {"<leader>rr", "<Plug>ReplSendVisual", mode="v"}
        },
        config = function()
            vim.g.repl_split = 'right'
            vim.g.repl_filetype_commands = {
                python = {
                    'ptpython',
                    '--history-file',
                    '/dev/null',
                    '--config',
                    vim.fn.expand("~/.config/ptpython/repl.py")
                }
            }

            vim.api.nvim_create_autocmd("BufEnter", {
                pattern = "*.py",
                desc = "Set repl split direction based on available space",
                callback = function()
                    if vim.fn.winwidth(0) < 200 then
                        vim.g.repl_split = "bottom"
                    else
                        vim.g.repl_split = "right"
                    end
                end
            })
            vim.api.nvim_create_autocmd("BufEnter", {
                pattern = "*",
                desc = "Control repl buffers",
                callback = function()
                    if vim.opt.buftype:get() ~= "terminal" then
                        return
                    end

                    if vim.fn.winnr("$") == 1 then
                        -- exit repl if it's the only buffer remaining
                        vim.fn.quit()
                    else
                        -- do not allow repls to be replaced with other buffers
                        local buf = vim.fn.bufnr()
                        vim.cmd [[
                            buffer#
                            normal! <C-W>w
                        ]]
                        vim.cmd("buffer " .. buf)
                    end
                end
            })
        end
    },

    {
        'mfussenegger/nvim-dap',
        keys = {
            { '<F5>', function()
                require('dap').continue()
                require('dapui').open()
            end},
            { '<F7>', '<cmd>DapStepInto<CR>' },
            { '<F9>', '<cmd>DapToggleBreakpoint<CR>' },
            { '<F10>', '<cmd>DapStepOver<CR>' },
            { '<F12>', '<cmd>DapTerminate<CR>' },
        },
        config = function()
            local dap = require('dap')
            dap.adapters.python = {
                type = 'executable';
                command = 'python';
                args = { '-m', 'debugpy.adapter' };

            }

            dap.configurations.python = {
                {
                    type = 'python';
                    request = 'launch';
                    name = "Launch file";

                    -- https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings
                    program = "${file}";
                },
                {
                    type = 'python';
                    request = 'launch';
                    name = "-m app.consumer";
                    module = "app.consumer";
                },
                {
                    type = 'python';
                    request = 'launch';
                    name = "-m app.services.main_service";
                    module = "app.services.main_service";
                },
            }

            vim.api.nvim_create_autocmd("FileType", {
                pattern = "dap-repl",
                callback = function()
                    require('dap.ext.autocompl').attach()
                end
            })
        end
    },

    {
        'rcarriga/nvim-dap-ui',
        dependencies = { 'mfussenegger/nvim-dap', 'nvim-neotest/nvim-nio' },
        config = function()
            local dapui = require('dapui')
            dapui.setup {
                layouts = {
                    {
                        elements = {
                            { id = "scopes", size = 0.25 },
                            { id = "stacks", size = 0.25 },
                            { id = "watches", size = 0.25 }
                        },
                        position = "left",
                        size = 40
                    },
                    {
                        elements = {
                            { id = "repl", size = 0.5 },
                            { id = "console", size = 0.5 }
                        },
                        position = "bottom",
                        size = 10
                    }
                },
            }
        end
    },

    {
        'nvim-treesitter/nvim-treesitter',
        build = function()
            require('nvim-treesitter.install').update({ with_sync = true })()
        end,
    },
    {
        'nvim-telescope/telescope.nvim',
        dependencies = {'nvim-lua/plenary.nvim'},
        keys = {
            {  '<leader>/', '<cmd>Telescope live_grep<CR>' },
            {  '<leader>*', '<cmd>Telescope grep_string<CR>' },
            -- { '<C-p>', '<cmd>Telescope find_files<CR>' },
            {  '<leader>go', '<cmd>Telescope jumplist<CR>' },
            {  '<leader>gt', '<cmd>Telescope tags<CR>' },
        },
    },
    {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        config = function()
            require('telescope').load_extension('fzf')
        end
    },
    {
        'nvim-telescope/telescope-fzy-native.nvim',
        config = function()
            require('telescope').load_extension('fzy_native')
        end
    },
    {
        'neovim/nvim-lspconfig'
    },
    {
        'hrsh7th/nvim-cmp',
        dependencies = {
            'neovim/nvim-lspconfig',
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
            'hrsh7th/cmp-cmdline',
            'hrsh7th/nvim-cmp',
            'hrsh7th/cmp-nvim-lsp-signature-help',

            'L3MON4D3/LuaSnip',
            'saadparwaiz1/cmp_luasnip',

            'onsails/lspkind.nvim',
        },
        config = function()
            vim.o.completeopt = 'menuone,noselect'

            local luasnip = require 'luasnip'
            local cmp = require 'cmp'
            local lspkind = require 'lspkind'
            cmp.setup {
                experimental = {
                    ghost_text = { hlgroup = "Comment" }
                },
                snippet = {
                    expand = function(args)
                        require('luasnip').lsp_expand(args.body)
                    end,
                },
                mapping = {
                    ['<C-p>'] = cmp.mapping.select_prev_item(),
                    ['<C-n>'] = cmp.mapping.select_next_item(),
                    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-f>'] = cmp.mapping.scroll_docs(4),
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<C-e>'] = cmp.mapping.close(),
                    ['<CR>'] = cmp.mapping.confirm {
                        behavior = cmp.ConfirmBehavior.Replace,
                        select = true,
                    },
                    ['<Tab>'] = function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end,
                    ['<S-Tab>'] = function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end,
                },
                formatting = {
                    format = lspkind.cmp_format({
                        mode = 'symbol',
                        maxwidth = 70,
                        ellipsis_char = '...',
                        show_labelDetails = true,
                    })
                },
                sources = cmp.config.sources({
                    { name = 'nvim_lsp' },
                    { name = 'luasnip' },
                    { name = 'nvim_lsp_signature_help' },
                })
            }
        end
    },

    -- remember neotest requires the language treesitter parser (:TSInstall python)
    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            "antoinemadec/FixCursorHold.nvim",
            "nvim-neotest/neotest-python",
        },
        keys = {
            { "<leader>tt", "<cmd>Neotest run<CR>" },
            { "<leader>tf", "<cmd>Neotest run file<CR>" },
            -- vim.keymap.set("n", "<leader>ta", function()
            --     for _, adapter_id in ipairs(neotest.run.adapters()) do
            --         neotest.run.run({ suite = true, adapter = adapter_id })
            --     end
            -- end)
            { "<leader>ta", "<cmd>Neotest run all<CR>" },
            { "<leader>tl", "<cmd>Neotest run last<CR>" },
            { "<leader>tp", "<cmd>Neotest summary toggle<CR>" },
            { "<leader>to", "<cmd>Neotest output short=true<CR>" },
        },
        config = function()
            local neotest = require("neotest")
            neotest.setup({
                adapters = {
                    require("neotest-python")({
                        dap = { justMyCode = false },
                    }),
                },
                summary = {
                    mappings = {
                        expand = "l",
                        expand_all = "L",
                        jumpto = "<CR>",
                    },
                },
                icons = {
                    passed = " ",
                    running = " ",
                    failed = " ",
                    unknown = " ",
                    running_animated = vim.tbl_map(function(s)
                        return s .. " "
                    end, { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }),
                },
                -- diagnostic = {
                --     enabled = true,
                -- },
                output = {
                    open_on_run = false,
                },
                -- status = {
                --     enabled = true,
                -- },
                quickfix = {
                    enabled = false,
                },
            })
        end
    },

    {
        'gen740/SmoothCursor.nvim',
        config = function()
            require('smoothcursor').setup({
                disabled_filetypes = { 'neotest-summary' }
            })
        end
    },
    { 'stevearc/dressing.nvim', event = 'VeryLazy' },
    {
        'rcarriga/nvim-notify',
        event = 'VeryLazy',
        config = function()
            vim.notify = require('notify')
            vim.notify.setup {
                render = "compact"
            }
        end
    },

    {
        "danielfalk/smart-open.nvim",
        keys = {
            {'<C-p>', '<cmd>Telescope smart_open cwd_only=true<CR>' },
        },
        config = function()
            require("telescope").load_extension("smart_open")
        end,
        dependencies = {"kkharji/sqlite.lua"}
    },

    {
        "ggandor/leap.nvim",
        config = function()
            require('leap').add_default_mappings()
        end
    },


    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
            "MunifTanjim/nui.nvim",
        },
        keys = {
            { '<leader>.', '<cmd>Neotree focus toggle=true<CR>' },
        },
        config = function()
            vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])

            local neotree = require("neo-tree")
            local command = require("neo-tree.command")
            neotree.setup({
                close_if_last_window = true, -- Close Neo-tree if it is the last window left in the tab
                popup_border_style = "rounded",
                enable_git_status = false,
                enable_diagnostics = false,
                open_files_do_not_replace_types = { "terminal", "trouble", "qf" }, -- when opening files, do not windows containing these filetypes or buftypes
                sort_case_insensitive = false, -- used when sorting files and directories in the tree
                window = {
                    position = "left",
                    width = 35,
                    mappings = {
                        ["q"] = "close_window",
                        ["R"] = "refresh",
                        ["?"] = "show_help",

                        ["o"] = "open",
                        ["O"] = "expand_all_nodes",
                        ["l"] = "open",
                        ["L"] = "expand_all_nodes",
                        ["h"] = "close_node",
                        ["H"] = "close_all_subnodes",

                        ["u"] = "navigate_up",
                        ["C"] = "set_root",
                        ["/"] = "fuzzy_finder",
                        ["<C-h>"] = "toggle_hidden",

                        ["<esc>"] = "revert_preview",
                        ["P"] = { "toggle_preview", config = { use_float = false } },
                        ["go"] = { "toggle_preview", config = { use_float = false } },
                        ["S"] = "open_split",
                        ["s"] = "open_vsplit",
                        ["t"] = "open_tabnew",

                        ["a"] = "add",
                        ["d"] = "delete",
                        ["r"] = "rename",
                        ["y"] = "copy_to_clipboard",
                        ["x"] = "cut_to_clipboard",
                        ["p"] = "paste_from_clipboard",
                        ["c"] = "copy",
                        ["m"] = "move",
                    }
                },
                filesystem = {
                    filtered_items = {
                        visible = false, -- when true, they will just be displayed differently than normal items
                        hide_dotfiles = false,
                        hide_gitignored = true,
                        hide_by_name = {},
                        hide_by_pattern = { -- uses glob style patterns
                        },
                        always_show = { -- remains visible even if other settings would normally hide it
                            --".gitignored",
                        },
                        never_show = { -- remains hidden even if visible is toggled to true, this overrides always_show
                            ".coverage",
                            ".dmypy.json",
                            ".git",
                            ".mypy_cache",
                            ".pytest_cache",
                            ".ropeproject",
                            ".tags",
                            ".tox",
                            ".venv",
                            "__pycache__",
                        },
                        never_show_by_pattern = { -- uses glob style patterns
                            '*.o',
                            '*.pyc',
                            '*.swo',
                            '*.swp',
                            '*.tags',
                            '*.vimsession',
                            '*~',
                        },
                    },
                    follow_current_file = {
                        enabled = true, -- This will find and focus the file in the active buffer every
                    },
                    -- time the current file is changed while the tree is open.
                    group_empty_dirs = true, -- when true, empty folders will be grouped together
                    hijack_netrw_behavior = "open_default", -- netrw disabled, opening a directory opens neo-tree
                    -- in whatever position is specified in window.position
                    -- "open_current",  -- netrw disabled, opening a directory opens within the
                    -- window like netrw would, regardless of window.position
                    -- "disabled",    -- netrw left alone, neo-tree does not handle opening dirs
                    use_libuv_file_watcher = true, -- This will the OS level file watchers to detect changes
                    -- instead of relying on nvim autocmd events.
                },
            })
        end
    },
})
