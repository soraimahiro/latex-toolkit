FROM alpine:latest

RUN apk add --no-cache \
    pandoc \
    texlive-xetex \
    texlive-luatex \
    texlive-latexextra \
    texlive-langextra \
    font-noto-cjk \
    fontconfig && \
    mkdir -p /var/cache/fontconfig && \
    chmod 777 /var/cache/fontconfig && \
    fc-cache -fv

WORKDIR /data

COPY header.tex /default_header.tex
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
