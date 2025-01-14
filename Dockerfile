# This file is intended to be used apart from the containing source code tree.

FROM python:3-slim-bullseye as builder

# Version of Radicale (e.g. v3)
ARG VERSION=master

# Optional dependencies (e.g. bcrypt)
ARG DEPENDENCIES=bcrypt

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential python3-dev libldap2-dev libsasl2-dev slapd ldap-utils \
    && python -m venv /app/venv \
    && /app/venv/bin/pip install --no-cache-dir "Radicale[${DEPENDENCIES}] @ https://github.com/Kozea/Radicale/archive/${VERSION}.tar.gz"


FROM python:3-slim-bullseye

WORKDIR /app

RUN useradd radicale --home /var/lib/radicale --system --uid 1000 --disabled-password \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y ca-certificates openssl ldap-utils libldap-2.4-2 slapd \
    && rm -rf /var/lib/apt/lists/*

COPY --chown=radicale --from=builder /app/venv /app

# Persistent storage for data
VOLUME /var/lib/radicale
# TCP port of Radicale
EXPOSE 5232
# Run Radicale
ENTRYPOINT [ "/app/bin/python", "/app/bin/radicale"]
CMD ["--hosts", "0.0.0.0:5232"]

USER radicale
