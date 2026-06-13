# Neovim 설정

[![Neovim](https://img.shields.io/badge/Neovim-0.12.2-57A143?logo=neovim&logoColor=white)](https://neovim.io/)
[![Plugin manager](https://img.shields.io/badge/plugin%20manager-lazy.nvim-2f81f7)](https://github.com/folke/lazy.nvim)
[![Healthcheck](https://img.shields.io/badge/healthcheck-passing-brightgreen)](./docs/troubleshooting.md#health-checks)
[![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Linux-blue)](./README.md#requirements)
[![License](https://img.shields.io/badge/license-not%20specified-lightgrey)](./README.md#license)

[English README](./README.md) · [설치](./docs/installation.md) · [사용법](./docs/usage.md) · [커스터마이징](./docs/customization.md) · [단축키](./docs/keymaps.md) · [구조](./docs/architecture.md) · [문제 해결](./docs/troubleshooting.md)

빠르고 예측 가능한 IDE 스타일 Neovim 설정입니다. Python, Lua, Bash, PowerShell, C, C++ 개발을 중심으로 LSP, inline diagnostics, 외부 터미널 실행, Windows 친화적인 작업 흐름을 제공합니다.

이 설정은 Neovim을 편집의 중심으로 사용하되, 프로그램 실행은 실제 외부 터미널에서 처리하도록 설계되었습니다.

## 주요 기능

| 영역 | 내용 |
| --- | --- |
| 언어 도구 | Python, Lua, Bash, PowerShell, C, C++ LSP |
| 진단 표시 | E/W/I/H sign과 `tiny-inline-diagnostic.nvim` inline 메시지 |
| 실행 흐름 | `<leader>r`로 현재 파일을 외부 터미널에서 실행 |
| Windows 지원 | PowerShell 7, Windows Terminal, Mason 경로, `.ps1` 종료 처리 |
| 탐색 | Telescope, Neo-tree, Trouble, Gitsigns, which-key |
| 디버깅/작업 | `nvim-dap`, `dap-ui`, `overseer.nvim` |
| 세션 | `auto-session` 자동 저장/복구 |
| 최신 API | Neovim 0.12 기준 Tree-sitter, LSP, diagnostic, `vim.uv` 사용 |
| 로컬 커스터마이징 | git에 올라가지 않는 `lua/user.lua` override 지원 |

## 미리보기

![Clean startup dashboard](assets/startup.png)

![Python LSP diagnostics](assets/lsp-python.png)

![External run workflow](assets/external-run.png)

![Which-key leader popup](assets/which-key.png)

![Telescope file search](assets/telescope.png)

## 빠른 설치

### Windows

```powershell
Rename-Item "$env:LOCALAPPDATA\nvim" "$env:LOCALAPPDATA\nvim.backup" -ErrorAction SilentlyContinue
git clone https://github.com/spidychoipro/neovim-config "$env:LOCALAPPDATA\nvim"
nvim
```

### Linux

```bash
mv ~/.config/nvim ~/.config/nvim.backup 2>/dev/null || true
git clone https://github.com/spidychoipro/neovim-config ~/.config/nvim
nvim
```

첫 실행 시 `lazy.nvim`이 자동으로 bootstrap됩니다. 자세한 내용은 [docs/installation.md](./docs/installation.md)를 참고하세요.

## 요구 사항

| 도구 | 설명 |
| --- | --- |
| Neovim | `v0.12.2`에서 확인 |
| Git | 플러그인 설치에 필요 |
| Node.js / npm | 여러 LSP 도구에 필요 |
| Python | Python LSP, DAP, 실행기에 필요 |
| PowerShell 7 (`pwsh`) | Windows에서 권장 |
| Windows Terminal (`wt.exe`) | Windows 외부 실행기에 사용 |
| `clang` / `clang++` | C/C++ 빌드 및 실행 |
| `bash` 또는 `sh` | Shell script 실행 |

## 자주 쓰는 단축키

| 단축키 | 동작 |
| --- | --- |
| `<leader>r` | 현재 파일 외부 터미널 실행 |
| `<leader>f` | 현재 파일 포맷 |
| `<C-p>` | 파일 검색 |
| `<leader>/` | 프로젝트 텍스트 검색 |
| `<C-n>` | 파일 탐색기 열기 |
| `<leader>hh` | 대시보드로 돌아가기 |
| `<leader>xx` | Trouble 진단 목록 |
| `<leader>ll` | inline diagnostics 토글 |
| `<leader>ld` | 다음 파일까지 inline diagnostics 끄기 |
| `<leader>uk` | screenkey 토글 |
| `<leader>uo` | 다음 파일까지 screenkey 끄기 |

전체 단축키는 [docs/keymaps.md](./docs/keymaps.md)에 정리되어 있습니다.

## 문서

| 문서 | 내용 |
| --- | --- |
| [Installation](./docs/installation.md) | 설치, 백업, 플랫폼별 준비 |
| [Usage](./docs/usage.md) | 일상적인 사용 흐름 |
| [Customization](./docs/customization.md) | 공유 설정 파일을 직접 고치지 않는 로컬 설정 |
| [Keymaps](./docs/keymaps.md) | 전체 단축키 |
| [Architecture](./docs/architecture.md) | 디렉터리 구조와 모듈 역할 |
| [Troubleshooting](./docs/troubleshooting.md) | healthcheck와 문제 해결 |
| [Contributing](./CONTRIBUTING.md) | 변경 시 지켜야 할 기준 |

## 커스터마이징

개인 장비별 설정은 `lua/user.lua`에 둘 수 있습니다. 이 파일은 git에서 무시되므로 공유 저장소의 기본 설정을 바꾸지 않고도 자기 환경에 맞게 조정할 수 있습니다.

시작 예시는 [examples/user.lua](./examples/user.lua)에 있고, 자세한 설명은 [docs/customization.md](./docs/customization.md)에 있습니다.

## 저장소 구조

```text
.
|-- init.lua                  # lazy.nvim bootstrap
|-- lua/
|   |-- config/               # 기본값과 로컬 설정 loader
|   |-- vim-options.lua       # 기본 옵션과 공통 단축키
|   |-- plugins/              # 플러그인 설정
|   |-- utils/                # 실행기와 virtualenv helper
|   `-- overseer/template/    # 작업 템플릿
|-- assets/                   # README 이미지
|-- docs/                     # 문서
|-- examples/                 # 복사해서 쓰는 로컬 설정 예시
|-- lazy-lock.json            # 플러그인 잠금 파일
`-- pyrightconfig.json        # Python workspace 제외 설정
```

## Healthcheck

업데이트 후에는 아래 명령으로 상태를 확인하세요.

```vim
:checkhealth
:checkhealth vim.deprecated vim.lsp nvim-treesitter screenkey lazy
```

현재 로컬 검증 기준으로 설정 소유 deprecated API 경고는 없습니다.

## 라이선스

현재 저장소에는 `LICENSE` 파일이 포함되어 있지 않습니다. 라이선스가 추가되기 전까지 권리는 저장소 소유자에게 있습니다.
