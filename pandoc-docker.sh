#!/bin/bash

# 常數

DOCKER_IMAGE=pandoc-alpine:latest

# 用法提示函式
usage() {
    echo "用法: $0 <markdown_檔案> <header_檔案> [-o 輸出_pdf]"
    echo "範例: $0 hw1.md header.tex -o final_report.pdf"
    exit 1
}

# 檢查必填參數數量
if [ "$#" -lt 2 ]; then
    echo "錯誤: 參數不足。"
    usage
fi

INPUT_MD="$1"
HEADER_TEX="$2"
shift 2

# 設定預設輸出檔名（將 .md 替換為 .pdf）
OUTPUT_PDF="${INPUT_MD%.*}.pdf"

# 解析可選的 -o 參數
while getopts ":o:" opt; do
  case $opt in
    o)
      OUTPUT_PDF="$OPTARG"
      ;;
    \?)
      echo "錯誤: 無效的選項 -$OPTARG"
      usage
      ;;
    :)
      echo "錯誤: 選項 -$OPTARG 需要參數。"
      usage
      ;;
  esac
done

# 檢查輸入檔案是否存在
if [ ! -f "$INPUT_MD" ]; then
    echo "錯誤: 找不到 Markdown 檔案 '$INPUT_MD'"
    exit 1
fi

if [ ! -f "$HEADER_TEX" ]; then
    echo "錯誤: 找不到 Header 檔案 '$HEADER_TEX'"
    exit 1
fi

# 執行 Docker 編譯
echo "----------------------------------------"
echo "正在編譯: $INPUT_MD"
echo "使用標頭: $HEADER_TEX"
echo "輸出目標: $OUTPUT_PDF"
echo "----------------------------------------"

docker run --rm \
  -v "$(pwd):/data" \
  -u $(id -u):$(id -g) \
  $DOCKER_IMAGE \
  "$INPUT_MD" -o "$OUTPUT_PDF" \
  --pdf-engine=xelatex \
  -V geometry="margin=1.5cm" \
  -H "$HEADER_TEX"

# 檢查執行結果
if [ $? -eq 0 ]; then
    echo "----------------------------------------"
    echo "成功: PDF 已生成於 $OUTPUT_PDF"
    ls -l "$OUTPUT_PDF"
else
    echo "----------------------------------------"
    echo "失敗: 編譯過程中發生錯誤。"
    exit 1
fi
