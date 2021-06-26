FROM alpine as builder

RUN apk add zola --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/

COPY blog /blog

WORKDIR blog

RUN zola build --base-url ""

FROM ghcr.io/jamesguthrie/httpserve:main

COPY --from=builder /blog/public /public

CMD ["--address", "0.0.0.0", "/public"]
