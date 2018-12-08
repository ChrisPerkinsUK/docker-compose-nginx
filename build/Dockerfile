FROM alpine:3.7 AS builder

## NGINX ENV VARS
ENV NGINX_SRC_DIR=/usr/local/src/
ENV NGINX_PATH=/usr/bin/nginx
ENV NGINX_MODULES_DIR=/usr/local/nginx/modules
ENV NGINX_CONFIG_FILE=/etc/nginx/nginx.conf
ENV NGINX_PID_FILE=/var/run/nginx.pid
ENV NGINX_ERROR_LOG=/var/log/nginx/error.log
ENV NGINX_ACCESS_LOG=/var/log/nginx/access.log

RUN apk update && apk add --no-cache \
      build-base \
      pcre-dev \
      pcre-dev \
      libressl-dev \
      zlib \
      zlib-dev && \
      rm -rf /var/cache/apk/*

RUN mkdir /var/log/nginx && \
    touch $NGINX_PID_FILE $(date +%s) && \
    touch $NGINX_ERROR_LOG $(date +%s) && \
    touch $NGINX_ACCESS_LOG $(date +%s)

ADD nginx-1.15.7.tar.gz $NGINX_SRC_DIR

WORKDIR $NGINX_SRC_DIR/nginx-1.15.7

RUN ./configure \
      --conf-path=$NGINX_CONFIG_FILE \
      --error-log-path=$NGINX_ERROR_LOG \
      --http-log-path=$NGINX_ACCESS_LOG \
      --pid-path=$NGINX_PID_FILE \
      --with-http_ssl_module \
      --with-pcre \
      --sbin-path=$NGINX_PATH

RUN make && \
      make install

RUN mkdir /etc/nginx/conf.d

COPY nginx.conf /etc/nginx/nginx.conf

COPY default.conf /etc/nginx/conf.d/default.conf

FROM alpine:3.7

RUN apk update && apk add --no-cache \
      pcre-dev \
      pcre-dev \
      libressl-dev \
      zlib \
      zlib-dev && \
      rm -rf /var/cache/apk/*


RUN mkdir /var/log/nginx && \
    touch $NGINX_PID_FILE $(date +%s) && \
    touch $NGINX_ERROR_LOG $(date +%s) && \
    touch $NGINX_ACCESS_LOG $(date +%s)

COPY --from=builder /etc/nginx /etc/nginx
COPY --from=builder /usr/local/nginx /usr/local/nginx
COPY --from=builder /usr/bin/nginx /usr/bin/nginx

CMD ["nginx", "-g", "daemon off;"]