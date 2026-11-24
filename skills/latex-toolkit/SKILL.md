---
name: latex-toolkit
description: Compile LaTeX (.tex) to PDF with XeLaTeX/LuaLaTeX, or convert Markdown (.md) to PDF with Pandoc, inside a Docker container that ships full TeX Live and Noto CJK fonts (Chinese/Japanese/Korean work out of the box). Use when the user asks to build, compile, or render a .tex or .md file to PDF, wants a formal-looking report from Markdown (named template "formal"), wants to start a new LaTeX homework or assignment from a template (`new homework`), or mentions latex-toolkit.
---

# latex-toolkit

A Python wrapper that runs a Docker image containing TeX Live, Pandoc, and Noto CJK fonts. All arguments go to the container's `entrypoint.sh`.

## Locating the command

The recommended install is a `latextk` command on `PATH` (a symlink to `latex-toolkit.py`). Shell aliases aren't loaded in non-interactive shells, so don't rely on one. Pick the first option that works:

1. **`latextk` is on `PATH`** (`command -v latextk` succeeds): use it directly.
   ```bash
   LT=latextk
   TOOLKIT_DIR="$(dirname "$(realpath "$(command -v latextk)")")"
   ```
2. **`$LATEX_TOOLKIT_DIR` is set**: `TOOLKIT_DIR="$LATEX_TOOLKIT_DIR"`.
3. **Otherwise, use this skill's own location.** The skill lives at `<repo>/skills/latex-toolkit/`, possibly reached through a symlink. Resolve the symlink first, then go up two levels:
   ```bash
   TOOLKIT_DIR="$(cd "$(realpath "<this skill's base directory>")/../.." && pwd)"
   ```

