---@type vim.lsp.Config
return {
  cmd = { 'ruff', 'server' },
  filetypes = { 'python' },
  root_markers = { 'pyproject.toml', '.git' },
  init_options = {
    settings = {
        logLevel = 'info',
    }
  }
}
