# Pandoc Docker PDF Generator

這是一個基於 Docker 和 Alpine Linux 的 Pandoc 編譯環境，專門用來將 Markdown 檔案轉換為 PDF。此映像檔內建了 LaTeX (XeTeX) 以及 Noto CJK 字體，非常適合用來處理包含中文、日文、韓文等多語系內容的文件。

## 系統需求

- [Docker](https://www.docker.com/)
- Bash (Linux/macOS 或 Windows WSL)

## 安裝與建置

**硬碟容量須知**：由於映像檔包含了 Texlive 的軟體包，因此容量佔用較大，約佔用 1.2 GB。在拉取或建置前請檢查硬碟剩餘容量是否足夠。

在使用腳本之前，您需要先取得 `pandoc-docker:main` Docker 映像檔。

在任意目錄執行以下指令來拉取映像檔：

```bash
docker pull ghcr.io/minstrike520/pandoc-docker:main
```

或者，在專案根目錄下執行以下指令來自行建置映像檔：

```bash
docker build -t pandoc-docker:main .
```

## 使用方法

使用提供的 `pandoc-docker.sh` 腳本來進行文件轉換，腳本會自動掛載當前目錄並執行轉換。

關於 Pandoc 支援的 Markdown 語法，請參見[Pandoc 官方文件](https://pandoc.org/MANUAL.html)。

值得注意的是，Pandoc 支援在 Markdown 新增 [YAML Frontmatter](https://jekyllrb.com/docs/front-matter/) 以對輸出進行細項調整。比如，以下設置會在封面加入標題「期末報告」，並註明著作日期「2024/3/20」與作者「小明」：


```yaml
title: "期末報告"
author: "小明"
date: "2024-03-20"
```

欲知完整的語法說明，請參照 [#Metadata variables](https://pandoc.org/MANUAL.html#metadata-variables)。

### 基本語法

```bash
./pandoc-docker.sh <markdown_檔案> [額外 pandoc 選項...]
```

如果想要使用非預設的映像檔名稱，請指定環境變數 `$PANDOC_DOCKER_IMAGE`：

```bash
PANDOC_DOCKER_IMAGE="my-pandoc:latest" ./pandoc-docker.sh (...)
```

也可以傳入 `--no-default-header` 來停用預設的 `header.tex`：

```bash
./pandoc-docker.sh document.md --no-default-header -H custom_header.tex
```

### 範例

1. **基本轉換** (自動使用預設標頭檔，並將輸出檔名設為 `.pdf`)：
   ```bash
   ./pandoc-docker.sh document.md
   ```
   *這將會產出 `document.pdf`*

2. **自訂輸出檔名**：
   ```bash
   ./pandoc-docker.sh document.md -o final_report.pdf
   ```

3. **加入額外標頭檔**：
   ```bash
   ./pandoc-docker.sh document.md -H extra_header1.tex -H extra_header2.tex
   ```

## 專案結構

- `Dockerfile`: 定義了包含 Pandoc、TeX Live 和 CJK 字體的 Alpine 映像檔，並預先載入預設的標頭檔與執行腳本。
- `entrypoint.sh`: 容器內部的啟動腳本，負責解析參數、自動補上輸出檔名與預設標頭檔。
- `pandoc-docker.sh`: 外部用的 Shell 腳本，封裝了 Docker 掛載與執行指令，其餘引數直接透傳給容器。
- `header.tex`: LaTeX 標頭檔預設範本（包含中文字體設定等），已內建於映像檔中。

## 腳本運作原理

`pandoc-docker.sh` 會將當前目錄 (`$(pwd)`) 掛載至容器的 `/data` 目錄，並使用當前使用者的 UID 及 GID 啟動容器。
後續編譯邏輯由容器內的 `entrypoint.sh` 接手處理：
- 若未指定輸出檔，則自動將輸出檔名設為與輸入檔相同的 `.pdf`。
- 預設載入映像檔內的 `/default_header.tex`（即 `header.tex`）以提供中文支援，除非傳入了 `--no-default-header`。
- 自動設定 PDF 引擎為 `xelatex` 以及頁面邊距 `-V geometry="margin=1.5cm"`。
- 將您傳入的其餘參數（例如多個 `-H`）直接傳遞給 Pandoc。

## 注意事項

- 請確保 `pandoc-docker.sh` 具有執行權限 (`chmod +x pandoc-docker.sh`)。
- 您的 Markdown 檔案與 header 檔案必須位於執行腳本時的當下目錄（或其子目錄）中，才能正確掛載進 Docker 容器。