For options 2 and 3, set `LT="$TOOLKIT_DIR/latex-toolkit.py"` and confirm the file exists. If no option works, ask the user where the latex-toolkit repo is (https://github.com/soraimahiro/latex-toolkit).

`TOOLKIT_DIR` (the repo root) is still needed for building the image and for reading template docs.

Below, `$LT` stands for the command found above.

## Rule that matters most: the working directory

Only the **current working directory** is mounted into the container (as `/data`). So:

- `cd` into the directory that contains the source file (or a parent of it) before running.
- Pass input/output paths **relative** to that directory.
- Files outside the cwd (images, `\input` files, bibliographies, custom headers) are invisible to the container. If the document references `../something`, `cd` higher up instead.
- Output files are written with the caller's uid/gid, inside the cwd.

## Prerequisites

- Docker daemon running (`docker info` succeeds).
- One of these images present locally (checked in this order): `latex-toolkit:main`, `pandoc-docker:main`, `ghcr.io/minstrike520/pandoc-docker:main`.
  - Build: `docker build -t latex-toolkit:main "$TOOLKIT_DIR"`
  - Or pull: `docker pull ghcr.io/minstrike520/pandoc-docker:main`
- To force a specific image: set `LATEX_TOOLKIT_IMAGE=<image>`.

Don't build or pull images without asking the user first; the image is several GB.

## Subcommands

### xelatex / lualatex: compile a .tex file

```bash
cd path/to/doc
"$LT" xelatex main.tex                    # -> main.pdf
"$LT" xelatex main.tex -o build/out.pdf   # moves the PDF there (creates the dir)
"$LT" lualatex main.tex -o out.pdf
```

- Uses `latexmk` (`-pdfxe` / `-pdflua`) with `-interaction=nonstopmode`, so cross-references and multiple passes are handled.
- Other `-flags` are passed through to latexmk.
- latexmk leaves auxiliary files (`.aux`, `.log`, `.fls`, `.fdb_latexmk`, `.xdv`) next to the source.
- CJK: XeLaTeX → `\documentclass{ctexart}` or `\usepackage{xeCJK}` + `\setCJKmainfont{Noto Serif CJK TC}`; LuaLaTeX → `\usepackage{luatexja-fontspec}` + `\setmainjfont{Noto Sans CJK TC}`.

### pandoc: convert Markdown to PDF

```bash
"$LT" pandoc doc.md                                   # -> doc.pdf
"$LT" pandoc doc.md -o report.pdf
"$LT" pandoc doc.md --template formal -o report.pdf   # named template
"$LT" pandoc doc.md -t formal -V font=times           # set template variables with -V
"$LT" pandoc --list-templates                         # list available template names
"$LT" pandoc doc.md --no-default-header -H my.tex     # replace the default CJK header
```

Behavior:
- Without `-o`, output is `<input>.pdf`.
- Without a template: uses `--pdf-engine=xelatex -V geometry=margin=1.5cm` and a default header that loads `xeCJK` with Noto Serif CJK TC, so Chinese works.
- With `--template`/`-t`/`--defaults`/`-d`, the default header and default engine/geometry are **not** added; the template controls them.
- If the .md is in a subdirectory, `--resource-path=.:<md dir>` is added automatically so relative image paths work.
- Any other option is passed straight to pandoc.

### Named templates

`--template <name>` or `-d <name>` resolves a name (when it isn't an existing file) by searching, in order:
`./template/<name>/`, `./templates/<name>/` (in the cwd), then the toolkit's built-in `template/pandoc/<name>/` (mounted in the container as `/template/<name>/`).
In each directory, `template.yaml` or `<name>.yaml` becomes `--defaults=...`; otherwise `template.latex` or `<name>.latex` becomes `--template=...`.

Built-in template **`formal`** (formal reports, specs, papers). Full variable list: `$TOOLKIT_DIR/template/pandoc/formal/README.md`. Read it before setting variables. Commonly used ones:
- Document info (YAML front matter or `-V`): `title`, `subtitle`, `author`, `date`, `abstract`
- `font`: `serif` (default), `sans`, `times`; `monofont`; `fontsize` (e.g. `12pt`); `papersize`; `geometry`
- `toc: true` for a table of contents
- Precedence: `-V` > Markdown front matter > `template.yaml` defaults.
- `template/pandoc/formal/template.yaml` (copied from `template.example.yaml`, git-ignored) wires in the Lua filters and defaults. If it's missing, only `template.latex` is used, so grid tables and `{align=...}` images won't work. Check for that file when the output looks off.

### new: start a LaTeX project from a template

Runs on the host (no Docker). Copies `$TOOLKIT_DIR/template/latex/<name>/` (except its `README.md`) into a directory.

```bash
"$LT" new --list                 # list LaTeX templates
"$LT" new homework hw3           # create hw3/ (default dir: cwd)
"$LT" new homework hw3 --force   # overwrite existing files
cd hw3 && "$LT" xelatex main.tex
```

- It refuses to overwrite and lists the conflicts unless `--force` is given. Don't pass `--force` without asking the user.
- Built-in **`homework`**: `homework.cls` + `main.tex` + `figure/` + `code/`. Set info with `\course{}`, `\hwnum{}`, `\studentname{}`, `\studentid{}`, then `\hwtitle`, `\problem{title}` per question, and `enumerate` for `(1)(2)` sub-items. The `showcaption` class option shows figure captions (hidden by default). Details: `$TOOLKIT_DIR/template/latex/homework/README.md`.
- These are LaTeX project templates, separate from the Pandoc templates used by `pandoc --template`.

## Troubleshooting

| Symptom | Cause / fix |
|---|---|
| `無法連接 Docker daemon` | Docker isn't running. Ask the user to start Docker Desktop. |
| `找不到映像檔 ...` | No image. Ask the user before building or pulling (see Prerequisites). |
| `編譯失敗！` (xelatex/lualatex) | Read `<name>.log` in the cwd and look for lines starting with `!`. |
| `File ... not found` / missing image | The file is outside the cwd mount, or the path isn't relative to the cwd. |
| Missing CJK glyphs / tofu | The document doesn't load a CJK package or font (see the CJK notes above). |
| `錯誤: 未知的指令` | The first argument must be `xelatex`, `lualatex`, `pandoc`, or `new`. |

The exit code is the container's exit code, so non-zero means failure.
