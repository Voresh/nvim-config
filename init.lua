-- clang: https://clang.llvm.org/get_started or package manager clangd: https://clangd.llvm.org/installation
-- clang-format: apt install clang-format
-- zig: https://ziglang.org/learn/getting-started/#linux
-- zls in /usr/bin/zls: https://zigtools.org/zls/install/
-- glsl in https://github.com/nolanderc/glsl_analyzer

-- Install plugins
local function install_plugin(path, repo, tag)
    local full_path = vim.fn.stdpath('config') .. path;
    if vim.fn.empty(vim.fn.glob(full_path)) > 0 then
        local git_cmd = {'git', 'clone', repo, full_path}
       
        if tag and #tag > 0 then
            table.insert(git_cmd, '--branch')
            table.insert(git_cmd, tag)
        end

        local result = vim.fn.system(git_cmd)

        if vim.v.shell_error == 0 then
            print("Installed " .. repo .. ", restart neovim!")
        else
            print("Failed to install " .. repo)
        end
    end
end

install_plugin('/pack/nvim/start/nvim-lspconfig', 'https://github.com/neovim/nvim-lspconfig')
install_plugin('/pack/nvim/start/nvim-lualine', 'https://github.com/nvim-lualine/lualine.nvim')
install_plugin('/pack/nvim/start/nvim-web-devicons', 'https://github.com/nvim-tree/nvim-web-devicons')
install_plugin('/pack/nvim/start/vim-glsl', 'https://github.com/tikhomirov/vim-glsl')
install_plugin('/pack/themes/start/darcula-dark.nvim', 'https://github.com/xiantang/darcula-dark.nvim')
install_plugin('/pack/nvim/start/nvim-treesitter', 'https://github.com/nvim-treesitter/nvim-treesitter')
install_plugin('/pack/nvim/start/blink.cmp', 'https://github.com/Saghen/blink.cmp', 'v0.5.1')

-- Setup treesitter
require'nvim-treesitter.configs'.setup {
  ensure_installed = { "c", "cpp", "markdown", "markdown_inline" },
  sync_install = false,
  auto_install = true,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
}

require('blink.cmp').setup{
     highlight = {
         use_nvim_cmp_as_default = true,
     },
     keymap = { preset = 'super-tab' },
 }

-- Setup LSP
local lspconfig = require('lspconfig')
lspconfig.clangd.setup {
  config = function(_, opts)
    local lspconfig = require('lspconfig')
    for server, config in pairs(opts.servers or {}) do
      config.capabilities = require('blink.cmp').get_lsp_capabilities(config.capabilities)
      lspconfig[server].setup(config)
    end
  end
}
-- lspconfig.zls.setup{}
lspconfig.glsl_analyzer.setup{}

-- Setup theme
require("darcula").setup({})

-- Setup lualine
require('lualine').setup{}

-- Setup icons
require('nvim-web-devicons').setup{}

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

function _G.format()
  local buffer_path = vim.fn.expand('%:p')
  local cmd = 'clang-format -i -style=file ' .. buffer_path
  local result = vim.fn.system(cmd)
  if vim.v.shell_error ~= 0 then
    vim.notify("clang-format failed: " .. result, vim.log.levels.ERROR)
    return
  end
  vim.cmd("edit")
end

-- Autocommands
vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = { "*.cpp", "*.hpp" },
    callback = function()
        format()
    end,
})

-- Configure Hotkeys
vim.api.nvim_set_keymap('n', '<leader>e', ':Vex<CR>', { noremap = true, silent = true })                            -- Open explorer
vim.api.nvim_set_keymap('n', '<leader>t', ':belowright split | terminal<CR>', { noremap = true, silent = true })    -- Open terminal
vim.api.nvim_set_keymap('n', '<leader>r', ':lua vim.lsp.buf.rename()<CR>', { noremap = true, silent = true })       -- Rename
vim.api.nvim_set_keymap('n', '<leader>b', ':lua vim.lsp.buf.definition()<CR>', { noremap = true, silent = true })   -- Go to definition
vim.api.nvim_set_keymap('n', '<leader>a', ':lua vim.lsp.buf.code_action()<CR>', { noremap = true, silent = true })  -- Code action
vim.api.nvim_set_keymap('t', '<Esc>', '<C-\\><C-n>', { noremap = true, silent = true })                             -- Unfocus terminal with esc
vim.api.nvim_set_keymap('n', '<leader>p', ':lua format()<CR>', { noremap = true, silent = true })                   -- Format
