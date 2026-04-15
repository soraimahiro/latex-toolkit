#!/bin/sh

usage() {
    echo "用法: <markdown_檔案> <header_檔案> [-o 輸出_pdf]"
    echo "範例: hw1.md header.tex -o final_report.pdf"
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

OUTPUT_PDF="${INPUT_MD%.*}.pdf"

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

if [ ! -f "$INPUT_MD" ]; then
    echo "錯誤: 找不到 Markdown 檔案 '$INPUT_MD'"
    exit 1
fi

if [ ! -f "$HEADER_TEX" ]; then
    echo "錯誤: 找不到 Header 檔案 '$HEADER_TEX'"
    exit 1
fi

echo "----------------------------------------"
echo "正在編譯: $INPUT_MD"
echo "使用標頭: $HEADER_TEX"
echo "輸出目標: $OUTPUT_PDF"
echo "----------------------------------------"

exec pandoc "$INPUT_MD" -o "$OUTPUT_PDF" --pdf-engine=xelatex -V geometry="margin=1.5cm" -H "$HEADER_TEX" "$@"
