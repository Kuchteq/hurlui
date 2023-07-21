return {
    "nvim-treesitter/nvim-treesitter",
    version = false,
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
        {
            "pfeiferj/nvim-hurl",
        }
    },
    opts = {
        highlight = { enable = true },
        --indent = { enable = true },
        context_commentstring = { enable = true, enable_autocmd = false },
        ensure_installed = {
            "hurl",
            "html",
            "javascript",
            "json",
            "yaml",
        }
    },
    config = function(_, opts)
        require("hurl").setup()
        require("nvim-treesitter.configs").setup(opts)
    end
}
