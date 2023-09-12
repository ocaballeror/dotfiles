vim.api.nvim_create_autocmd("BufWinEnter", {
    pattern = "*",
    desc = "Jump to the last known cursor position when opening a file",
    callback = function()
        if (
            not vim.tbl_contains({'gitcommit', 'fugitive'}, vim.opt.ft:get()) and
            vim.fn.line("'\"") > 0 and vim.fn.line("'\"") <= vim.fn.line("$")
        ) then
            vim.cmd("normal g`\"")
        end
    end
})

vim.api.nvim_create_autocmd("VimResized", {
    pattern = "*",
    desc = "Rebalance windows on vim resize",
    command = "wincmd ="
})

-- Detect file types
vim.filetype.add({
    extension = {
        bats = "sh",
        wsgi = "python",
    },
    filename = {
        ['.bash_prompt'] = "sh",
        ['.bash_customs'] = "sh",
        ['.gitcredentials'] = "gitconfig",
    }
})

vim.api.nvim_create_autocmd("TextYankPost", {
    pattern = "*",
    desc = "Highlight text on yank",
    callback = function() vim.highlight.on_yank() end
})
