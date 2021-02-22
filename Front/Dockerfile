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

FROM scratch

COPY --from=base /dist/frontBinary /

EXPOSE 9191

CMD ["/frontBinary"]
