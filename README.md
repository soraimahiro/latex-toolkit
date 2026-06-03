# LaTeX & Pandoc Docker Toolkit

這是一個基於 Docker 和 `texlive/texlive:latest` 的 LaTeX 與 Pandoc 編譯環境，專門用來將 `.tex` 檔案與 Markdown 檔案編譯或轉換為 PDF。此環境內建了完整的 TeX Live 套件以及 Noto CJK 中文字體，非常適合用來處理包含中文、日文、韓文等多語系內容的文件。

## 系統需求

- [Docker](https://www.docker.com/)
- Bash (Linux/macOS 或 Windows WSL)

## 安裝與建置

在專案根目錄下執行以下指令來建置映像檔：

```bash
docker build -t latex-toolkit:main .
```

*注意：因為 `texlive/texlive:latest` 包含完整的 TeX Live 發行版及 Noto CJK 字型，映像檔建置需要較多硬碟空間（約數 GB）與下載時間。*

## 使用方法

本專案提供統一的入口腳本 `./latex-toolkit.sh`，可藉由第一個參數（子指令）來選擇不同的編譯功能。

### 1. 使用 XeLaTeX 編譯 LaTeX 檔案 (`xelatex`)

使用 XeLaTeX 編譯 `.tex` 檔案。此指令會使用 `latexmk` 自動執行多遍編譯以處理交叉引用。

```bash
./latex-toolkit.sh xelatex <input.tex> [-o output.pdf] [其他選項...]
```

#### 範例：
```bash
./latex-toolkit.sh xelatex document.tex
```
*這會生成 `document.pdf`。*

```bash
./latex-toolkit.sh xelatex document.tex -o build/report.pdf
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
./latex-toolkit.sh lualatex <input.tex> [-o output.pdf] [其他選項...]
```

#### 範例：
```bash
./latex-toolkit.sh lualatex document.tex -o output.pdf
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
./latex-toolkit.sh pandoc <markdown_檔案> [額外 pandoc 選項...]
```

#### 參數選項：
- `--no-default-header`：停用容器內預設的 `header.tex`（即使用自訂標頭）。

#### 範例：
```bash
# 基本轉換（自動將輸出檔名設為 .pdf）
./latex-toolkit.sh pandoc document.md

# 自訂輸出檔名
./latex-toolkit.sh pandoc document.md -o final_report.pdf

# 停用預設標頭，使用自訂標頭
./latex-toolkit.sh pandoc document.md --no-default-header -H custom_header.tex
```

---

## 專案結構

- `Dockerfile`: 基於 `texlive/texlive:latest`，內建 Pandoc、Noto CJK 字體以及 fontconfig。
- `entrypoint.sh`: 容器內的啟動腳本，負責分流 `xelatex`、`lualatex` 與 `pandoc`，並進行對應的參數解析與編譯。
- `latex-toolkit.sh`: 外部用的統一 Shell 腳本，掛載當前目錄並將所有引數透傳給容器。
- `header.tex`: Pandoc 預設的 LaTeX 標頭檔範本，主要用於 Pandoc Markdown 中文支援。

## VS Code 整合 (LaTeX Workshop)

如果您使用 VS Code 搭配 [LaTeX Workshop](https://marketplace.visualstudio.com/items?itemName=James-Yu.latex-workshop) 擴充功能，可以透過以下設定將其與本工具整合。

請在 VS Code 的 `settings.json` 中配置自訂的 Tool 與 Recipe（**請將 `command` 的值替換為您系統中 `latex-toolkit.sh` 的絕對路徑**，例如 `/home/username/latex-toolkit/latex-toolkit.sh`）：

```json
{
  "latex-workshop.latex.tools": [
    {
      "name": "docker-xelatex",
      "command": "/path/to/latex-toolkit.sh",
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
      "command": "/path/to/latex-toolkit.sh",
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

## 注意事項

- 請確保 `latex-toolkit.sh` 具有執行權限 (`chmod +x latex-toolkit.sh`)。
- 您的輸入檔案必須位於執行腳本時的當下目錄（或其子目錄）中，才能正確被掛載進 Docker 容器。
