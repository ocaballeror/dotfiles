---@type vim.lsp.Config
return {
    cmd = { "pylsp" },
    cmd_env = { PYLSP_MYPY_ALLOW_DANGEROUS_CODE_EXECUTION = true },
    filetypes = { 'python' },
    settings = {
        pylsp = {
            -- configurationSources = { "flake8" },
            plugins = {
                pylsp_mypy = {
                    enabled = true,
                    dmypy = true,
                    live_mode = false,
                    report_progress = true,
                },
                jedi_completion = { fuzzy = true },
                pyflakes = { enabled = false },
                pycodestyle = { enabled = false },
                pylint = { enabled = false },
            },
        },
    },
}
