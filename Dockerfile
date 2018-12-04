FROM alpine:3.7 AS build

## OpenSSL ENV VARS
ENV OPENSSL_SRC_DIR=/var/openssl
ENV OPENSSL_PATH=/usr/local
ENV OPENSSL_LIB_PATH=/usr/local/openssl
ENV OPENSSL_INCLUDE_DIR=/usr/local/include/openssl
ENV OPENSSL_SYSTEM_BIN=/usr/bin/openssl
ENV OPENSSL_LOCAL_BIN=/usr/local/bin/openssl
ENV OPENSSL_PKG_CONF=/usr/local/lib/pkgconfig/openssl.pc

## NGINX ENV VARS
ENV NGINX_SRC_DIR=/var/nginx
ENV EXECUTIBLE_PATH=/usr/local/nginx/sbin/nginx
ENV MODULES_PATH=/usr/local/nginx/modules
ENV CONFIG_PATH=/etc/ngjnx
ENV PID_PATH=/var/run/nginx.pid
ENV ERROR_LOG_PATH=/var/log/nginx/error.log
ENV ACCESS_LOG_PATH=/var/log/nginx/access.log

RUN apk update && apk add --no-cache \
         build-base \
         perl \
         pcre-dev \
         zlib-dev

ADD openssl-1.0.2q.tar.gz $OPEN_SRC_DIR

WORKDIR $OPEN_SRC_DIR/openssl-1.0.2q

RUN ./config \
          --prefix=/usr/local \
          --openssldir=/usr/local/openssl

RUN make \
         && make test \
         && make install \

ADD nginx-1.15.7.tar.gz $NGINX_SRC_DIR

WORKDIR $NGINX_SRC_DIR/nginx-1.15.7

RUN ./configure \
          --sbin-path=$EXECUTIBLE_PATH \
          --modules-path=$MODULES_PATH \
          --conf-path=$CONFIG_PATH \
          --pid-path=$PID_PATH \
          --error-log-path=$ERROR_LOG_PATH \
          --http-log-path=$ACCESS_LOG_PATH \
          --with-http_ssl_module \
          --with-pcre \
          --with-openssl=$OPENSSL_LIB_PATH

RUN make \
         && make test \
         && make install \

FROM alpine:3.7

COPY --from=build $OPENSSL_LIB_PATH $OPENSSL_LIB_PATH
COPY --from=build $OPENSSL_INCLUDE_DIR $OPENSSL_INCLUDE_DIR
COPY --from=build $OPENSSL_SYSTEM_BIN $OPENSSL_SYSTEM_BIN
COPY --from=build $OPENSSL_LOCAL_BIN $OPENSSL_LOCAL_BIN
COPY --from=build $OPENSSL_PKG_CONF $OPENSSL_PKG_CONF


