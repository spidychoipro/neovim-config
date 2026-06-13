return {
    {
        'akinsho/toggleterm.nvim',
        version = '*',
        config = function()
            require('toggleterm').setup({
                size = 15,
                open_mapping = [[<F7>]],
                direction = 'horizontal',
                close_on_exit = true,
                shell = 'pwsh.exe',
                start_in_insert = false,
            })
            
            -- Function to run current file
            local function run_current_file()
                local filetype = vim.bo.filetype
                local filename = vim.fn.expand('%:p')
                local buftype = vim.bo.buftype
                
                -- Don't run if it's a special buffer (like config files)
                if buftype ~= '' then
                    print('ERROR: Cannot run special buffer type: ' .. buftype)
                    return
                end
                
                -- Don't run if no file is open
                if filename == '' then
                    print('ERROR: No file open')
                    return
                end
                
                -- Save the file first (only if it's modifiable)
                if vim.bo.modifiable and vim.bo.modified then
                    vim.cmd('write')
                end
                
                print('File type: ' .. filetype)
                print('Running: ' .. filename)
                
                -- Simpler command structure
                local cmd = ''
                if filetype == 'python' then
                    cmd = 'python "' .. filename .. '"'
                elseif filetype == 'javascript' then
                    cmd = 'node "' .. filename .. '"'
                elseif filetype == 'lua' then
                    cmd = 'lua "' .. filename .. '"'
                elseif filetype == 'sh' then
                    cmd = 'bash "' .. filename .. '"'
                elseif filetype == 'go' then
                    cmd = 'go run "' .. filename .. '"'
                elseif filetype == 'c' then
                    cmd = 'gcc "' .. filename .. '" -o %TEMP%\\a.exe && %TEMP%\\a.exe'
                elseif filetype == 'cpp' then
                    cmd = 'g++ "' .. filename .. '" -o %TEMP%\\a.exe && %TEMP%\\a.exe'
                elseif filetype == 'java' then
                    cmd = 'javac "' .. filename .. '" && java ' .. vim.fn.expand('%:t:r')
                else
                    print('ERROR: Unsupported file type: ' .. filetype)
                    return
                end
                
                print('Command: ' .. cmd)
                
                -- Execute the command
                require('toggleterm').exec(cmd, 1)
            end
            
            -- Bind F5 to run file
            vim.keymap.set('n', '<F5>', run_current_file, { 
                noremap = true, 
                silent = false, 
                desc = 'Run current file' 
            })
            
            -- Bind Ctrl+Enter to run file (normal mode)
            vim.keymap.set('n', '<C-CR>', run_current_file, { 
                noremap = true, 
                silent = false, 
                desc = 'Run current file' 
            })
            
            -- Bind Ctrl+Enter to run file (insert mode)
            vim.keymap.set('i', '<C-CR>', function()
                vim.cmd('stopinsert')
                run_current_file()
            end, { 
                noremap = true, 
                silent = false, 
                desc = 'Run current file' 
            })
            
            -- Terminal mode: Esc to exit terminal mode
            vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], { noremap = true })
            
            -- Terminal mode: F7 to close terminal
            vim.keymap.set('t', '<F7>', [[<C-\><C-n><Cmd>ToggleTerm<CR>]], { noremap = true })
        end,
    },
}
