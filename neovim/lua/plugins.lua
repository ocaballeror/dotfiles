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
    {
        'alvan/vim-closetag',
        ft = { 'html', 'xml' },
        init = function()
            vim.g.closetag_filenames = "*.html,*.xml"
        end
    },
    -- {'jiangmiao/auto-pairs'},
    {'tpope/vim-commentary'},
    {'tpope/vim-fugitive', cmd = 'Git' },
    {'tpope/vim-repeat'},
    {'tpope/vim-surround'},
    {
        'nvim-tree/nvim-web-devicons',
        lazy = true,
        config = true,
    },
    -- {
    --     'vim-airline/vim-airline',
    --     dependencies = { 'vim-airline/vim-airline-themes' },
    --     init = function()
    --         vim.g.airline_highlighting_cache = 1
    --         vim.g.airline_detect_modified = 1
    --         vim.g.airline_detect_paste = 1
    --         vim.g.airline_theme = 'tomorrow'
    --         vim.g.airline_powerline_fonts = 1
    --         vim.g.airline_skip_empty_sections = 1
    --     end
    -- },
    {
        'nvim-lualine/lualine.nvim',
        opts = {
            options = {
                theme = require('lualine-themes.Tomorrow_Night'),
            },
            extensions = { 'fugitive', 'neo-tree', 'nvim-dap-ui', 'quickfix', 'lazy' },
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
    {
        'pappasam/nvim-repl',
        keys = {
            {"<leader>rt", "<cmd>silent ReplOpen<CR>"},
            {"<leader>rc", "<cmd>ReplRunCell<CR>"},
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
        opts = {
            adapters = {
                python = {
                    type = 'executable';
                    command = 'python';
                    args = { '-m', 'debugpy.adapter' };
                }
            },
            configurations = {
                python = {
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
            }
        },
        config = function()
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
        options = {
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
        opts = {
            extensions = {
                smart_open = {
                    ignore_patterns = { "*.venv/*" }
                }
            }
        }
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
                ['<C-k>'] = { 'show_signature', 'hide_signature', 'fallback'},
            },

            completion = {
                trigger = {
                    show_on_blocked_trigger_characters = { ' ', '\n', '\t', '('},
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
                default = { 'lsp', 'path' },
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
            "nvim-treesitter/nvim-treesitter",
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
                        dap = { justMyCode = false }
                    })
                }
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
            {'<C-p>', '<cmd>Telescope smart_open cwd_only=true<CR>' },
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
        "ggandor/leap.nvim",
        config = function()
            require('leap').add_default_mappings()
        end
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
        }
    },
    {
        "chrisgrieser/nvim-puppeteer",
        dependencies = "nvim-treesitter/nvim-treesitter",
        ft = {'python'},
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
        "ocaballeror/nvim-github-linker",
        cmd = "Hublink",
        options = {
            -- set up a different command to avoid conflicts with :G for fugitive
            mappings = false,
        },
        config = function()
            vim.cmd([[command! -range Hublink lua require('nvim-github-linker').github_linker_command(<line1>,<line2>)]])
        end,
    },
})
