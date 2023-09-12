-- Load other lua files
-- local luafiles = vim.fs.find(
--     function(name)
--         return name:match(".*lua$")
--     end,
--     { type = 'file', path = vim.fn.stdpath('config') .. '/lua', limit = math.huge }
-- )
-- for _, fname in pairs(luafiles) do
--     print('load ' .. fname)
--     loadfile(fname)
-- end
require('options')
require('maps')
require('typos')
require('autocmds')
require('plugins')
require('lsp')
