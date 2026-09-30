#!/bin/bash

# 尋找具名範本目錄中的設定檔或 LaTeX 範本
find_named_template() {
    local name="$1"
    # 若為已存在之實體檔案或明確路徑，則不視為具名範本名稱
    if [ -f "$name" ]; then
        return 1
    fi

    # 依序搜尋當前工作目錄與工具箱內建範本目錄
    for base in "/data/template/$name" "/data/templates/$name" "/template/$name"; do
        if [ -f "$base/template.yaml" ]; then
            echo "--defaults=$base/template.yaml"
            return 0
        elif [ -f "$base/$name.yaml" ]; then
            echo "--defaults=$base/$name.yaml"
            return 0
        elif [ -f "$base/template.latex" ]; then
            echo "--template=$base/template.latex"
            return 0
        elif [ -f "$base/$name.latex" ]; then
            echo "--template=$base/$name.latex"
            return 0
        fi
    done
    return 1
}

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

    # 檢查是否列出所有可用範本
    if [ "$1" = "--list-templates" ] || [ "$1" = "-l" ]; then
        echo "可用的 Pandoc 範本列表："
        for d in /template/* /data/template/*; do
            if [ -d "$d" ]; then
                tname=$(basename "$d")
                echo "  - $tname"
            fi
        done | sort -u
        exit 0
    fi

    USE_DEFAULT_HEADER=true
    HAS_CUSTOM_TEMPLATE=false
    HAS_RESOURCE_PATH=false
    HAS_OUT=false
    INPUT_MD=""

    # 預處理參數：解析具名範本（如 --template formal 或 -d formal）
    PROCESSED_ARGS=()
    while [ $# -gt 0 ]; do
        case "$1" in
            --template=*)
                VAL="${1#--template=}"
                if RESOLVED=$(find_named_template "$VAL"); then
                    PROCESSED_ARGS+=("$RESOLVED")
                    HAS_CUSTOM_TEMPLATE=true
                    USE_DEFAULT_HEADER=false
                else
                    PROCESSED_ARGS+=("$1")
                    HAS_CUSTOM_TEMPLATE=true
                    USE_DEFAULT_HEADER=false
                fi
                shift
                ;;
            --template|-t)
                VAL="$2"
                if [ -n "$VAL" ] && RESOLVED=$(find_named_template "$VAL"); then
                    PROCESSED_ARGS+=("$RESOLVED")
                    HAS_CUSTOM_TEMPLATE=true
                    USE_DEFAULT_HEADER=false
                    shift 2
                else
                    PROCESSED_ARGS+=("$1")
                    HAS_CUSTOM_TEMPLATE=true
                    USE_DEFAULT_HEADER=false
                    shift
                fi
                ;;
            -t*)
                VAL="${1#-t}"
                if RESOLVED=$(find_named_template "$VAL"); then
                    PROCESSED_ARGS+=("$RESOLVED")
                    HAS_CUSTOM_TEMPLATE=true
                    USE_DEFAULT_HEADER=false
                else
                    PROCESSED_ARGS+=("$1")
                    HAS_CUSTOM_TEMPLATE=true
                    USE_DEFAULT_HEADER=false
                fi
                shift
                ;;
            --defaults=*)
                VAL="${1#--defaults=}"
                if RESOLVED=$(find_named_template "$VAL"); then
                    PROCESSED_ARGS+=("$RESOLVED")
                    HAS_CUSTOM_TEMPLATE=true
                    USE_DEFAULT_HEADER=false
                else
                    PROCESSED_ARGS+=("$1")
                    HAS_CUSTOM_TEMPLATE=true
                    USE_DEFAULT_HEADER=false
                fi
                shift
                ;;
            --defaults|-d)
                VAL="$2"
                if [ -n "$VAL" ] && RESOLVED=$(find_named_template "$VAL"); then
                    PROCESSED_ARGS+=("$RESOLVED")
                    HAS_CUSTOM_TEMPLATE=true
                    USE_DEFAULT_HEADER=false
                    shift 2
                else
                    PROCESSED_ARGS+=("$1")
                    HAS_CUSTOM_TEMPLATE=true
                    USE_DEFAULT_HEADER=false
                    shift
                fi
                ;;
            -d*)
                VAL="${1#-d}"
                if RESOLVED=$(find_named_template "$VAL"); then
                    PROCESSED_ARGS+=("$RESOLVED")
                    HAS_CUSTOM_TEMPLATE=true
                    USE_DEFAULT_HEADER=false
                else
                    PROCESSED_ARGS+=("$1")
                    HAS_CUSTOM_TEMPLATE=true
                    USE_DEFAULT_HEADER=false
                fi
                shift
                ;;
            -H*|--include-in-header*)
                USE_DEFAULT_HEADER=false
                PROCESSED_ARGS+=("$1")
                shift
                ;;
            --no-default-header)
                USE_DEFAULT_HEADER=false
                shift
                ;;
            *)
                PROCESSED_ARGS+=("$1")
                shift
                ;;
        esac
    done
    set -- "${PROCESSED_ARGS[@]}"

    # 第二次掃描：尋找輸入檔案、輸出設定與資源路徑
    for arg in "$@"; do
        case "$arg" in
            --resource-path*)
                HAS_RESOURCE_PATH=true
                ;;
            -o)
                HAS_OUT=true
                ;;
            -o*)
                HAS_OUT=true
                ;;
            -*)
                # 忽略其他參數
                ;;
            *)
                if [ -z "$INPUT_MD" ]; then
                    INPUT_MD="$arg"
                fi
                ;;
        esac
    done

    if [ -z "$INPUT_MD" ]; then
        echo "用法: ./latex-toolkit.sh pandoc <markdown_檔案> [額外 pandoc 選項...]"
        echo "範本選項: "
        echo "  --template <名稱>    使用指定的範本名稱（例如 formal）"
        echo "  -d <名稱>            同上，載入指定範本的 Defaults 檔"
        echo "  --list-templates     列出所有可用範本"
        echo "  --no-default-header  停用預設的 header.tex"
        exit 1
    fi

    # 如果沒有指定輸出，自動加上同名 .pdf
    if [ "$HAS_OUT" = false ]; then
        OUTPUT_PDF="${INPUT_MD%.*}.pdf"
        set -- "$@" -o "$OUTPUT_PDF"
    fi

    # 自動加入資源搜尋路徑（圖片等）：工作目錄與 Markdown 檔案所在目錄
    if [ "$HAS_RESOURCE_PATH" = false ] && [ -n "$INPUT_MD" ]; then
        INPUT_DIR=$(dirname "$INPUT_MD")
        if [ "$INPUT_DIR" != "." ]; then
            set -- "$@" --resource-path=".:$INPUT_DIR"
        fi
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

    if [ "$HAS_CUSTOM_TEMPLATE" = true ]; then
        exec pandoc "$@"
    else
        exec pandoc "$@" --pdf-engine=xelatex -V geometry="margin=1.5cm"
    fi

else
    echo "錯誤: 未知的指令 '$1'"
    echo "用法: ./latex-toolkit.sh <指令> [參數...]"
    echo "指令列表:"
    echo "  xelatex   <tex_檔案> [-o 輸出.pdf]   使用 XeLaTeX 編譯 LaTeX"
    echo "  lualatex  <tex_檔案> [-o 輸出.pdf]   使用 LuaLaTeX 編譯 LaTeX"
    echo "  pandoc    <md_檔案>  [其他參數...]    使用 Pandoc 編譯 Markdown"
    exit 1
fi
