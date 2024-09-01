-- clang: https://clang.llvm.org/get_started or package manager
-- clangd: https://clangd.llvm.org/installation
-- zig: https://ziglang.org/learn/getting-started/#linux
-- zls in /usr/bin/zls: https://zigtools.org/zls/install/

-- Install plugins
local function install_plugin(path, repo)
    local full_path = vim.fn.stdpath('config') .. path;
    if vim.fn.empty(vim.fn.glob(full_path)) > 0 then
        local result = vim.fn.system({'git', 'clone', repo, full_path})
        if vim.v.shell_error == 0 then
            print("Installed " .. repo .. ", restart neovim!")
        else
            print("Failed to install " .. repo)
        end
    end
end

install_plugin('/pack/nvim/start/nvim-lspconfig', 'https://github.com/neovim/nvim-lspconfig')
install_plugin('/pack/nvim/start/nvim-lualine', 'https://github.com/nvim-lualine/lualine.nvim')
install_plugin('/pack/themes/start/onedark.nvim', 'https://github.com/navarasu/onedark.nvim.git')

-- Setup LSP
local lspconfig = require('lspconfig')
lspconfig.clangd.setup{}
lspconfig.zls.setup{}

-- Setup theme
require('onedark').setup {
  style = 'dark'
}
require('onedark').load()

-- Setup lualine
require('lualine').setup {
    options = {
        theme = 'onedark' 
    }
}

-- Configure formatting
vim.opt.tabstop = 4      -- Number of visual spaces per TAB
vim.opt.shiftwidth = 4   -- Number of spaces to use for auto-indenting
vim.opt.expandtab = true -- Use spaces instead of tabs
vim.wo.number = true     -- Display numbers
vim.opt.showmatch = true -- Show matching parentheses and brackets

-- Configure auto-indent
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.cindent = true

-- Enable local config
vim.o.exrc = true
vim.o.secure = true

-- Configure Hotkeys
vim.api.nvim_set_keymap('n', '<leader>e', ':Vex<CR>', { noremap = true, silent = true })                          -- Open explorer
vim.api.nvim_set_keymap('n', '<leader>t', ':belowright split | terminal<CR>', { noremap = true, silent = true })  -- Open terminal
vim.api.nvim_set_keymap('n', '<leader>r', ':lua vim.lsp.buf.rename()<CR>', { noremap = true, silent = true })     -- Rename
vim.api.nvim_set_keymap('n', '<leader>b', ':lua vim.lsp.buf.definition()<CR>', { noremap = true
