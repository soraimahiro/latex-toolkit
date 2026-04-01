# Pandoc Docker PDF Generator

這是一個基於 Docker 和 Alpine Linux 的 Pandoc 編譯環境，專門用來將 Markdown 檔案轉換為 PDF。此映像檔內建了 LaTeX (XeTeX) 以及 Noto CJK 字體，非常適合用來處理包含中文、日文、韓文等多語系內容的文件。

## 系統需求

- [Docker](https://www.docker.com/)
- Bash (Linux/macOS 或 Windows WSL)

## 安裝與建置

在使用腳本之前，您需要先建立 Docker 映像檔。映像檔名稱預設為 `pandoc-alpine:latest`。

在專案根目錄下執行以下指令來建置映像檔：

```bash
docker build -t pandoc-alpine:latest .
```

## 使用方法

使用提供的 `pandoc-docker.sh` 腳本來進行文件轉換，腳本會自動掛載當前目錄並執行轉換。

### 基本語法

```bash
./pandoc-docker.sh <markdown_檔案> <header_檔案> [-o 輸出_pdf]
```

### 範例

1. **基本轉換** (自動將輸出檔名設為與輸入檔相同的 `.pdf`)：
   ```bash
   ./pandoc-docker.sh document.md header.tex
   ```
   *這將會產出 `document.pdf`*

2. **自訂輸出檔名**：
   ```bash
   ./pandoc-docker.sh document.md header.tex -o final_report.pdf
   ```

## 專案結構

- `Dockerfile`: 定義了包含 Pandoc、TeX Live 和 CJK 字體的 Alpine 映像檔。
- `pandoc-docker.sh`: 執行轉換的 Shell 腳本，封裝了 Docker 的執行指令，方便快速生成 PDF。
- `header.tex`: LaTeX 標頭檔範例（可用來自訂字體、邊界、段落格式等）。

## 腳本運作原理

`pandoc-docker.sh` 會讀取您的輸入文件，並透過以下設定來啟動 Docker 容器：
- 將當前目錄 (`$(pwd)`) 掛載至容器的 `/data` 目錄。
- 使用您當前使用者的 UID 及 GID 執行，確保生成的 PDF 具有正確的檔案權限。
- 指定 PDF 引擎為 `xelatex` 以完整支援 Unicode 和 CJK 字體。
- 設定頁面邊距 `-V geometry="margin=1.5cm"`。
- 引入指定的 LaTeX 標頭檔 `-H "$HEADER_TEX"`。

## 注意事項

- 請確保 `pandoc-docker.sh` 具有執行權限 (`chmod +x pandoc-docker.sh`)。
- 您的 Markdown 檔案與 header 檔案必須位於執行腳本時的當下目錄（或其子目錄）中，才能正確掛載進 Docker 容器。