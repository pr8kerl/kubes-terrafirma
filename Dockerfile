From golang:1.10-alpine as cfssl

ENV USER root

# Install Build Dependencies
RUN apk add --no-cache --virtual .build-deps \
        build-base \
        gcc \
        git \
        libtool \
        sqlite-dev

RUN go get github.com/cloudflare/cfssl/...
WORKDIR /go/src/github.com/cloudflare/cfssl
RUN go install ./cmd/...

FROM lachlanevenson/k8s-kubectl:v1.10.1 as kubectl
FROM lachlanevenson/k8s-helm:v2.9.0 as helm
FROM hairyhenderson/gomplate:v2.4.0 as gomplate

FROM alpine:3.6
RUN apk add -U curl make bash openssl
COPY --from=cfssl /go/bin/cfssl /usr/bin/
COPY --from=cfssl /go/bin/cfssljson /usr/bin/
COPY --from=kubectl /usr/local/bin/kubectl /usr/bin/
COPY --from=helm /usr/local/bin/helm /usr/bin/
COPY --from=gomplate /gomplate /usr/bin/

WORKDIR /app

CMD ["/bin/bash"]
