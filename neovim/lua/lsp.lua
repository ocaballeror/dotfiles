require('plugins')

local servers = {
    -- clangd = {
    --     cmd = { "clangd" },
    --     filetypes = { 'c', 'cpp' },
    -- },
    -- solargraph = {
    --     cmd = { "solargraph", "stdio" },
    --     filetypes = { 'ruby' },
    -- },
    -- bashls = {
    --     cmd = { "bash-language-server", "start" },
    --     filetypes = { 'sh' },
    -- },
    tsserver = {
        cmd = { "typescript-language-server", "--stdio" },
        filetypes = { 'typescript', 'javascript', 'typescriptreact' },
    },
    -- lua_ls = {
    --     cmd = { "lua-language-server" },
    --     filetypes = { 'lua' },
    -- },
    pylsp = {
        cmd = { "pylsp" },
        cmd_env = { PYLSP_MYPY_ALLOW_DANGEROUS_CODE_EXECUTION = true },
        filetypes = { 'python' },
        settings = {
            pylsp = {
                -- configurationSources = { "flake8" },
                plugins = {
                    pylsp_mypy = {
                        enabled = true,
                        dmypy = false,
                        report_progress = true,
                    },
                    jedi_completion = { fuzzy = true },
                    pyflakes = { enabled = false },
                    pycodestyle = { enabled = false },
                    pylint = { enabled = false },
                },
            },
        },
    },
    ruff = {
        filetypes = { "python" },
        cmd = { "ruff", "server" },
    },
    -- sqlls = {
    --     cmd = { 'sql-language-server', 'up', '--method', 'stdio' },
    --     filetypes = { 'sql', 'mysql', 'pgsql' },
    -- }
    -- sqruff = {
    --     cmd = { "sqruff", "lsp" },
    --     filetypes = { 'sql', 'mysql', 'pgsql' },
    -- }
}

local capabilities = vim.lsp.protocol.make_client_capabilities()
for name, config in pairs(servers) do
    vim.lsp.config[name] = {
        root_markers = { ".git", "pyproject.toml", "package.json", ".luarc.json" },
        cmd = config.cmd,
        cmd_env = config.cmd_env,
        filetypes = config.filetypes,
        settings = config.settings,
        capabilities = capabilities,
    }
    vim.lsp.enable(name)
end

local telescope = require 'telescope.builtin'
vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        local opts = { noremap = true, silent = true, buffer = ev.buf }

        vim.keymap.set('n', 'gt', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', 'gi', telescope.lsp_implementations, opts)
        vim.keymap.set('n', 'gr', telescope.lsp_references, opts)
        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set('n', '<leader>di', vim.diagnostic.open_float, opts)
        vim.keymap.set('n', '<leader>bl', vim.lsp.buf.format, opts)

        -- if client.supports_method('textDocument/completion') then
        --     vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
        -- end
    end
})

-- vim.opt.completeopt = { 'menu', 'popup', 'noselect', 'fuzzy' }
-- vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }
vim.opt.shortmess:append('c')
vim.diagnostic.config({
    virtual_text = true,
    -- virtual_lines = true,
})
