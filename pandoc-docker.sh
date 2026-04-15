#!/bin/bash

# 常數
LOCAL_IMAGE="pandoc-docker:main"
GHCR_IMAGE="ghcr.io/minstrike520/pandoc-docker:main"

# 檢查 Docker 執行權限
if ! docker info >/dev/null 2>&1; then
    echo "錯誤: 無法連接 Docker daemon。請確認 Docker 已啟動且您有執行權限。"
    exit 1
fi

# 決定要使用的 Docker 映像檔
if [ -n "$PANDOC_DOCKER_IMAGE" ]; then
    if ! docker image inspect "$PANDOC_DOCKER_IMAGE" >/dev/null 2>&1; then
      echo "錯誤：找不到映像檔 '$PANDOC_DOCKER_IMAGE'"
      exit 1
    fi
    DOCKER_IMAGE="$PANDOC_DOCKER_IMAGE"
else
    if docker image inspect "$LOCAL_IMAGE" >/dev/null 2>&1; then
        DOCKER_IMAGE="$LOCAL_IMAGE"
        echo "使用映像檔 '$LOCAL_IMAGE'"
    elif docker image inspect "$GHCR_IMAGE" >/dev/null 2>&1; then
        DOCKER_IMAGE="$GHCR_IMAGE"
        echo "使用映像檔 '$GHCR_IMAGE'"
    else
        echo "錯誤：找不到映像檔 '$LOCAL_IMAGE' 或 '$GHCR_IMAGE'"
        exit 1
    fi
fi

# 執行 Docker，所有引數交由 container 內的 entrypoint.sh 處理
docker run --rm \
  -v "$(pwd):/data" \
  -u $(id -u):$(id -g) \
  $DOCKER_IMAGE \
  "$@"
