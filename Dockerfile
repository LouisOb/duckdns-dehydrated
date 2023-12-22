FROM alpine:latest

LABEL maintainer='github.com/LouisOb'

ARG WORK_PATH="/letsencrypt"
ARG DATA_PATH="/data"
ARG TZ="Europe/Berlin"

ENV WORK_PATH=${WORK_PATH}
ENV DATA_PATH=${DATA_PATH}
ENV TZ=${TZ}


RUN apk update && \
    apk add --no-cache curl tzdata bash openrc busybox-openrc openssl\
    && rm -rf \
    /var/cache/apk/* \
    /.cache

#RUN rc-service crond start && rc-update add crond

ENV CURRENT_VERSION=0.7.1

RUN curl -s -o /usr/bin/dehydrated "https://raw.githubusercontent.com/lukas2511/dehydrated/v${CURRENT_VERSION}/dehydrated" && \
    chmod +x /usr/bin/dehydrated

RUN mkdir -p ${WORK_PATH}
RUN mkdir -p data
RUN mkdir -p /var/www/dehydrated

COPY ./hook.sh ${WORK_PATH}/hook.sh

RUN chmod +x ${WORK_PATH}/hook.sh

COPY ./request_cert.sh /request_cert.sh

RUN chmod +x /request_cert.sh

COPY ./entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]


