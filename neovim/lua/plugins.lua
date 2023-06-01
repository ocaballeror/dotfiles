local packerdir = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
local packerinstall = false

if vim.fn.isdirectory(packerdir) == 0 then
    packerinstall = true
    os.execute("mkdir -p " .. packerdir)
    os.execute("git clone -qq https://github.com/wbthomason/packer.nvim " .. packerdir)
    vim.cmd.packloadall()
end

require('packer').startup(function(use)
    use 'wbthomason/packer.nvim'

    use {'alvan/vim-closetag', ft = 'html'}
    use 'easymotion/vim-easymotion'
    use 'flazz/vim-colorschemes'
    use 'jiangmiao/auto-pairs'
    use 'PotatoesMaster/i3-vim-syntax'
    use {'skywind3000/asyncrun.vim', cmd = 'AsyncRun' }
    use 'tpope/vim-commentary'
    use {'tpope/vim-fugitive', cmd = 'Git' }
    use 'tpope/vim-repeat'
    use 'tpope/vim-surround'
    use 'vim-airline/vim-airline'
    use 'vim-airline/vim-airline-themes'
    use {'szw/vim-maximizer', cmd = 'MaximizerToggle' }
    use 'ryanoasis/vim-devicons'
    use 'pappasam/nvim-repl'
    use {
        'mfussenegger/nvim-dap',
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
                    name = "Run consumer";

                    -- https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings
                    module = "app.consumer";
                },
            }

            vim.api.nvim_create_autocmd("FileType", {
                pattern = "dap-repl",
                callback = function()
                    require('dap.ext.autocompl').attach()
                end
            })

            vim.keymap.set('n', '<F5>', function()
                dap.continue()
                require('dapui').open()
            end)
            vim.keymap.set('n', '<F9>', dap.toggle_breakpoint)
            vim.keymap.set('n', '<F10>', dap.step_over)
            vim.keymap.set('n', '<F11>', dap.step_into)
            vim.keymap.set('n', '<F12>', dap.step_out)
        end
    }

    use {
        'rcarriga/nvim-dap-ui',
        requires = { 'mfussenegger/nvim-dap' },
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
    }

    use {
        'nvim-treesitter/nvim-treesitter',
        run = function()
            require('nvim-treesitter.install').update({ with_sync = true })()
        end,
    }
    use {
        'nvim-telescope/telescope.nvim',
        requires = {'nvim-lua/plenary.nvim'},
        config = function()
            local builtin = require('telescope.builtin')
            vim.keymap.set('n', '<leader>/', builtin.live_grep)
            vim.keymap.set('n', '<leader>*', builtin.grep_string)
            -- vim.keymap.set('n', '<C-p>', builtin.find_files)
            vim.keymap.set('n', '<leader>go', builtin.jumplist)
            vim.keymap.set('n', '<leader>gt', builtin.tags)
        end
    }

    use {
        'neovim/nvim-lspconfig'
    }

    use {
        'hrsh7th/nvim-cmp',
        requires = {
            'neovim/nvim-lspconfig',
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
            'hrsh7th/cmp-cmdline',
            'hrsh7th/nvim-cmp',

            'L3MON4D3/LuaSnip',
            'saadparwaiz1/cmp_luasnip',
        },
        config = function()
            vim.o.completeopt = 'menuone,noselect'

            local luasnip = require 'luasnip'
            local cmp = require 'cmp'
            cmp.setup {
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
                sources = {
                    { name = 'nvim_lsp' },
                    { name = 'luasnip' },
                },
            }
        end
    }

    use {
        "nvim-neotest/neotest",
        requires = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            "nvim-neotest/neotest-python",
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
            vim.keymap.set("n", "<leader>tt", function()
                neotest.run.run({})
            end)
            vim.keymap.set("n", "<leader>tf", function()
                neotest.run.run({ vim.api.nvim_buf_get_name(0) })
            end)
            vim.keymap.set("n", "<leader>ta", function()
                for _, adapter_id in ipairs(neotest.run.adapters()) do
                    neotest.run.run({ suite = true, adapter = adapter_id })
                end
            end)
            vim.keymap.set("n", "<leader>tl", function()
                neotest.run.run_last()
            end)
            vim.keymap.set("n", "<leader>td", function()
                neotest.run.run({ strategy = "dap" })
            end)
            vim.keymap.set("n", "<leader>tp", function()
                neotest.summary.toggle()
            end)
            vim.keymap.set("n", "<leader>to", function()
                neotest.output.open({ short = true })
            end)
        end
    }

    use {
        'gen740/SmoothCursor.nvim',
        config = function()
            require('smoothcursor').setup({
                disabled_filetypes = { 'neotest-summary' }
            })
        end
    }
    use {
        'stevearc/dressing.nvim'
    }

    use {
        'rcarriga/nvim-notify',
        config = function()
            vim.notify = require('notify')
            vim.notify.setup {
                render = "compact"
            }
        end
    }

    use {
        "danielfalk/smart-open.nvim",
        config = function()
            local telescope = require("telescope")
            telescope.load_extension("smart_open")

            vim.keymap.set('n', '<C-p>', function()
                telescope.extensions.smart_open.smart_open({ cwd_only=true })
            end)
        end,
        requires = {"kkharji/sqlite.lua"}
    }


    use {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v2.x",
        requires = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
            "MunifTanjim/nui.nvim",
        },
        config = function()
            vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])

            local neotree = require("neo-tree")
            local command = require("neo-tree.command")
            vim.keymap.set('n', '<leader>.', function()
                command.execute({ action = "focus", toggle = true })
            end)

            neotree.setup({
                close_if_last_window = true, -- Close Neo-tree if it is the last window left in the tab
                popup_border_style = "rounded",
                enable_git_status = false,
                enable_diagnostics = false,
                open_files_do_not_replace_types = { "terminal", "trouble", "qf" }, -- when opening files, do not use windows containing these filetypes or buftypes
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
                    follow_current_file = true, -- This will find and focus the file in the active buffer every
                    -- time the current file is changed while the tree is open.
                    group_empty_dirs = true, -- when true, empty folders will be grouped together
                    hijack_netrw_behavior = "open_default", -- netrw disabled, opening a directory opens neo-tree
                    -- in whatever position is specified in window.position
                    -- "open_current",  -- netrw disabled, opening a directory opens within the
                    -- window like netrw would, regardless of window.position
                    -- "disabled",    -- netrw left alone, neo-tree does not handle opening dirs
                    use_libuv_file_watcher = true, -- This will use the OS level file watchers to detect changes
                    -- instead of relying on nvim autocmd events.
                },
            })
        end
    }
end)

if packerinstall then
    vim.cmd.PackerInstall()
end
vim.cmd.PackerCompile()
