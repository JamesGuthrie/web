FROM alpine as builder

RUN apk add zola

COPY blog /blog

WORKDIR blog

RUN zola build --base-url ""

FROM ghcr.io/jamesguthrie/httpserve:0.2.0

COPY --from=builder /blog/public /public

CMD ["--address", "0.0.0.0", "--redirect-http", "/public"]
