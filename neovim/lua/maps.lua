vim.keymap.set("n", "<leader>ct", "<cmd>AsyncRun rm -f .tags && ctags -R .<CR>")
vim.keymap.set({ "n", "v" }, "j", "gj")  -- don't skip wrapped lines
vim.keymap.set({ "n", "v" }, "k", "gk")  -- don't skip wrapped lines

vim.keymap.set("n", "<C-b>", "<cmd>b#<CR>")  -- go to previous buffer with <c-b>
vim.keymap.set({ "n", "v" }, "\\", "@:")     -- repeat last colon command
vim.keymap.set({ "n", "v" }, "ñ", "@:")      -- repeat last colon command

vim.keymap.set(
    "n", "<leader>gco",
    function()  -- git checkout the current file
        vim.cmd("!git checkout --quiet " .. vim.fn.expand('%t'))
        vim.cmd("edit!")
    end,
    { silent = true }
)

vim.keymap.set("n", "<C-j>", "<cmd>move .+1<CR>==")  -- move the current line up
vim.keymap.set("n", "<C-k>", "<cmd>move .-2<CR>==")  -- move the current line down

vim.keymap.set({ "n", "v" }, "gp", '"_dP')  -- paste into selection without losing clipboard contents

vim.keymap.set("n", "<C-e>", "2<C-e>")  -- make scrolling a bit faster
vim.keymap.set("n", "<C-y>", "2<C-y>")  -- make scrolling a bit faster

vim.keymap.set("n", "<leader>ev", function()  -- edit nvim config
    vim.cmd("vsplit " .. vim.fn.stdpath("config") .. "init.lua")
end)

vim.keymap.set("n", "Q", "@@")  -- repeat last recorded macro

-- move between panes
vim.keymap.set("n", "<leader>f" , "<C-w>j")
vim.keymap.set("n", "<leader>d" , "<C-w>k")
vim.keymap.set("n", "<leader>g" , "<C-w>l")
vim.keymap.set("n", "<leader>s" , "<C-w>h")

-- resize panes
vim.keymap.set("n", "<C-Up>", ":resize +5<CR>")
vim.keymap.set("n", "<C-Down>", ":resize -5<CR>")
vim.keymap.set("n", "<C-Right>", ":vertical resize +5<CR>")
vim.keymap.set("n", "<C-Left>", ":vertical resize -5<CR>")

-- move between terminals
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>")
vim.keymap.set("t", "<A-h>", "<C-\\><C-n><C-w>h")
vim.keymap.set("t", "<A-j>", "<C-\\><C-n><C-w>j")
vim.keymap.set("t", "<A-k>", "<C-\\><C-n><C-w>k")
vim.keymap.set("t", "<A-l>", "<C-\\><C-n><C-w>l")

-- open terminals with Vterm and Sterm
vim.api.nvim_create_user_command("Vterm", "vsplit | terminal", {})
vim.api.nvim_create_user_command("Sterm", "split | terminal", {})
