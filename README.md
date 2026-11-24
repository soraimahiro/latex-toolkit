# LaTeX & Pandoc Docker Toolkit

這是一個基於 Docker 和 `texlive/texlive:latest` 的 LaTeX 與 Pandoc 編譯環境，專門用來將 `.tex` 檔案與 Markdown 檔案編譯或轉換為 PDF。此環境內建了完整的 TeX Live 套件以及 Noto CJK 中文字體，非常適合用來處理包含中文、日文、韓文等多語系內容的文件。

## 系統需求

- [Docker](https://www.docker.com/)
- Python 3（Linux/macOS 或 Windows WSL）

## 安裝與建置

在專案根目錄下執行以下指令來建置映像檔：

```bash
docker build -t latex-toolkit:main .
```

*注意：因為 `texlive/texlive:latest` 包含完整的 TeX Live 發行版及 Noto CJK 字型，映像檔建置需要較多硬碟空間（約數 GB）與下載時間。*

### 設定為全域指令
以下幾種方法

1. 在 `~/.local/bin` 建立 symlink
  在 `~/.local/bin` 建立名為 `latextk` 的 symlink，即可在任何目錄使用 `latextk`。
  ```bash
  ln -s "path/to/latex-toolkit/latex-toolkit.py" ~/.local/bin/latextk
  ```
  若 `~/.local/bin` 尚未建立，請自行建立目錄，並在 `.bashrc`（或 `.zshrc`，看你用什麼 shell）加入 `export PATH="$HOME/.local/bin:$PATH"`。

1. 新增為 alias
  在你用的 shell 的 rc file（例如 bash 是 .bashrc）中加入 
  ```bash
  alias latextk="/path/to/latex-toolkit/latex-toolkit.py"
  ```

建議使用 symlink 而非 alias，因為 alias 只在互動式 shell 生效，AI agent 等非互動環境讀不到，例如下方使用的 AI Agent Skill，symlink 則兩者都能用。

## 使用方法

本專案提供統一的入口腳本 `latex-toolkit.py`，可藉由第一個參數（子指令）來選擇不同的編譯功能。
這邊預設你在此專案目錄下使用，執行 `./latex-toolkit.py`。如果你已經設定全域指令 latextk，就可以直接把 `./latex-toolkit.py` 換成 latextk

### 1. 使用 XeLaTeX 編譯 LaTeX 檔案 (`xelatex`)

使用 XeLaTeX 編譯 `.tex` 檔案。此指令會使用 `latexmk` 自動執行多遍編譯以處理交叉引用。

```bash
./latex-toolkit.py xelatex <input.tex> [-o output.pdf] [其他選項...]
```

#### 範例：
```bash
./latex-toolkit.py xelatex document.tex
```
*這會生成 `document.pdf`。*

```bash
./latex-toolkit.py xelatex document.tex -o build/report.pdf
```
*這會生成並將 PDF 存放在 `build/report.pdf`。*

#### 中文支援範例 (`xeCJK`)：
若要在 XeLaTeX 中使用中文，可在 `.tex` 檔中使用 `ctex` 類別或 `xeCJK` 套件搭配 Noto 字型：
```latex
\documentclass{ctexart}
\begin{document}
這是 XeLaTeX 中文測試。
\end{document}
```

---

### 2. 使用 LuaLaTeX 編譯 LaTeX 檔案 (`lualatex`)

使用 LuaLaTeX 編譯 `.tex` 檔案。

```bash
./latex-toolkit.py lualatex <input.tex> [-o output.pdf] [其他選項...]
```

#### 範例：
```bash
./latex-toolkit.py lualatex document.tex -o output.pdf
```

#### 中文支援範例 (`luatexja`)：
若要在 LuaLaTeX 中使用中文，可使用 `luatexja-fontspec` 套件並設定 CJK 字型（如 `Noto Sans CJK TC` 或 `Noto Serif CJK TC`）：
```latex
\documentclass{article}
\usepackage{luatexja-fontspec}
\setmainjfont{Noto Sans CJK TC}
\begin{document}
這是 LuaLaTeX 中文測試。
\end{document}
```

---

### 3. 使用 Pandoc 編譯 Markdown 檔案 (`pandoc`)

此功能與原先舊版本完全相容，會使用 Pandoc 將 Markdown 轉換為 PDF，預設會載入中文字型設定標頭並使用 XeLaTeX 引擎。

```bash
./latex-toolkit.py pandoc <markdown_檔案> [額外 pandoc 選項...]
```

#### 參數選項：
- `--no-default-header`：停用容器內預設的 `header.tex`（即使用自訂標頭）。

#### 範例：
```bash
# 基本轉換（自動將輸出檔名設為 .pdf）
./latex-toolkit.py pandoc document.md

# 自訂輸出檔名
./latex-toolkit.py pandoc document.md -o final_report.pdf

# 使用內建正式技術報告範本（直接指定範本名稱即可）
./latex-toolkit.py pandoc document.md --template formal -o final_report.pdf

# 透過參數指定字體：serif / sans / times
./latex-toolkit.py pandoc document.md --template formal -V font=times -o report_times.pdf

# 列出所有可用的範本名稱
./latex-toolkit.py pandoc --list-templates

# 停用預設標頭，使用自訂標頭
./latex-toolkit.py pandoc document.md --no-default-header -H custom_header.tex
```

#### 使用範本

Pandoc 範本存放於 `template/pandoc/` 下，每個範本一個子目錄。使用時以 `--template <名稱>`（或 `-t <名稱>`）指定名稱即可，不需輸入路徑。`formal` 範本的設定變數與字體選項請參閱 [template/pandoc/formal/README.md](template/pandoc/formal/README.md)。

#### 新增範本

例如建立 `academic`：
1. 在 `template/pandoc/` 下建立子資料夾 `template/pandoc/academic/`。
2. 放入 `template.latex`（LaTeX 排版範本）與 `template.yaml`（Pandoc Defaults 設定檔，需設定 `template: /template/academic/template.latex`），另可放入 Lua Filter 等檔案。
3. 之後即可用 `--template academic` 使用。

（`template/pandoc/` 在容器內掛載為 `/template`，所以 yaml 裡的路徑寫 `/template/<名稱>/...`。）

---

### 4. 從 LaTeX 範本建立專案 (`new`)

把 `template/latex/<名稱>/` 裡的檔案複製到指定目錄，建立一個可以直接編譯的 LaTeX 專案。這個指令在本機執行，不需要 Docker。

```bash
./latex-toolkit.py new --list              # 列出可用的 LaTeX 範本
./latex-toolkit.py new homework            # 在當前目錄建立
./latex-toolkit.py new homework hw3        # 在 hw3/ 建立（目錄不存在會自動建立）
./latex-toolkit.py new homework hw3 --force  # 覆蓋已存在的檔案
```

建立後 `cd hw3 && ./latex-toolkit.py xelatex main.tex` 即可編譯。排版設定都放在專案內的 `.cls` 檔，所以專案本身是自給自足的，也能直接上傳到 Overleaf（編譯器選 XeLaTeX）。

內建範本：
- `homework`：作業範本（題號標題、`(1)(2)` 小題、程式碼排版、中文支援），說明見 [template/latex/homework/README.md](template/latex/homework/README.md)。

#### 新增 LaTeX 範本

在 `template/latex/` 下建立子資料夾（例如 `template/latex/report/`），放入要複製到新專案的所有檔案即可。資料夾裡的 `README.md` 不會被複製；空資料夾可放 `.gitkeep`，`new` 只會建立資料夾，不會複製 `.gitkeep`。

---

## 專案結構

- `Dockerfile`: 基於 `texlive/texlive:latest`，內建 Pandoc、Noto CJK 字體以及 fontconfig。
- `entrypoint.sh`: 容器內的啟動腳本，負責分流 `xelatex`、`lualatex` 與 `pandoc`（`new` 由 `latex-toolkit.py` 在本機處理），並進行範本解析與編譯。
- `latex-toolkit.py`: 外部統一 Python 腳本（僅用標準函式庫），掛載當前目錄與範本目錄並將引數傳遞給容器。
- `header.tex`: Pandoc 預設的 LaTeX 標頭檔，用於一般 Markdown 中文支援。
- `template/pandoc/`: Pandoc 範本庫目錄，每個範本以獨立子目錄存放（如 `template/pandoc/formal/`）。
- `template/latex/`: LaTeX 專案範本，供 `new` 子指令複製（如 `template/latex/homework/`）。
- `skills/latex-toolkit/`: 供 AI agent 使用的 Skill（見下方「AI Agent Skill」）。

## AI Agent Skill

`skills/latex-toolkit/SKILL.md` 是一份 Agent Skill，教 AI agent 如何用本工具把 `.tex`／`.md` 編譯成 PDF，內容涵蓋：工作目錄掛載限制、各子指令用法、具名範本與疑難排解。

Skill 內不含任何電腦的絕對路徑。agent 會依序用以下方式找到本工具：`PATH` 上的 `latextk` 指令（見上方「設定為全域指令」）→ 環境變數 `LATEX_TOOLKIT_DIR` → 由 Skill 所在位置（解析 symlink 後往上兩層）推得 repo 根目錄。

### 安裝

將 `skills/latex-toolkit` 複製或建立 symlink 到你的 agent 存放 skill 的資料夾下。
以 claude code 為例，存放 skills 的地方是 `~/.claude/skills` 就可以建立 symlink 到底下
```bash
ln -s "path/to/latex-toolkit/skills/latex-toolkit" ~/.claude/skills/latex-toolkit
```

加入之後可以在 agent 中用 `/latex-toolkit` 手動呼叫。

## VS Code 整合 (LaTeX Workshop)

如果您使用 VS Code 搭配 [LaTeX Workshop](https://marketplace.visualstudio.com/items?itemName=James-Yu.latex-workshop) 擴充功能，可以透過以下設定將其與本工具整合。

請在 VS Code 的 `settings.json` 中配置自訂的 Tool 與 Recipe（**請將 `command` 的值替換為您系統中 `latex-toolkit.py` 的絕對路徑**，例如 `/home/username/latex-toolkit/latex-toolkit.py`）：

```json
{
  "latex-workshop.latex.tools": [
    {
      "name": "docker-xelatex",
      "command": "/path/to/latex-toolkit.py",
      "args": [
        "xelatex",
        "%DOCFILE_EXT%",
        "-o",
        "%DOCFILE%.pdf"
      ],
      "env": {}
    },
    {
      "name": "docker-lualatex",
      "command": "/path/to/latex-toolkit.py",
      "args": [
        "lualatex",
        "%DOCFILE_EXT%",
        "-o",
        "%DOCFILE%.pdf"
      ],
      "env": {}
    }
  ],
  "latex-workshop.latex.recipes": [
    {
      "name": "Docker: XeLaTeX",
      "tools": [
        "docker-xelatex"
      ]
    },
    {
      "name": "Docker: LuaLaTeX",
      "tools": [
        "docker-lualatex"
      ]
    }
  ]
}
```

設定完成後，在 VS Code 編輯 `.tex` 檔案時，即可在左側 TeX 面板選擇 `Docker: XeLaTeX` 或 `Docker: LuaLaTeX` 進行中文編譯。

### 如何為特定檔案指定編譯引擎

如果您的預設編譯方式是 XeLaTeX，但您希望某個特定檔案（例如 `a.tex`）使用 LuaLaTeX 編譯，您可以使用以下三種方式之一：

#### 1. 使用 Magic Comment 魔法註解（最推薦，針對單一檔案）
在該 `.tex` 檔案的**最頂部第一行**，加上 LaTeX Workshop 專用的 Recipe 魔法註解。例如指定使用 LuaLaTeX：

```latex
%!LW recipe=Docker: LuaLaTeX
```
*當您儲存或執行編譯時，LaTeX Workshop 會自動讀取此註解並使用 `Docker: LuaLaTeX` 這套 Recipe 來編譯該檔案。*

#### 2. 修改專案（工作區）預設值
如果您希望整個專案（Workspace）的所有檔案都預設改用 LuaLaTeX，可以在專案根目錄的 `.vscode/settings.json` 中設定：

```json
{
  "latex-workshop.latex.recipe.default": "Docker: LuaLaTeX"
}
```

#### 3. 手動選擇編譯 Recipe
- **側邊欄選單**：點擊 VS Code 左側的 **TeX 標籤**。在 **Build LaTeX project** 列表中，手動點擊 **Docker: LuaLaTeX**。
- **命令列**：按下 `Ctrl + Shift + P` (Mac 上為 `Cmd + Shift + P`)，輸入 `LaTeX Workshop: Build with recipe`，然後選擇 `Docker: LuaLaTeX`。

## 注意事項

- 請確保 `latex-toolkit.py` 具有執行權限 (`chmod +x latex-toolkit.py`)。
- 您的輸入檔案必須位於執行腳本時的當下目錄（或其子目錄）中，才能正確被掛載進 Docker 容器。
