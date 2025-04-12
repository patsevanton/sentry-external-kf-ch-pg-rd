ARG SNUBA_VERSION
FROM ${SNUBA_VERSION}

COPY ca-certs/*.crt /usr/local/share/ca-certificates/
COPY enhance-image.sh /usr/src/snuba/

USER root

RUN if [ -s /usr/src/snuba/enhance-image.sh ]; then \
    /usr/src/snuba/enhance-image.sh; \
fi

RUN if [ -s /usr/src/snuba/requirements.txt ]; then \
    echo "sentry/requirements.txt is deprecated, use sentry/enhance-image.sh - see https://develop.sentry.dev/self-hosted/#enhance-sentry-image"; \
    pip install -r /usr/src/snuba/requirements.txt; \
fi

USER snuba
