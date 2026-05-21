require('plugins')

vim.lsp.enable('ruff')
vim.lsp.enable('zuban')
vim.lsp.enable('tsserver')
vim.lsp.enable('lua_ls')


local telescope = require 'telescope.builtin'
vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(ev)
        -- local client = vim.lsp.get_client_by_id(ev.data.client_id)
        local opts = { noremap = true, silent = true, buffer = ev.buf }

        -- do not hijack and break gq
        vim.opt.formatexpr = ""

        -- vim.keymap.set('n', 'gt', vim.lsp.buf.definition, opts)
        -- vim.keymap.set('n', '<Enter>', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'gt', telescope.lsp_definitions, opts)
        vim.keymap.set('n', '<Enter>', telescope.lsp_definitions, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', 'gi', telescope.lsp_implementations, opts)
        vim.keymap.set('n', 'gr', telescope.lsp_references, opts)
        vim.keymap.set('n', '<Space>', telescope.lsp_references, opts)
        vim.keymap.set('n', 'grr', telescope.lsp_references, opts)
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
