---@type vim.lsp.Config
return {
    cmd = { 'sql-language-server', 'up', '--method', 'stdio' },
    filetypes = { 'sql', 'mysql', 'pgsql' },
}
