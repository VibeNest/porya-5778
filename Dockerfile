# VibeNest-compatible multi-stage build for Sanaei 3X-UI.
# Build directly from the repository to avoid embedding a duplicate source ZIP.

# ------------------------------------------------------------
# Stage 1: build frontend
# ------------------------------------------------------------
FROM node:24-alpine AS frontend
WORKDIR /src
COPY . ./
WORKDIR /src/frontend
RUN npm ci && npm run build

# ------------------------------------------------------------
# Stage 2: build backend and download runtime components
# ------------------------------------------------------------
FROM golang:1.27-alpine AS builder
WORKDIR /app
ARG TARGETARCH

RUN apk add --no-cache --update build-base gcc curl unzip
COPY . ./
COPY --from=frontend /src/internal/web/dist ./internal/web/dist

# ZIP archives do not reliably preserve executable bits.
RUN chmod +x DockerInit.sh DockerEntrypoint.sh x-ui.sh

ENV CGO_ENABLED=1
ENV CGO_CFLAGS="-D_LARGEFILE64_SOURCE"

RUN mkdir -p build && go build -ldflags "-w -s" -o build/x-ui main.go
RUN sh ./DockerInit.sh "$TARGETARCH"

# ------------------------------------------------------------
# Stage 3: runtime
# ------------------------------------------------------------
FROM alpine:3.22

ENV TZ=Asia/Tehran
WORKDIR /app

RUN apk add --no-cache --update \
    ca-certificates \
    tzdata \
    fail2ban \
    bash \
    curl \
    openssl

COPY --from=builder /app/build/ /app/
COPY --from=builder /app/DockerEntrypoint.sh /app/
COPY --from=builder /app/x-ui.sh /usr/bin/x-ui
COPY --from=builder /app/internal/web/translation /app/internal/web/translation

RUN rm -f /etc/fail2ban/jail.d/alpine-ssh.conf \
    && cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local \
    && sed -i "s/^\[ssh\]$/&\nenabled = false/" /etc/fail2ban/jail.local \
    && sed -i "s/^\[sshd\]$/&\nenabled = false/" /etc/fail2ban/jail.local \
    && sed -i "s/#allowipv6 = auto/allowipv6 = auto/g" /etc/fail2ban/fail2ban.conf

RUN chmod +x /app/DockerEntrypoint.sh /app/x-ui /usr/bin/x-ui

ENV XUI_IN_DOCKER="true"
ENV XUI_MAIN_FOLDER="/app"
ENV XUI_ENABLE_FAIL2BAN="false"
ENV XUI_PORT="8080"
ENV XUI_DB_TYPE=""
ENV XUI_DB_DSN=""

EXPOSE 8080
VOLUME ["/etc/x-ui"]

ENTRYPOINT ["/app/DockerEntrypoint.sh"]
CMD ["./x-ui"]
