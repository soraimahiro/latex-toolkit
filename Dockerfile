FROM texlive/texlive:latest

# 安裝 pandoc, fonts-noto-cjk 及 fontconfig 以支援 Markdown 轉換與中文字型
RUN apt update && apt install -y \
    pandoc \
    fonts-noto-cjk \
    fontconfig \
    && rm -rf /var/lib/apt/lists/* \
    && fc-cache -fv

WORKDIR /data

COPY header.tex /default_header.tex
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
