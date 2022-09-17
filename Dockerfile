# This file is intended to be used apart from the containing source code tree.

FROM python:3-alpine

# Version of Radicale (e.g. v3)
ARG VERSION=master
# Persistent storage for data
VOLUME /var/lib/radicale
# TCP port of Radicale
EXPOSE 5232
# Run Radicale
CMD ["radicale", "--hosts", "0.0.0.0:5232"]

COPY . /app

WORKDIR /app

RUN apk add --no-cache ca-certificates openssl openldap-dev \
    && apk add --no-cache --virtual .build-deps gcc libffi-dev musl-dev \
    && pip install --no-cache-dir python-ldap \
    && pip install --no-cache-dir -e  . \
    && apk del .build-deps
