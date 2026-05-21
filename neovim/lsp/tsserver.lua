---@type vim.lsp.Config
return {
    cmd = { "typescript-language-server", "--stdio" },
    filetypes = { 'typescript', 'javascript', 'typescriptreact' },
    root_markers = { 'package.json', '.git' },
}
