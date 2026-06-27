return {
    "numToStr/Comment.nvim",
    opts = {
        pre_hook = function(ctx)
            local U = require("Comment.utils")
            if ctx.ctype == U.ctype.blockwise then
                return "'''%s'''"
            end
            return vim.bo.commentstring
        end,
        padding = true,
        sticky = true,
        toggler = {
            line = "gcc",
            block = "gbc",
        },
        opleader = {
            line = "gc",
            block = "gb",
        },
        extra = {
            above = "gcO",
            below = "gco",
            eol = "gcA",
        },
        mappings = {
            basic = true,
            extra = true,
        },
    },
}
