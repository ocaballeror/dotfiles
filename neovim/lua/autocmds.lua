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
        ['nginx.conf.template'] = "nginx",
    }
})

vim.api.nvim_create_autocmd("TextYankPost", {
    pattern = "*",
    desc = "Highlight text on yank",
    callback = function() vim.highlight.on_yank() end
})


vim.api.nvim_create_autocmd("BufWinEnter", {
    pattern = "*",
    desc = "Close floating windows with Esc",
    callback = function(args)
        local win = vim.api.nvim_get_current_win()
        local wincfg = vim.api.nvim_win_get_config(win)
        if wincfg.relative and wincfg.relative ~= "" then
            vim.keymap.set("n", "<Esc>", ":q<CR>", { buffer = args.buf, silent = true })
        end
    end,
})
