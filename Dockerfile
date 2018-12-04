FROM alpine:3.7 AS build

## OpenSSL ENV VARS
ENV OPENSSL_SRC_DIR=/var/openssl
ENV OPENSSL_DIR=/usr/local
ENV OPENSSL_LIB_DIR=/usr/local/openssl
ENV OPENSSL_INCLUDE_DIR=/usr/local/include/openssl
ENV OPENSSL_SYSTEM_BIN=/usr/bin/openssl
ENV OPENSSL_LOCAL_BIN=/usr/local/bin/openssl
ENV OPENSSL_PKG_CONF_FILE=/usr/local/lib/pkgconfig/openssl.pc

## NGINX ENV VARS
ENV NGINX_SRC_DIR=/var/nginx
ENV NGINX_PATH=/usr/local/nginx/sbin/nginx
ENV NGINX_MODULES_DIR=/usr/local/nginx/modules
ENV NGINX_CONFIG_DIR=/etc/ngjnx
ENV NGINX_PID_FILE=/var/run/nginx.pid
ENV NGINX_ERROR_LOG=/var/log/nginx/error.log
ENV NGINX_ACCESS_LOG=/var/log/nginx/access.log

RUN apk update && apk add --no-cache \
         build-base \
         perl \
         pcre-dev \
         zlib-dev

ADD openssl-1.0.2q.tar.gz $OPENSSL_SRC_DIR

WORKDIR $OPENSSL_SRC_DIR/openssl-1.0.2q

RUN ./config \
          --prefix=/usr/local \
          --openssldir=/usr/local/openssl

RUN make \
         && make test \
         && make install \

ADD nginx-1.15.7.tar.gz $NGINX_SRC_DIR

WORKDIR $NGINX_SRC_DIR/nginx-1.15.7

RUN ./configure \
          --sbin-path=$NGINX_PATH \
          --modules-path=$NGINX_MODULES_DIR \
          --conf-path=$NGINX_CONFIG_DIR \
          --pid-path=$NGINX_PID_FILE \
          --error-log-path=$NGINX_ERROR_LOG \
          --http-log-path=$NGINX_ACCESS_LOG \
          --with-http_ssl_module \
          --with-pcre \
          --with-openssl=$OPENSSL_LIB_DIR

RUN make \
         && make test \
         && make install \

FROM alpine:3.7

COPY --from=build $OPENSSL_LIB_DIR $OPENSSL_LIB_DIR
COPY --from=build $OPENSSL_INCLUDE_DIR $OPENSSL_INCLUDE_DIR
COPY --from=build $OPENSSL_SYSTEM_BIN $OPENSSL_SYSTEM_BIN
COPY --from=build $OPENSSL_LOCAL_BIN $OPENSSL_LOCAL_BIN
COPY --from=build $OPENSSL_PKG_CONF_FILE $OPENSSL_PKG_CONF_FILE


