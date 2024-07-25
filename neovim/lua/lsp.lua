require('plugins')

local nvim_lsp = require 'lspconfig'
local telescope = require 'telescope.builtin'
local on_attach = function(client, bufnr)
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    local opts = { noremap = true, silent = true, buffer=bufnr }
    vim.keymap.set('n', 'gt', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gi', telescope.lsp_implementations, opts)
    vim.keymap.set('n', 'gr', telescope.lsp_references, opts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', '<leader>di', vim.diagnostic.open_float, opts)
    -- vim.keymap.set('n', '<leader>bl', vim.lsp.buf.format, opts)
end

-- Add additional capabilities supported by nvim-cmp
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Enable some language servers with the additional completion capabilities offered by nvim-cmp
local servers = { 'clangd', 'solargraph', 'bashls' }
for _, lsp in ipairs(servers) do
    nvim_lsp[lsp].setup {
        on_attach = on_attach,
        capabilities = capabilities,
    }
end

nvim_lsp.pylsp.setup {
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
        pylsp = {
            configurationSources = 'flake8',
            plugins = {
                flake8 = { enabled = false, maxLineLength = 99 },
                pyflakes = { enabled = false },
                pycodestyle = { enabled = false },
                pylint = { enabled = false },
                pylsp_mypy = { enabled = true, dmypy = false },
                pyls_isort = { enabled = false },
                jedi_completion = { fuzzy = true },
                -- black = { enabled = true, cache_config = true, line_length = 99 },
                ruff = { enabled = true, exclude = { ".venv" }, maxLineLength = 99 },
            }
        },
    }
}
