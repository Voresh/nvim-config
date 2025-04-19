-- clang: https://clang.llvm.org/get_started or package manager clangd: https://clangd.llvm.org/installation
-- clang-format: apt install clang-format
-- ripgrep: apt install ripgrep (for telescope live_grep)

local function get_git_tag(path)
    local command = {'git', '-C', path, 'describe', '--tags'}
    local tag = vim.fn.system(command)
    
    if vim.v.shell_error == 0 then
        return vim.trim(tag)
    end

    return nil
end

local function install_plugin(path, repo, tag)
    local full_path = vim.fn.stdpath('config') .. path

    -- Clone plugin if not installed
    if vim.fn.empty(vim.fn.glob(full_path)) > 0 then
        local git_cmd = {'git', 'clone', repo, full_path}
        if tag and #tag > 0 then
            table.insert(git_cmd, '--branch')
            table.insert(git_cmd, tag)
        end

        local result = vim.fn.system(git_cmd)

        if vim.v.shell_error == 0 then
            print("Installed " .. repo .. ", restart Neovim!")
        else
            print("Failed to install " .. repo)
        end
    else
        -- Update plugin if tag is different
        if tag and #tag > 0 then
            local existing_tag = get_git_tag(full_path)

            if tag ~= existing_tag then
                print("Updating " .. repo .. " from " .. existing_tag .. " to " .. tag)
                local fetch_command = {'git', '-C', full_path, 'fetch', '--tags'}
                vim.fn.system(fetch_command)

                local checkout_command = {'git', '-C', full_path, 'checkout', tag}
                vim.fn.system(checkout_command)

                if vim.v.shell_error == 0 then
                    print("Updated " .. repo .. ", restart Neovim!")
                else
                    print("Failed to update " .. repo)
                end
            end
        end
    end
end

-- Install plugins
install_plugin('/pack/themes/start/gruvbox', 'https://github.com/ellisonleao/gruvbox.nvim', '2.0.0')
install_plugin('/pack/nvim/start/nvim-lspconfig', 'https://github.com/neovim/nvim-lspconfig', 'v1.7.0')
install_plugin('/pack/nvim/start/nvim-lualine', 'https://github.com/nvim-lualine/lualine.nvim')
install_plugin('/pack/nvim/start/nvim-web-devicons', 'https://github.com/nvim-tree/nvim-web-devicons')
install_plugin('/pack/nvim/start/nvim-treesitter', 'https://github.com/nvim-treesitter/nvim-treesitter', 'v0.9.3')
install_plugin('/pack/nvim/start/blink.cmp', 'https://github.com/Saghen/blink.cmp', 'v1.1.1')
install_plugin('/pack/nvim/start/nvim-scrollbar', 'https://github.com/petertriho/nvim-scrollbar')
install_plugin('/pack/nvim/start/plenary.nvim', 'https://github.com/nvim-lua/plenary.nvim', 'v0.1.4')
install_plugin('/pack/nvim/start/telescope.nvim', 'https://github.com/nvim-telescope/telescope.nvim', '0.1.8')

-- Setup plugins
require('nvim-treesitter.configs').setup {
    ensure_installed = {"c", "cpp", "markdown", "asm" },
    sync_install = false,
    auto_install = true,
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
}

require('blink.cmp').setup {
    appearance = {use_nvim_cmp_as_default = true, nerd_font_variant = 'mono'},
    completion = {
	    trigger = {
            show_on_keyword = true,
        },
        accept = {
            auto_brackets = {
                enabled = false,
            }   
        },
        ghost_text = {
            enabled = false,
        },
    },
    keymap = {
        preset = 'super-tab',
    },
    signature = { enabled = true } -- experimental
}

local lspconfig = require('lspconfig')
lspconfig.clangd.setup {
    cmd = { "clangd", "--header-insertion=never" },
    config = function(_, opts)
        for server, config in pairs(opts.servers or {}) do
            config.capabilities = require('blink.cmp').get_lsp_capabilities(config.capabilities)
            lspconfig[server].setup(config)
        end
    end
}

vim.diagnostic.config({ virtual_text = {prefix = '⚠', spacing = 0, }, })

vim.o.background = "dark"
vim.cmd([[colorscheme gruvbox]])

require("scrollbar").setup()
require('lualine').setup {}
require('nvim-web-devicons').setup {}

-- Configure vim
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.wo.number = true
vim.opt.showmatch = true
vim.opt.wrap = false
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.cindent = true
vim.o.exrc = true
vim.o.secure = true
vim.g.netrw_banner = 0
vim.g.mapleader = " "

-- Hotkeys and autocommands
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

vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = { "*.c", "*.h", "*.cpp", "*.hpp" },
    callback = function()
        format()
    end,
})
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'make',
  callback = function()
    vim.opt_local.expandtab = false
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
  end
})

local telescope_builtin = require('telescope.builtin')
vim.api.nvim_set_keymap('n', '<leader>e', ':Vex<CR>', { noremap = true, silent = true }) -- Open netrw
vim.api.nvim_set_keymap('n', '<leader>t', ':belowright split | terminal<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>r', ':lua vim.lsp.buf.rename()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>b', ':lua vim.lsp.buf.definition()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>a', ':lua vim.lsp.buf.code_action()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>f', [[<cmd>lua require('telescope.builtin').find_files()<CR>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>g', [[<cmd>lua require('telescope.builtin').live_grep()<CR>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>h', [[<cmd>lua require('telescope.builtin').lsp_references(require('telescope.themes').get_cursor())<CR>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('t', '<Esc>', '<C-\\><C-n>', { noremap = true, silent = true }) -- Unfocus terminal with esc
vim.api.nvim_set_keymap('n', '<leader>p', ':lua format()<CR>', { noremap = true, silent = true }) -- Format
