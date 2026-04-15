#!/bin/sh

USE_DEFAULT_HEADER=true
HAS_OUT=false
INPUT_MD=""

# 第一次掃描：尋找主要參數
for arg in "$@"; do
    case "$arg" in
        --no-default-header)
            USE_DEFAULT_HEADER=false
            ;;
        -o)
            HAS_OUT=true
            ;;
        -o*)
            HAS_OUT=true
            ;;
        -*)
            # 忽略其他 - 開頭的參數
            ;;
        *)
            if [ -z "$INPUT_MD" ]; then
                INPUT_MD="$arg"
            fi
            ;;
    esac
done

# 移除我們的自訂選項，保留原生 pandoc 選項
for arg do
    shift
    case "$arg" in
        --no-default-header) continue ;;
        *) set -- "$@" "$arg" ;;
    esac
done

if [ -z "$INPUT_MD" ]; then
    echo "用法: <markdown_檔案> [額外 pandoc 選項...]"
    echo "自訂選項: "
    echo "  --no-default-header    停用預設的 header.tex"
    exit 1
fi

# 如果沒有指定輸出，自動加上
if [ "$HAS_OUT" = false ]; then
    OUTPUT_PDF="${INPUT_MD%.*}.pdf"
    set -- "$@" -o "$OUTPUT_PDF"
fi

# 如果需要預設 header，自動加上
if [ "$USE_DEFAULT_HEADER" = true ] && [ -f "/default_header.tex" ]; then
    set -- "$@" -H "/default_header.tex"
fi

echo "----------------------------------------"
echo "編譯檔案: $INPUT_MD"
echo "使用預設 Header: $USE_DEFAULT_HEADER"
if [ "$HAS_OUT" = false ]; then
    echo "自動輸出檔案: $OUTPUT_PDF"
fi
echo "參數清單: $@"
echo "----------------------------------------"

exec pandoc "$@" --pdf-engine=xelatex -V geometry="margin=1.5cm"
