# Formal 技術報告範本 (Formal Template)

專為正式報告、技術規格書、評估報告與論文設計之排版範本。

## 檔案說明
- `template.latex`：XeLaTeX 排版範本主檔。
- `template.example.yaml`：Pandoc Defaults 設定範例（納入 git，選用的預設值皆為註解）。
- `template.yaml`：實際使用的設定檔，由範例複製而來，自行修改（不納入 git，需自行建立：`cp template.example.yaml template.yaml`）。
- `table-grid.lua`：表格全框線過濾器（自動注入直橫格線）。
- `image-align.lua`：圖片對齊過濾器（支援 `{align=...}`）。
- `example.md`：示範文件。
- `hello.png`：示範圖片。

## 使用方式
首次使用請先複製設定範例（`template.yaml` 不納入 git）：

```bash
cp template/formal/template.example.yaml template/formal/template.yaml
```

之後直接指定範本名稱即可，無需輸入檔案路徑：

```bash
# 基本編譯
./latex-toolkit.sh pandoc mydoc.md --template formal -o output.pdf

# 亦可使用簡寫
./latex-toolkit.sh pandoc mydoc.md -t formal -o output.pdf

# 動態切換字體（serif / sans / times）
./latex-toolkit.sh pandoc mydoc.md --template formal -V font=times -o output.pdf
```

## 可設定的變數

變數有三種設定方式，優先順序為 **`-V` > md front matter > template.yaml**：

1. 指令列 `-V 名稱=值`，例如 `-V fontsize=12pt`（臨時覆蓋）
2. md 檔開頭的 YAML front matter（單一文件）
3. `template.yaml` 的 `variables:` 區塊（所有使用此範本的文件的預設值）

template.yaml 的變數必須加 `default-` 前綴，否則會蓋過 md 的設定：

```yaml
# template.yaml
variables:
  default-font: sans
  default-fontsize: 12pt
```

可在 template.yaml 設預設值的有 `font`、`fontsize`、`papersize`、`geometry`、`documentclass`、`toc-depth`、`secnumdepth`（加上 `default-` 前綴）。其餘變數請在 md 或 `-V` 設定。

### 文件資訊

| 變數 | 說明 | 預設 |
|---|---|---|
| `title` | 標題 | 無（未設定則不產生標題區） |
| `subtitle` | 副標題 | 無 |
| `author` | 作者（單一字串，多位作者請自行以「、」或「,」分隔） | 無 |
| `date` | 日期 | 無 |
| `thanks` | 標題的註腳（致謝） | 無 |
| `abstract` | 摘要（需有 `title` 才會顯示） | 無 |

### 字體與版面

| 變數 | 說明 | 預設 |
|---|---|---|
| `font` | 字體：`serif`（明體）、`sans`（黑體）、`times`（Times） | `serif`（Noto Serif） |
| `fontsize` | 內文字級，如 `10pt`、`11pt`、`12pt` | `11pt` |
| `papersize` | 紙張，如 `a4`、`letter` | `a4` |
| `geometry` | 頁面邊界，可為清單，如 `margin=2.5cm` | `a4paper,margin=2.0cm` |
| `documentclass` | LaTeX 文件類別，如 `article`、`report` | `article` |
| `classoption` | 傳給文件類別的額外選項，可為清單 | 無 |

### 目錄與章節編號

| 變數 | 說明 | 預設 |
|---|---|---|
| `toc` | 設為 `true` 產生目錄 | 關閉 |
| `toc-depth` | 目錄深度 | `3` |
| `numbersections` | 設為 `true` 自動編號章節 | 關閉（以 md 原文編號為準） |
| `secnumdepth` | 自動編號深度（需啟用 `numbersections`） | `5` |

### 進階

| 變數 | 說明 |
|---|---|
| `include-before` | 在正文前插入 LaTeX 內容 |
| `include-after` | 在正文後插入 LaTeX 內容 |

### 範例

```yaml
---
title: "系統架構與技術評估報告"
subtitle: "Formal Document Template"
author: "王小明、李小華"
date: "2026-09-30"
font: times
fontsize: 12pt
toc: true
numbersections: true
---
```

## 圖片大小與對齊

在圖片後以 `{...}` 設定，多個屬性以空白分隔：

```markdown
![說明](hello.png){width=50%}
![說明](hello.png){width=4cm align=left}
![說明](hello.png){height=3cm align=right}
```

- `width`、`height`：可用 `%`（相對版面寬度）、`cm`、`mm`、`in`、`pt`；只設一個時維持長寬比。
- `align`：`left`、`center`（預設）、`right`。僅對有說明文字的圖片（`![說明](...)`）有效。
- 圖片不浮動，依 md 原文順序排版；放不下時圖片換頁。

表格預設靠左對齊，欄內對齊以 md 表格的 `:---`、`---:`、`:---:` 指定。
