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
            local function empty(n)
                local lines = {}
                for i = 1, n do
                    lines[i] = ""
                end
                return lines
            end

            local Buffer = require("vim-be-good.buffer")
            Buffer.clear = function(self)
                local len = #(self.lastRenderedInstruction or {}) + #(self.lastRendered or {})
                vim.api.nvim_buf_set_lines(self.bufh, 0, len, false, empty(len))
            end
            Buffer.render = function(self, lines)
                self.instructions = self.instructions or {}
                self.lastRendered = self.lastRendered or {}
                self.lastRenderedInstruction = self.lastRenderedInstruction or {}
                self:clear()
                self.lastRendered = lines
                local offset = 0
                if self.debugLineStr then
                    vim.api.nvim_buf_set_lines(self.bufh, 0, 1, false, { self.debugLineStr })
                    offset = 1
                end
                if #self.instructions > 0 then
                    vim.api.nvim_buf_set_lines(self.bufh, offset, offset + #self.instructions, false, self.instructions)
                    offset = offset + #self.instructions
                end
                vim.api.nvim_buf_set_lines(self.bufh, offset, offset + #lines, false, lines)
            end
            local SnakeGame = require("vim-be-good.games.snakelib.snakegame")
            local orig_new = SnakeGame.new
            SnakeGame.new = function(_, width, height, difficultyLevel, endGameCallback)
                local self = orig_new(nil, width, height, difficultyLevel, endGameCallback)
                if vim.g.vim_be_good_snake_walls ~= nil then
                    self.noWalls = not vim.g.vim_be_good_snake_walls
                end
                return self
            end

            Buffer.getGameLines = function(self)
                local startOffset = #(self.instructions or {})
                local len = #(self.lastRendered or {})
                return vim.api.nvim_buf_get_lines(self.bufh, startOffset, startOffset + len, false)
            end
            Buffer.clearGameLines = function(self)
                local startOffset = #(self.instructions or {})
                local len = #(self.lastRendered or {})
                vim.api.nvim_buf_set_lines(self.bufh, startOffset, startOffset + len, false, empty(len))
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
