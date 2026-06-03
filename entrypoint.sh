#!/bin/sh

if [ "$1" = "xelatex" ] || [ "$1" = "lualatex" ]; then
    ENGINE="$1"
    shift

    INPUT_TEX=""
    OUTPUT_PDF=""
    OTHER_ARGS=""

    while [ $# -gt 0 ]; do
        case "$1" in
            -o)
                OUTPUT_PDF="$2"
                shift 2
                ;;
            -o*)
                OUTPUT_PDF="${1#-o}"
                shift
                ;;
            -*)
                OTHER_ARGS="$OTHER_ARGS $1"
                shift
                ;;
            *)
                if [ -z "$INPUT_TEX" ]; then
                    INPUT_TEX="$1"
                else
                    OTHER_ARGS="$OTHER_ARGS $1"
                fi
                shift
                ;;
        esac
    done

    if [ -z "$INPUT_TEX" ]; then
        echo "用法: ./latex-toolkit.sh $ENGINE <tex_檔案> [-o 輸出檔案.pdf] [其他 latexmk 選項...]"
        exit 1
    fi

    # 決定 latexmk 的引擎選項
    if [ "$ENGINE" = "xelatex" ]; then
        LATEXMK_ENGINE="-pdfxe"
    else
        LATEXMK_ENGINE="-pdflua"
    fi

    echo "----------------------------------------"
    echo "編譯引擎: $ENGINE"
    echo "輸入檔案: $INPUT_TEX"
    if [ -n "$OUTPUT_PDF" ]; then
        echo "輸出檔案: $OUTPUT_PDF"
    fi
    echo "其他參數: $OTHER_ARGS"
    echo "----------------------------------------"

    # 執行 latexmk 編譯
    latexmk $LATEXMK_ENGINE -interaction=nonstopmode $OTHER_ARGS "$INPUT_TEX"
    EXIT_CODE=$?

    if [ $EXIT_CODE -ne 0 ]; then
        echo "編譯失敗！"
        exit $EXIT_CODE
    fi

    # 預設產出的 PDF 路徑為將 .tex 換成 .pdf
    DEFAULT_PDF="${INPUT_TEX%.*}.pdf"

    # 如果有指定輸出檔案，且與預設產出不同，則將其移動至指定位置
    if [ -n "$OUTPUT_PDF" ] && [ "$DEFAULT_PDF" != "$OUTPUT_PDF" ]; then
        # 確保輸出的父目錄存在
        OUTPUT_DIR=$(dirname "$OUTPUT_PDF")
        if [ ! -d "$OUTPUT_DIR" ]; then
            mkdir -p "$OUTPUT_DIR"
        fi
        mv "$DEFAULT_PDF" "$OUTPUT_PDF"
    fi

    echo "編譯完成！"
    exit 0

elif [ "$1" = "pandoc" ]; then
    shift

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
        echo "用法: ./latex-toolkit.sh pandoc <markdown_檔案> [額外 pandoc 選項...]"
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

else
    echo "錯誤: 未知的指令 '$1'"
    echo "用法: ./latex-toolkit.sh <指令> [參數...]"
    echo "指令列表:"
    echo "  xelatex   <tex_檔案> [-o 輸出.pdf]   使用 XeLaTeX 編譯 LaTeX"
    echo "  lualatex  <tex_檔案> [-o 輸出.pdf]   使用 LuaLaTeX 編譯 LaTeX"
    echo "  pandoc    <md_檔案>  [其他參數...]    使用 Pandoc 編譯 Markdown"
    exit 1
fi
