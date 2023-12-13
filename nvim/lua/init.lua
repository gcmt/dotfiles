
require'nvim-treesitter.configs'.setup {
    ensure_installed = { "vim", "python", "go", "javascript", "rust", "yaml" },
    sync_install = false,
    ignore_install = {""},
    highlight = {
        enable = false,
        disable = {""},
        additional_vim_regex_highlighting = false,
    },
    indent = {
        enable = true,
        disable = {""},
    },
}
