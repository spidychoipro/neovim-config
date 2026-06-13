# Neovim 설정 (Neovim Config)

[English Documents](./README.md)

언어 도구 지원, 외부 터미널 실행, 그리고 낮은 진입 장벽의 편집 환경에 초점을 맞춘 깔끔하고 빠르며 IDE와 같은 Neovim 설정입니다.

이 설정은 Neovim을 컨트롤 센터로 취급하며, 프로그램 실행은 실제 외부 터미널에서 유지하도록 설계되었습니다.

## 소개

Neovim을 단순한 텍스트 에디터 그 이상으로 사용하고자 하는 사용자를 위해 구성되었습니다. 모든 복잡한 설정은 추상화되어 있으며, 사용자는 코딩 그 자체에 집중할 수 있습니다.

## 기능

- **LSP 지원**: Bash, Python, Lua, PowerShell, C, C++ 지원.
- **외부 실행 시스템**: `<leader>r`을 통한 즉각적인 외부 터미널 실행.
- **Windows 지원**: Windows Terminal 및 PowerShell(`pwsh`) 연동 최적화.
- **Linux 지원**: 시스템 기본 터미널을 통한 실행 지원.
- **포맷팅**: `conform.nvim`을 통한 자동 코드 정렬.
- **린팅**: `nvim-lint`를 통한 정적 코드 분석.
- **디버깅**: `nvim-dap`, `debugpy`, `codelldb` 기반의 디버깅 환경.
- **세션 관리**: `auto-session`을 통한 작업 상태 자동 저장 및 복구.
- **작업 관리**: `overseer.nvim`을 통한 빌드 및 테스트 자동화.
- **직관적 단축키**: `which-key.nvim`을 통한 가시적인 단축키 가이드.
- **PowerShell 최적화**: `powershell.nvim`을 통한 강력한 스크립팅 환경.

## 철학

- **외부 터미널 우선**: 내부 터미널의 복잡함 대신 실제 터미널 환경을 활용합니다.
- **최소주의 및 강력함**: 불필요한 기능은 배제하되 필요한 기능은 강력하게 지원합니다.
- **빠른 반복 작업**: 무거운 추상화보다 직관적이고 빠른 작업 흐름을 선호합니다.
- **비대하지 않은 IDE 환경**: IDE의 편리함을 제공하되 Neovim 본연의 속도를 유지합니다.

## 요구 사항

- Neovim v0.11 이상
- Git
- Node.js 및 npm
- Python
- PowerShell 7 이상 (`pwsh`)
- Windows Terminal (`wt.exe`, Windows 전용)
- Linux 터미널 (`x-terminal-emulator`, `gnome-terminal`, `konsole`, `alacritty`, `kitty`, `wezterm`, `xterm` 등)
- `clang` 및 `clang++`
- `bash` 또는 `sh`

Mason을 통해 다음 도구들이 자동/수동으로 관리됩니다:
- `lua-language-server`, `basedpyright`, `bash-language-server`, `powershell-editor-services`, `clangd`
- `clang-format`, `debugpy`, `codelldb`, `black`, `isort`, `stylua`, `shellcheck`, `shfmt`

## 설치 방법

### Windows

```powershell
git clone https://github.com/spidychoipro/neovim-config "$env:LOCALAPPDATA\nvim"
```

기존 설정이 있다면 먼저 백업하세요:
```powershell
Rename-Item "$env:LOCALAPPDATA\nvim" "$env:LOCALAPPDATA\nvim.backup"
git clone https://github.com/spidychoipro/neovim-config "$env:LOCALAPPDATA\nvim"
```

### Linux

```bash
git clone https://github.com/spidychoipro/neovim-config ~/.config/nvim
```

기존 설정이 있다면 먼저 백업하세요:
```bash
mv ~/.config/nvim ~/.config/nvim.backup
git clone https://github.com/spidychoipro/neovim-config ~/.config/nvim
```

## 키맵 (주요 단축키)

| 단축키 | 동작 |
| --- | --- |
| `<leader>r` | 외부 터미널에서 현재 파일 실행 |
| `<leader>f` | 현재 파일 포맷팅 (코드 정렬) |
| `<leader>d` | 디버그 그룹 (Breakpoint, Continue 등) |
| `<leader>l` | LSP 그룹 (Code action, Rename 등) |
| `<leader>t` | 작업(Tasks) 그룹 (Overseer 실행/목록) |
| `<leader>s` | 세션 그룹 (저장/복구/검색) |
| `<leader>e` | 현재 라인 진단 정보 팝업 |
| `<leader>ll` | 인라인 진단 메시지 표시 모드 전환 |
| `<leader>/` | 전체 텍스트 검색 (Live Grep) |
| `<C-p>` | 파일 검색 |
| `<C-n>` | 파일 탐색기 열기/닫기 |

## 외부 실행 시스템 지원 정보

| 언어 | 실행 명령 |
| --- | --- |
| Python | `python file.py` |
| Lua | `lua` 또는 `luajit` 기반 실행 |
| Bash | `bash file.sh` |
| PowerShell | `pwsh file.ps1` |
| C | `clang` 컴파일 후 실행 |
| C++ | `clang++` 컴파일 후 실행 |

## 스크린샷

![Clean startup dashboard](assets/startup.png)

![Python LSP diagnostics](assets/lsp-python.png)

![External run workflow](assets/external-run.png)

![Which-key leader popup](assets/which-key.png)

![Telescope file search](assets/telescope.png)
