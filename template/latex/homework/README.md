# Homework 作業範本 (LaTeX)

XeLaTeX 作業範本，支援中文（Noto CJK TC），提供題號標題、小題編號、程式碼排版等設定。

## 建立專案

```bash
latextk new homework hw3      # 在 hw3/ 建立專案（省略目錄則建在當前目錄）
cd hw3
latextk xelatex main.tex
```

`new` 會複製以下檔案（本 README 不會被複製）：

- `homework.cls`：所有排版設定。專案自帶這個檔案，所以也可以直接上傳到 Overleaf（編譯器選 XeLaTeX）。
- `main.tex`：作業內容骨架。
- `figure/`：截圖資料夾（已設定 `\graphicspath`，直接寫檔名即可）。
- `code/`：程式碼資料夾，搭配 `\lstinputlisting`。

## main.tex 可設定的地方

| 指令 | 說明 |
| --- | --- |
| `\course{...}` | 課程名稱 |
| `\hwnum{...}` | 作業編號，也會用在題號（例如 `2.1`） |
| `\studentname{...}` | 姓名 |
| `\studentid{...}` | 學號 |
| `\hwtitle` | 在 `\begin{document}` 後輸出標題 |
| `\problem{題目名稱}` | 新的一題，自動編號並畫分隔線 |

小題用 `enumerate`，標籤為 `(1)(2)…`。

## Class 選項

- `showcaption`：顯示 figure 的 `\caption`（預設隱藏，但 `\caption` 內容可以保留不用刪）。
- 其他選項（例如 `11pt`、`letterpaper`）會傳給 `article`。

## 內建環境

- `proof`（標題為 `proof:`，結尾 ■）、`lemma`、`claim`
- `listings` 程式碼樣式（灰底、行號、自動換行）
- `float` 的 `[H]`、`booktabs` 表格
