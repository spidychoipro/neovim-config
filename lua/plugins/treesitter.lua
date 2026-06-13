return {
    {
        "nvim-treesitter/nvim-treesitter", 
        branch = 'master',
        event = { "BufReadPost", "BufNewFile" },
        cmd = { "TSInstall", "TSUpdate", "TSBufEnable", "TSBufDisable" },
        build = ":TSUpdate",
        
        config = function()
            local config = require("nvim-treesitter.configs")
            config.setup({
                ensure_installed = {
                    "bash",
                    "c",
                    "cpp",
                    "json",
                    "lua",
                    "markdown",
                    "markdown_inline",
                    "powershell",
                    "python",
                    "query",
                    "vim",
                    "vimdoc",
                },
                highlight = {enable = true},
                indent = {enable = true},
            })
        end
    },
}
