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

ENTRYPOINT ["pandoc"]
