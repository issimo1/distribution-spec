# ---
# Stage 1: Install certs and build conformance binary
# ---
FROM docker.m.daocloud.io/golang:1.13.6-alpine3.11 AS builder
ARG VERSION=unknown
ARG GO_PKG=github.com/opencontainers/distribution-spec/conformance
RUN go env -w GOPROXY=https://goproxy.cn,direct
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories
RUN apk --update add git make ca-certificates && mkdir -p /go/src/${GO_PKG}
WORKDIR /go/src/${GO_PKG}
ADD . .
RUN CGO_ENABLED=0 go test -c -o /conformance.test --ldflags="-X ${GO_PKG}.Version=${VERSION}"

# ---
# Stage 2: Final image with nothing but certs & binary
# ---
FROM alpine:latest AS final
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=builder /conformance.test /conformance.test
COPY /run_oci.sh /run_oci.sh
ENTRYPOINT ["/run_oci.sh"]
