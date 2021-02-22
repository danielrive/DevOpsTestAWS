FROM golang:1.16.0-alpine3.12 AS base

ENV GO111MODULE=on \
    CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64

WORKDIR /build

COPY . .

RUN go build -o frontBinary main.go

WORKDIR /dist

RUN cp /build/frontBinary .



FROM golang:1.16.0-alpine3.12

RUN apk update \
    && apk add --no-cache jq

COPY --from=base /dist/frontBinary /usr/src/frontBinary

COPY runapp.sh /usr/src/runapp.sh

RUN chmod +x  /usr/src/runapp.sh

EXPOSE 9191

ENTRYPOINT ["sh","/usr/src/runapp.sh"]
