# Keymaps

The leader key is `<Space>`.

## Core

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>r` | Normal | Run current file |
| `<leader>f` | Normal | Format current file |
| `<C-p>` | Normal | Find files |
| `<leader>/` | Normal | Live grep |
| `<leader>fb` | Normal | Find buffers |
| `<leader>fh` | Normal | Find help |
| `<C-n>` | Normal | Reveal file explorer |
| `<leader>hh` | Normal | Go to dashboard |
| `<leader>j` | Normal / Visual / Operator | Flash jump |
| `<leader>?` | Normal | Buffer-local keymaps |
| `<C-S-v>` | Normal / Insert | Paste from system clipboard |

## Yank And Paste

| Key | Mode | Action |
| --- | --- | --- |
| `p` | Normal / Visual | Paste after the cursor or selection |
| `P` | Normal / Visual | Paste before the cursor or selection |
| `<leader>p` | Normal / Visual | Open yank history |
| `[y` | Normal | After a paste, replace it with the previous yank |
| `]y` | Normal | After a paste, replace it with the next yank |

## LSP

| Key | Mode | Action |
| --- | --- | --- |
| `K` | Normal | Hover documentation |
| `gd` | Normal | Go to definition |
| `gr` | Normal | List references |
| `gi` | Normal | Go to implementation |
| `<leader>la` | Normal / Visual | Code action |
| `<leader>lr` | Normal | Rename symbol |

## Diagnostics

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>e` | Normal | Show line diagnostics float |
| `<leader>ll` | Normal | Toggle inline diagnostics |
| `<leader>ld` | Normal | Disable inline diagnostics until next file |
| `<leader>xx` | Normal | Trouble diagnostics |
| `<leader>xX` | Normal | Trouble buffer diagnostics |
| `<leader>xQ` | Normal | Trouble quickfix list |
| `<leader>xL` | Normal | Trouble location list |
| `<leader>cs` | Normal | Trouble symbols |
| `<leader>cl` | Normal | Trouble LSP references / definitions |

## Git

| Key | Mode | Action |
| --- | --- | --- |
| `]c` | Normal | Next hunk |
| `[c` | Normal | Previous hunk |
| `<leader>gs` | Normal / Visual | Stage hunk |
| `<leader>gr` | Normal / Visual | Reset hunk |
| `<leader>gp` | Normal | Preview hunk |
| `<leader>gb` | Normal | Blame line |

## Debugging

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>db` | Normal | Toggle breakpoint |
| `<leader>dc` | Normal | Continue debug session |
| `<leader>di` | Normal | Step into |
| `<leader>do` | Normal | Step over |
| `<leader>du` | Normal | Toggle DAP UI |
| `<leader>dx` | Normal | Terminate debug session |

## Tasks

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>tr` | Normal | Run task |
| `<leader>tb` | Normal | Build task |
| `<leader>tt` | Normal | Toggle task list |
| `<leader>ta` | Normal | Task action |

## Sessions

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>ss` | Normal | Search sessions |
| `<leader>sr` | Normal | Restore session |
| `<leader>sw` | Normal | Save session |
| `<leader>st` | Normal | Toggle session autosave |

## UI

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>uk` | Normal | Toggle screenkey |
| `<leader>uK` | Normal | Redraw screenkey |
| `<leader>uo` | Normal | Disable screenkey until next file |
