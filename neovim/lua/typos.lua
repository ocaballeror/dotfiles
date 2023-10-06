vim.keymap.set("n", "q:", "<cmd>q<CR>")

vim.cmd.cnoreabbrev("W!", "w!")
vim.cmd.cnoreabbrev("Q!", "q!")
vim.cmd.cnoreabbrev("Qall!", "qall!")
vim.cmd.cnoreabbrev("Wq", "wq")
vim.cmd.cnoreabbrev("Wa", "wa")
vim.cmd.cnoreabbrev("wQ", "wq")
vim.cmd.cnoreabbrev("WQ", "wq")
vim.cmd.cnoreabbrev("W", "w")
vim.cmd.cnoreabbrev("Q", "q")
vim.cmd.cnoreabbrev("Qall", "qall")

vim.cmd.inoreabbrev("lenght", "length")
vim.cmd.inoreabbrev("recieve", "receive")
vim.cmd.inoreabbrev("reciever", "receiver")
vim.cmd.inoreabbrev("emtpy", "empty")
vim.cmd.inoreabbrev("acesible", "accessible")
vim.cmd.inoreabbrev("acessible", "accessible")
vim.cmd.inoreabbrev("accesible", "accessible")
vim.cmd.inoreabbrev("lsit", "list")
vim.cmd.inoreabbrev("NOne", "None")
vim.cmd.inoreabbrev("awiat", "await")
vim.cmd.inoreabbrev("improt", "import")

vim.keymap.set({ "n", "v", "i" }, "<F1>", "<Nop>")  -- disable F1 for help (usually meant to use Esc)
