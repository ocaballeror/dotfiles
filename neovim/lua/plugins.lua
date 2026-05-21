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
    -- {
    --     'deparr/tairiki.nvim',
    --     init = function()
    --         vim.cmd [[ colorscheme tairiki-dark ]]
    --     end
    -- },
    -- {
    --     'catppuccin/nvim',
    --     name = 'catppucin',
    --     priority = 1000,
    --     init = function()
    --         vim.cmd [[ colorscheme catppuccin ]]
    --     end
    -- },
    -- {
    --     "folke/tokyonight.nvim",
    --     lazy = false,
    --     priority = 1000,
    --     opts = {},
    --     -- init = function()
    --     --     vim.cmd[[ colorscheme tokyonight-night ]]
    --     -- end
    -- },
    {
        'alvan/vim-closetag',
        ft = { 'html', 'xml' },
        init = function()
            vim.g.closetag_filenames = "*.html,*.xml"
        end
    },
    -- {'jiangmiao/auto-pairs'},
    { 'tpope/vim-commentary' },
    {
        'tpope/vim-fugitive',
        -- cmd = { 'Git', 'Gdiffsplit', 'Gvdiffsplit' },
        cmd = { 'Git' },
    },
    {
        'sindrets/diffview.nvim',
        cmd = { 'DiffviewOpen' },
        keys = {
            { "<leader>dv", "<cmd>DiffviewOpen origin/main<CR>" },
            { "<leader>dc", "<cmd>DiffviewClose<CR>" },
            { "[q", function() require('diffview.actions').select_prev_entry() end },
            { "]q", function() require('diffview.actions').select_next_entry() end },
        },
        config = function()
            require('diffview').setup()

            vim.opt.fillchars:append { diff = "╱" }
        end
    },
    {
        'yorickpeterse/nvim-pqf',
        config = true,
    },
    -- {
    --     'akinsho/git-conflict.nvim',
    --     config = true,
    --     opts = {
    --         disable_diagnostics = true,
    --     }
    -- },
    { 'tpope/vim-repeat' },
    { 'tpope/vim-surround' },
    {
        'nvim-tree/nvim-web-devicons',
        lazy = true,
        config = true,
    },
    {
        'navarasu/onedark.nvim',
        priority = 1000,
        config = function()
            require('onedark').setup {
                -- style = 'warm'
                style = 'warmer',
                code_style = {
                    -- keywords = 'bold'
                }
            }
            require('onedark').load()
        end,
    },
    {
        'nvim-lualine/lualine.nvim',
        opts = {
            options = {
                -- theme = require('lualine-themes.Tomorrow_Night'),
                -- theme = require('lualine-themes.onedark'),
                theme = 'onedark'
            },
            extensions = { 'fugitive', 'neo-tree', 'quickfix', 'lazy' },
            sections = {
                lualine_b = {
                    'branch',
                    {
                        'diagnostics',
                        symbols = {
                            error = '\u{EA87} ',
                            warn = '\u{EA6C} ',
                            info = '\u{EA74} ',
                            hint = '\u{F400} ',
                        }
                    }
                },
                lualine_c = {
                    {
                        'filename',
                        newfile_status = true,
                        path = 1,
                        symbols = {
                            modified = '●',
                            readonly = '\u{F023}',
                            unnamed = '\u{EB32}',
                            newfile = '\u{F055}',
                        }
                    }
                },
                lualine_x = {
                    -- {
                    --     'overseer',
                    -- },
                    {
                        'selectioncount',
                    },
                    {
                        'searchcount',
                        maxcount = 999,
                        timeout = 500,
                    },
                    {
                        'filetype',
                        colored = true,
                        icon_only = false,
                        icon = { align = 'right' },
                    }
                },
                lualine_y = {
                    {
                        'lsp_status',
                        icon = '', -- f013
                        symbols = {
                            -- Standard unicode symbols to cycle through for LSP progress:
                            spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' },
                            -- Standard unicode symbol for when LSP is done:
                            done = '✓',
                            -- Delimiter inserted between LSP names:
                            separator = ' ',
                        },
                        -- List of LSP names to ignore (e.g., `null-ls`):
                        ignore_lsp = {},
                    }
                }
            }
        }
    },
    {
        'szw/vim-maximizer',
        cmd = 'MaximizerToggle',
        init = function()
            vim.g.maximizer_default_mapping_key = '<leader>fu'
            vim.g.maximizer_set_mapping_with_bang = 1
        end
    },
    -- {
    --     'pappasam/nvim-repl',
    --     keys = {
    --         { "<leader>rt", "<cmd>silent ReplOpen<CR>" },
    --         { "<leader>rc", "<cmd>ReplRunCell<CR>" },
    --         { "<leader>rr", "<Plug>ReplSendLine" },
    --         { "<leader>rr", "<Plug>ReplSendVisual",    mode = "v" }
    --     },
    --     config = function()
    --         vim.g.repl_split = 'right'
    --         vim.g.repl_filetype_commands = {
    --             python = {
    --                 'ptpython',
    --                 '--history-file',
    --                 '/dev/null',
    --                 '--config',
    --                 vim.fn.expand("~/.config/ptpython/repl.py")
    --             }
    --         }

    --         vim.api.nvim_create_autocmd("BufEnter", {
    --             pattern = "*.py",
    --             desc = "Set repl split direction based on available space",
    --             callback = function()
    --                 if vim.fn.winwidth(0) < 200 then
    --                     vim.g.repl_split = "bottom"
    --                 else
    --                     vim.g.repl_split = "right"
    --                 end
    --             end
    --         })
    --         vim.api.nvim_create_autocmd("BufEnter", {
    --             pattern = "*",
    --             desc = "Control repl buffers",
    --             callback = function()
    --                 if vim.opt.buftype:get() ~= "terminal" then
    --                     return
    --                 end

    --                 if vim.fn.winnr("$") == 1 then
    --                     -- exit repl if it's the only buffer remaining
    --                     vim.fn.quit()
    --                 else
    --                     -- do not allow repls to be replaced with other buffers
    --                     local buf = vim.fn.bufnr()
    --                     vim.cmd [[
    --                         buffer#
    --                         normal! <C-W>w
    --                     ]]
    --                     vim.cmd("buffer " .. buf)
    --                 end
    --             end
    --         })
    --     end
    -- },

    {
        'mfussenegger/nvim-dap',
        dependencies = {
            {
                'Joakker/lua-json5',
                build = './install.sh',
            }
        },
        keys = {
            {
                '<F5>', function()
                    require('dap').continue()
                    require('dap-view').open()
                end
            },
            { '<F7>', '<cmd>DapStepInto<CR>' },
            { '<F8>', '<cmd>DapStepOver<CR>' },
            { '<F9>', '<cmd>DapToggleBreakpoint<CR>' },
            -- { '<F12>', '<cmd>DapTerminate<CR>' },
        },
        config = function()
            local dap = require('dap')

            vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DapBreakpoint", linehl = "", numhl = "" })

            dap.adapters.python = {
                type = 'executable',
                command = 'python',
                args = { '-m', 'debugpy.adapter' },
            }

            require('dap.ext.vscode').json_decode = require('json5').parse
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "dap-repl",
                callback = function()
                    require('dap.ext.autocompl').attach()
                end
            })
        end
    },
    
    {
        'mfussenegger/nvim-dap-python',
        config = function()
            local dap = require('dap')
            local dap_python = require('dap-python')
            dap_python.setup('uv')
            dap_python.test_runner = 'pytest'

            dap.configurations.python = {
                {
                    type = 'python',
                    request = 'launch',
                    name = "Fastapi: The good one",
                    module = "fastapi",
                    args = {
                        "dev",
                        "--reload-dir", "src",
                        "src/link_workflow/_dev.py",
                    },
                    console = "integratedTerminal",
                },
                {
                    type = 'python',
                    request = 'launch',
                    name = "pytest: current file",
                    module = "pytest",
                    args = {
                        "-vv",
                        "${file}",
                    },
                    console = "integratedTerminal",
                },
            }

        end
    },

    -- {
    --     'rcarriga/nvim-dap-ui',
    --     dependencies = { 'mfussenegger/nvim-dap', 'nvim-neotest/nvim-nio' },
    --     opts = {
    --         layouts = {
    --             {
    --                 elements = {
    --                     { id = "scopes",  size = 0.25 },
    --                     { id = "stacks",  size = 0.25 },
    --                     { id = "watches", size = 0.25 }
    --                 },
    --                 position = "left",
    --                 size = 40
    --             },
    --             {
    --                 elements = {
    --                     { id = "repl",    size = 0.5 },
    --                     { id = "console", size = 0.5 }
    --                 },
    --                 position = "bottom",
    --                 size = 10
    --             }
    --         },
    --     }
    -- },
    {
        {
            {
                "igorlfs/nvim-dap-view",
                -- let the plugin lazy load itself
                lazy = false,
                version = "1.*",
                ---@module 'dap-view'
                ---@type dapview.Config
                opts = {
                    winbar = {
                        sections = { "console", "scopes", "repl", "watches", "exceptions", "breakpoints", "threads" },
                        default_section = "console",
                        controls = {
                            enabled = true,
                        },
                    },
                    auto_toggle = "keep_terminal",
                },
            },
        }
    },

    {
        'theHamsta/nvim-dap-virtual-text',
        opts = {}
    },

    {
        'nvim-treesitter/nvim-treesitter',
        branch = 'main',
        build = function()
            require('nvim-treesitter.install').update({ with_sync = true })()
        end,
        config = function()
            local langs = { 'python' }  -- lua, typescript

            require('nvim-treesitter').install(langs)
            vim.api.nvim_create_autocmd('FileType', {
                pattern = langs,
                callback = function()
                    vim.treesitter.start()                                    -- highlighting
                    vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'     -- folds
                    vim.wo.foldmethod = 'expr'
                    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()" -- indentation
                end,
            })
        end
    },
    {
        'nvim-telescope/telescope.nvim',
        dependencies = { 'nvim-lua/plenary.nvim' },
        keys = {
            { '<leader>/',  '<cmd>Telescope live_grep<CR>' },
            { '<leader>*',  '<cmd>Telescope grep_string<CR>' },
            -- { '<C-p>', '<cmd>Telescope find_files<CR>' },
            { '<C-S-b>', '<cmd>Telescope buffers<CR>' },
            { '<leader>go', '<cmd>Telescope jumplist<CR>' },
            { '<leader>gt', '<cmd>Telescope tags<CR>' },
        },
        opts = {
            extensions = {
                smart_open = {
                    ignore_patterns = { "*.venv/*" }
                }
            },
            defaults = {
                layout_strategy = 'flex',
                layout_config = {
                    flex = {
                        -- switch to horizontal if window > 150 columns
                        flip_columns = 150,
                    },
                },
                mappings = {
                    i = {
                        ['<C-r>'] = 'cycle_history_prev',
                        ['<C-s>'] = 'cycle_history_next',
                        ['<C-t>'] = function(prompt_bufnr)
                            require('telescope.actions').close(prompt_bufnr)
                            require('telescope.builtin').search_history()
                        end,
                    }
                }
            },
            pickers = {
                search_history = {
                    mappings = {
                        i = {
                            ['<CR>'] = function(prompt_bufnr)
                                local state = require('telescope.actions.state')
                                local selection = state.get_selected_entry()
                                local picker = state.get_current_picker(prompt_bufnr)
                                require('telescope.actions').close(prompt_bufnr)
                                require('telescope.builtin').live_grep { default_text = selection.value }
                            end
                        }
                    }
                }
            },
        },
    },
    {
        'saghen/blink.cmp',
        version = '1.*',
        -- enabled = false,

        ---@module 'blink.cmp'
        ---@type blink.cmp.Config
        opts = {
            -- cmdline = { enabled = false },
            keymap = {
                preset = 'none',
                ['<C-Space>'] = { 'show', 'fallback' },
                ['<CR>'] = { 'accept', 'fallback' },
                ['<Up>'] = { 'select_prev', 'fallback' },
                ['<Down>'] = { 'select_next', 'fallback' },
                ['<Tab>'] = { 'select_next', 'fallback' },
                ['<S-Tab>'] = { 'select_prev', 'fallback' },
                ['<C-k>'] = { 'show_signature', 'hide_signature', 'fallback' },
            },

            completion = {
                trigger = {
                    show_on_blocked_trigger_characters = { ' ', '\n', '\t', '(' },
                },
                list = {
                    selection = {
                        preselect = false,
                        auto_insert = true,
                    }
                },
                documentation = {
                    auto_show = true,
                    auto_show_delay_ms = 500,
                }
            },

            signature = {
                enabled = true,
                window = {
                    show_documentation = true,
                }
            },

            appearance = {
                -- Sets the fallback highlight groups to nvim-cmp's highlight groups
                -- Useful for when your theme doesn't support blink.cmp
                -- Will be removed in a future release
                use_nvim_cmp_as_default = true,
                -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
                -- Adjusts spacing to ensure icons are aligned
                nerd_font_variant = 'mono'
            },

            -- Default list of enabled providers defined so that you can extend
            -- it elsewhere in your config, without redefining it, due to
            -- `opts_extend`
            sources = {
                default = { 'lazydev', 'lsp', 'path' },
                providers = {
                    lazydev = {
                        name = "LazyDev",
                        module = 'lazydev.integrations.blink',
                        -- make lazydev completions top priority
                        score_offset = 100,
                    },
                },
            },

            -- Blink.cmp uses a Rust fuzzy matcher by default for typo
            -- resistance and significantly better performance You may use a
            -- lua implementation instead by using `implementation = "lua"` or
            -- fallback to the lua implementation, when the Rust fuzzy matcher
            -- is not available, by using `implementation = "prefer_rust"`
            --
            -- See the fuzzy documentation for more information
            fuzzy = { implementation = "prefer_rust_with_warning" },
        },
        opts_extend = { "sources.default" }
    },

    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "antoinemadec/FixCursorHold.nvim",
            "nvim-neotest/neotest-python",
            "nvim-neotest/nvim-nio",
        },
        keys = {
            { "<leader>tt", "<cmd>Neotest run<CR>" },
            { "<leader>tf", "<cmd>Neotest run file<CR>" },
            -- vim.keymap.set("n", "<leader>ta", function()
            --     for _, adapter_id in ipairs(neotest.run.adapters()) do
            --         neotest.run.run({ suite = true, adapter = adapter_id })
            --     end
            -- end)
            {
                "<leader>td",
                function()
                    require("neotest").run.run({ strategy = "dap" })
                end,
                desc = "Debug nearest test",
            },
            { "<leader>ta", "<cmd>Neotest run all<CR>" },
            { "<leader>tl", "<cmd>Neotest run last<CR>" },
            { "<leader>tp", "<cmd>Neotest summary toggle<CR>" },
            { "<leader>to", "<cmd>Neotest output short=true<CR>" },
            { "<leader>tO", "<cmd>Neotest output<CR>" },
            { "<leader>ts", "<cmd>Neotest stop<CR>" },
        },
        opts = {
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
        },
        config = function()
            require("neotest").setup({
                adapters = {
                    require("neotest-python")({
                        dap = { justMyCode = false },
                        args = { "-vv" },
                    })
                },
                -- consumers = {
                --     overseer = require('neotest.consumers.overseer'),
                -- },
            })
        end,
    },

    {
        'gen740/SmoothCursor.nvim',
        opts = {
            disabled_filetypes = { 'neotest-summary' },
            disable_float_win = true,
        }
    },
    { 'stevearc/dressing.nvim', event = 'VeryLazy' },
    {
        'rcarriga/nvim-notify',
        event = 'VeryLazy',
        opts = {
            render = "compact"
        }
    },

    {
        "danielfalk/smart-open.nvim",
        keys = {
            { '<C-p>', '<cmd>Telescope smart_open cwd_only=true<CR>' },
        },
        -- opts = {
        --     ignore_patterns = { '*.venv/*' }
        -- },
        config = function()
            require("telescope").load_extension("smart_open")
            require('telescope').load_extension("fzy_native")
        end,
        dependencies = {
            "kkharji/sqlite.lua",
            "nvim-telescope/telescope-fzy-native.nvim",
        }
    },

    {
        "https://codeberg.org/andyg/leap.nvim",
        keys = {
            { 's', '<Plug>(leap)' },
            { 'S', '<Plug>(leap-backward)' },
        }
    },

    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        init = function()
            vim.g.neo_tree_remove_legacy_commands = 1
        end,
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
            "MunifTanjim/nui.nvim",
        },
        keys = {
            { '<leader>.', '<cmd>Neotree focus toggle=true<CR>' },
        },
        opts = {
            close_if_last_window = true, -- Close Neo-tree if it is the last window left in the tab
            popup_border_style = "rounded",
            enable_git_status = false,
            enable_diagnostics = false,
            open_files_do_not_replace_types = { "terminal", "trouble", "qf" }, -- when opening files, do not windows containing these filetypes or buftypes
            sort_case_insensitive = false,                                     -- used when sorting files and directories in the tree
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
                    always_show = {     -- remains visible even if other settings would normally hide it
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
                group_empty_dirs = true,                -- when true, empty folders will be grouped together
                hijack_netrw_behavior = "open_default", -- netrw disabled, opening a directory opens neo-tree
                -- in whatever position is specified in window.position
                -- "open_current",  -- netrw disabled, opening a directory opens within the
                -- window like netrw would, regardless of window.position
                -- "disabled",    -- netrw left alone, neo-tree does not handle opening dirs
                use_libuv_file_watcher = true, -- This will the OS level file watchers to detect changes
                -- instead of relying on nvim autocmd events.
            },
        }
    },
    {
        "chrisgrieser/nvim-puppeteer",
        ft = { 'python' },
    },
    -- {
    --     "zbirenbaum/copilot.lua",
    --     cmd = "Copilot",
    --     event = "InsertEnter",
    --     opts = {
    --         suggestion = {
    --             enabled = true,
    --             auto_trigger = true,
    --             keymap = {
    --                 accept = "<C-e>",
    --             }
    --         },
    --         panel = {
    --             enabled = true,
    --             auto_refresh = true,
    --         }
    --     }
    -- },
    {
        "vincent178/nvim-github-linker",
        -- cmd = "Hublink",
        opts = {
            -- set up a different command to avoid conflicts with :G for fugitive
            mappings = false,
        },
        init = function()
            -- require('nvim-github-linker').setup()
            -- vim.g.nvim_github_linker_default_remote = 'origin'
            vim.cmd([[command! -range Hublink lua require('nvim-github-linker').github_link(<line1>,<line2>)]])
        end,
    },
    {
        'folke/trouble.nvim',
        opts = {},
        cmd = "Trouble",
        keys = {
            {
                "<leader>xx",
                "<cmd>Trouble diagnostics toggle<cr>",
                desc = "Diagnostics (Trouble)",
            }
        },
    },
    {
        'folke/lazydev.nvim',
        ft = 'lua',
        opts = {
            library = {
                { 'nvim-dap-ui' },
                {
                    path = "${3rd}/luv/library",
                    words = { "vim%.uv" }
                },
            },
        },
    },
    -- {
    --     "kndndrj/nvim-dbee",
    --     dependencies = {
    --         "MunifTanjim/nui.nvim",
    --     },
    --     build = function()
    --         require("dbee").install()
    --     end,
    --     opts = {
    --         drawer = {
    --             disable_help = true,
    --         },
    --         editor = {
    --             mappings = {
    --                 { key = "<C-c>", mode = "",  action = "cancel_call" },
    --                 -- run what's currently selected on the active connection
    --                 { key = "BB",    mode = "v", action = "run_selection" },
    --                 -- run the whole file on the active connection
    --                 { key = "BB",    mode = "n", action = "run_file" },
    --                 -- run what's under the cursor to the next newline
    --                 { key = "<CR>",  mode = "n", action = "run_under_cursor" },
    --             },
    --         },
    --         result = {
    --             focus_result = false,
    --             mappings = {
    --                 { key = "<C-c>", mode = "", action = "cancel_call" },
    --             }
    --         },
    --     }
    -- },

    {
        "pwntester/octo.nvim",
        cmd = "Octo",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope.nvim",
            "nvim-tree/nvim-web-devicons",
        },
        keys = {
            {
                "<leader>oi",
                "<CMD>Octo issue list<CR>",
                desc = "List GitHub Issues",
            },
            {
                "<leader>op",
                "<CMD>Octo pr list<CR>",
                desc = "List GitHub PullRequests",
            },
            {
                "<leader>od",
                "<CMD>Octo discussion list<CR>",
                desc = "List GitHub Discussions",
            },
            {
                "<leader>on",
                "<CMD>Octo notification list<CR>",
                desc = "List GitHub Notifications",
            },
            {
                "<leader>os",
                function()
                    require("octo.utils").create_base_search_command { include_current_repo = true }
                end,
                desc = "Search GitHub",
            },
        },
        config = function()
            require('octo').setup(
                {
                    picker = "telescope",
                    enable_builtin = true,
                    use_local_fs = true,
                    poll = {
                        enabled = true,
                    },
                }
            )
            vim.api.nvim_create_autocmd('BufEnter', {
                pattern = '*',
                desc = 'Remove intrusive Octo keybindings from non-octo buffers',
                callback = function()
                    vim.schedule(function()
                        local keys = { "<C-e>", "<C-b>" }

                        for _, key in ipairs(keys) do
                            local map = vim.fn.maparg(key, "n", false, true)

                            if (
                                map
                                and not vim.tbl_isempty(map)
                                and map.callback
                                and debug.getinfo(map.callback).source:match("octo")
                            ) then
                                pcall(vim.keymap.del, "n", key, { buffer = map.buffer > 0 })
                            end
                        end
                    end)
                end
            })
        end
    },

    -- {
    --     "ThePrimeagen/harpoon",
    --     branch = "harpoon2",
    --     dependencies = { "nvim-lua/plenary.nvim" },
    --     config = function()
    --         local harpoon = require("harpoon")
    --         local extensions = require("harpoon.extensions")
    --         harpoon:setup()

    --         harpoon:extend(extensions.builtins.highlight_current_file())
    --         harpoon:extend(extensions.builtins.navigate_with_number())

    --         local function refresh()
    --             local list = harpoon:list()
    --             extensions.extensions:emit(extensions.event_names.LIST_CHANGE, { list = list })
    --             vim.api.nvim_buf_set_lines(0, 0, -1, false, list:display())
    --         end

    --         harpoon:extend({
    --             UI_CREATE = function(cx)
    --                 vim.keymap.set("n", "<C-v>", function()
    --                     harpoon.ui:select_menu_item({ vsplit = true })
    --                 end, { buffer = cx.bufnr })
    --                 vim.keymap.set("n", "<C-p>", "k", { buffer = cx.bufnr })
    --                 vim.keymap.set("n", "<C-n>", "j", { buffer = cx.bufnr })
    --                 vim.keymap.set("n", "<BS>", function()
    --                     local list = harpoon:list()
    --                     local index = vim.fn.line(".")
    --                     local item = list.items[index]

    --                     if item then
    --                         table.remove(list.items, index)
    --                         list._length = list._length - 1

    --                         extensions.extensions:emit(
    --                             extensions.event_names.REMOVE,
    --                             { list = list, item = item, idx = index }
    --                         )

    --                         refresh()
    --                     end
    --                 end)

    --                 -- Move Item Up
    --                 vim.keymap.set("n", "<C-k>", function()
    --                     local list = harpoon:list()
    --                     local idx = vim.fn.line(".")
    --                     if idx <= 1 then return end

    --                     local items = list.items
    --                     items[idx], items[idx - 1] = items[idx - 1], items[idx]

    --                     refresh()
    --                     vim.cmd("normal! k") -- Move cursor up with the item
    --                 end)

    --                 -- Move Item Down
    --                 vim.keymap.set("n", "<C-j>", function()
    --                     local list = harpoon:list()
    --                     local idx = vim.fn.line(".")
    --                     if idx >= list._length then return end

    --                     local items = list.items
    --                     items[idx], items[idx + 1] = items[idx + 1], items[idx]

    --                     refresh()
    --                     vim.cmd("normal! j") -- Move cursor down with the item
    --                 end)
    --             end,
    --         })

    --         vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
    --         vim.keymap.set("n", "<C-l>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

    --         vim.keymap.set("n", "<C-1>", function() harpoon:list():select(1) end)
    --         vim.keymap.set("n", "<C-2>", function() harpoon:list():select(2) end)
    --         vim.keymap.set("n", "<C-3>", function() harpoon:list():select(3) end)
    --         vim.keymap.set("n", "<C-4>", function() harpoon:list():select(4) end)

    --         -- Toggle previous & next buffers stored within Harpoon list
    --         vim.keymap.set("n", "<C-S-P>", function() harpoon:list():prev() end)
    --         vim.keymap.set("n", "<C-S-N>", function() harpoon:list():next() end)
    --     end,
    -- },

    --{
    --    'stevearc/overseer.nvim',
    --    ---@module 'overseer'
    --    ---@type overseer.SetupOpts
    --    opts = {},
    --    cmd = { 'OverseerRun', 'OverseerOpen' },
    --    config = function()
    --        local overseer = require("overseer")

    --        overseer.register_template({
    --            name = "pre-commit",
    --            generator = function(opts, cb)
    --                local config_file = vim.fs.find(".pre-commit-config.yaml", { 
    --                    upward = true, 
    --                    type = "file", 
    --                    path = opts.dir 
    --                })[1]

    --                if not config_file then
    --                    cb({})
    --                    return
    --                end

    --                local tasks = {}

    --                -- global task to run all hooks at once
    --                table.insert(tasks, {
    --                    name = "pre-commit: run all",
    --                    builder = function()
    --                        return {
    --                            cmd = { "pre-commit", "run", "--all-files" },
    --                            components = { "default" },
    --                        }
    --                    end,
    --                    tags = { overseer.TAG.BUILD },
    --                })

    --                -- parse the yaml file to extract individual hooks and create tasks for them
    --                local lines = vim.fn.readfile(config_file)
    --                for _, line in ipairs(lines) do
    --                    -- match lines like "- id: trailing-whitespace"
    --                    local hook_id = line:match("id:%s*([%w%-_]+)")

    --                    if hook_id then
    --                        table.insert(tasks, {
    --                            name = "pre-commit: " .. hook_id,
    --                            builder = function()
    --                                return {
    --                                    cmd = { "pre-commit", "run", hook_id, "--all-files" },
    --                                    components = { "default" },
    --                                }
    --                            end,
    --                        })
    --                    end
    --                end

    --                cb(tasks)
    --            end,

    --            -- cache the results. overseer will re-evaluate this generator
    --            -- only if the .pre-commit-config.yaml file is modified or
    --            -- changed.
    --            cache_key = function(opts)
    --                return vim.fs.find(".pre-commit-config.yaml", { 
    --                    upward = true, 
    --                    type = "file", 
    --                    path = opts.dir 
    --                })[1]
    --            end,
    --        })
    --    end
    --}
})
