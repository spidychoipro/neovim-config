return {
    {
        "ThePrimeagen/vim-be-good",
        cmd = "VimBeGood",
        init = function()
            vim.g.vim_be_good_window_padding_row = 0
            vim.g.vim_be_good_window_padding_col = 0
            vim.g.vim_be_good_snake_walls = true
        end,
        config = function()
            local SnakeGame = require("vim-be-good.games.snakelib.snakegame")
            local orig_new = SnakeGame.new
            SnakeGame.new = function(_, width, height, difficultyLevel, endGameCallback)
                local self = orig_new(nil, width, height, difficultyLevel, endGameCallback)
                if vim.g.vim_be_good_snake_walls ~= nil then
                    self.noWalls = not vim.g.vim_be_good_snake_walls
                end
                return self
            end
        end,
        keys = {
            {
                "<leader>vg",
                function()
                    pcall(vim.cmd, "Neotree close")
                    vim.cmd("tabnew")
                    vim.cmd("only")
                    vim.cmd("VimBeGood")
                end,
                desc = "VimBeGood",
            },
        },
    },
}
