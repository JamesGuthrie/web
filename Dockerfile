FROM alpine AS builder

RUN apk add zola

COPY blog /blog

WORKDIR /blog

RUN zola build --base-url=""

FROM ghcr.io/jamesguthrie/httpserve:0.3.2

COPY --from=builder /blog/public /public

CMD ["--address", "0.0.0.0", "--redirect-http", "--max-cache-size-mib", "128", "/public"]
