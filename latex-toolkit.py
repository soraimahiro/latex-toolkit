#!/usr/bin/env python3
"""latex-toolkit：以 Docker 容器編譯 LaTeX / Markdown 的統一入口。

所有引數交由容器內的 entrypoint.sh 處理（xelatex / lualatex / pandoc 子指令）。
"""

import os
import subprocess
import sys
from pathlib import Path

# 常數
LOCAL_IMAGE = "latex-toolkit:main"
OLD_LOCAL_IMAGE = "pandoc-docker:main"
GHCR_IMAGE = "ghcr.io/minstrike520/pandoc-docker:main"

# 跟隨 symlink，確保從任何位置呼叫都能找到 entrypoint.sh 與 template/
SCRIPT_DIR = Path(__file__).resolve().parent


def run_quiet(*cmd: str) -> bool:
    """執行指令並隱藏輸出，回傳是否成功。"""
    try:
        result = subprocess.run(
            cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
        )
    except FileNotFoundError:
        return False
    return result.returncode == 0


def docker_available() -> bool:
    return run_quiet("docker", "info")


def image_exists(image: str) -> bool:
    return run_quiet("docker", "image", "inspect", image)


def select_image() -> str:
    """決定要使用的 Docker 映像檔，找不到時結束程式。"""
    for env_var in ("LATEX_TOOLKIT_IMAGE", "PANDOC_DOCKER_IMAGE"):
        image = os.environ.get(env_var)
        if image:
            if not image_exists(image):
                sys.exit(f"錯誤：找不到映像檔 '{image}'")
            return image

    for image in (LOCAL_IMAGE, OLD_LOCAL_IMAGE, GHCR_IMAGE):
        if image_exists(image):
            print(f"使用映像檔 '{image}'")
            return image

    sys.exit(
        f"錯誤：找不到映像檔 '{LOCAL_IMAGE}'、'{OLD_LOCAL_IMAGE}' 或 '{GHCR_IMAGE}'"
    )


def main() -> None:
    if not docker_available():
        sys.exit("錯誤: 無法連接 Docker daemon。請確認 Docker 已啟動且您有執行權限。")

    image = select_image()
    sys.stdout.flush()

    cmd = [
        "docker", "run", "--rm",
        "-e", "XDG_CACHE_HOME=/tmp/.cache",
        "-v", f"{Path.cwd()}:/data",
        "-v", f"{SCRIPT_DIR / 'entrypoint.sh'}:/entrypoint.sh",
        "-v", f"{SCRIPT_DIR / 'template'}:/template:ro",
        "-u", f"{os.getuid()}:{os.getgid()}",
        image,
        *sys.argv[1:],
    ]
    # 以 docker 取代目前行程，讓 exit code 與 Ctrl-C 直接傳遞
    os.execvp("docker", cmd)


if __name__ == "__main__":
    main()
