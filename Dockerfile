FROM cfssl/cfssl:1.3.0 as cfssl

FROM lachlanevenson/k8s-kubectl:v1.9.2 as kubectl
FROM hairyhenderson/gomplate:v2.2.0 as gomplate

FROM alpine:3.6
RUN apk add -U curl make bash openssl
COPY --from=cfssl /go/bin/cfssl /usr/bin/
COPY --from=kubectl /usr/local/bin/kubectl /usr/bin/
COPY --from=gomplate /gomplate /usr/bin/

WORKDIR /app

CMD ["/bin/bash"]
