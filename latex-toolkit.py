#!/usr/bin/env python3
"""latex-toolkit：以 Docker 容器編譯 LaTeX / Markdown 的統一入口。

`new` 子指令在本機執行（複製 LaTeX 範本）；其餘引數交由容器內的
entrypoint.sh 處理（xelatex / lualatex / pandoc 子指令）。
"""

import argparse
import os
import shutil
import subprocess
import sys
from pathlib import Path

# 常數
LOCAL_IMAGE = "latex-toolkit:main"
OLD_LOCAL_IMAGE = "pandoc-docker:main"
GHCR_IMAGE = "ghcr.io/minstrike520/pandoc-docker:main"

# 跟隨 symlink，確保從任何位置呼叫都能找到 entrypoint.sh 與 template/
SCRIPT_DIR = Path(__file__).resolve().parent
LATEX_TEMPLATE_DIR = SCRIPT_DIR / "template" / "latex"
# 範本目錄中不複製到新專案的檔案
TEMPLATE_SKIP = {"README.md", ".DS_Store"}


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


def latex_templates() -> list[str]:
    if not LATEX_TEMPLATE_DIR.is_dir():
        return []
    return sorted(p.name for p in LATEX_TEMPLATE_DIR.iterdir() if p.is_dir())


def cmd_new(args: list[str]) -> None:
    """在本機複製 LaTeX 範本，建立新專案（不需要 Docker）。"""
    parser = argparse.ArgumentParser(
        prog="latextk new",
        description="從 LaTeX 範本建立新專案",
    )
    parser.add_argument("name", nargs="?", help="範本名稱（例如 homework）")
    parser.add_argument("dir", nargs="?", default=".", help="目標目錄（預設為當前目錄）")
    parser.add_argument("-l", "--list", action="store_true", help="列出可用的 LaTeX 範本")
    parser.add_argument("-f", "--force", action="store_true", help="覆蓋已存在的檔案")
    opts = parser.parse_args(args)

    available = latex_templates()
    if opts.list or not opts.name:
        print("可用的 LaTeX 範本：")
        for name in available:
            print(f"  - {name}")
        if not opts.list:
            parser.print_usage()
        return

    if opts.name not in available:
        sys.exit(f"錯誤：找不到 LaTeX 範本 '{opts.name}'。可用範本：{', '.join(available)}")

    src = LATEX_TEMPLATE_DIR / opts.name
    dest = Path(opts.dir)
    files = [
        p.relative_to(src)
        for p in sorted(src.rglob("*"))
        if p.is_file() and p.name not in TEMPLATE_SKIP
    ]

    # .gitkeep 只用來讓空資料夾進 git，新專案只需建立資料夾
    dirs = [f.parent for f in files if f.name == ".gitkeep"]
    files = [f for f in files if f.name != ".gitkeep"]

    conflicts = [f for f in files if (dest / f).exists()]
    if conflicts and not opts.force:
        print("錯誤：以下檔案已存在（加上 --force 覆蓋）：", file=sys.stderr)
        for f in conflicts:
            print(f"  {dest / f}", file=sys.stderr)
        sys.exit(1)

    for f in files:
        target = dest / f
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src / f, target)
        print(f"建立 {target}")
    for d in dirs:
        (dest / d).mkdir(parents=True, exist_ok=True)
        print(f"建立 {dest / d}/")
    print(f"完成！編譯：cd {dest} && latextk xelatex main.tex")


def main() -> None:
    if len(sys.argv) > 1 and sys.argv[1] == "new":
        cmd_new(sys.argv[2:])
        return

    if not docker_available():
        sys.exit("錯誤: 無法連接 Docker daemon。請確認 Docker 已啟動且您有執行權限。")

    image = select_image()
    sys.stdout.flush()

    cmd = [
        "docker", "run", "--rm",
        "-e", "XDG_CACHE_HOME=/tmp/.cache",
        "-v", f"{Path.cwd()}:/data",
        "-v", f"{SCRIPT_DIR / 'entrypoint.sh'}:/entrypoint.sh",
        "-v", f"{SCRIPT_DIR / 'template' / 'pandoc'}:/template:ro",
        "-u", f"{os.getuid()}:{os.getgid()}",
        image,
        *sys.argv[1:],
    ]
    # 以 docker 取代目前行程，讓 exit code 與 Ctrl-C 直接傳遞
    os.execvp("docker", cmd)


if __name__ == "__main__":
    main()
