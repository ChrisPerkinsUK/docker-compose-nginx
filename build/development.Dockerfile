################################################
#######  Use Multistage buld to reduce   #######
#######  image size and attack surface   #######
################################################

################################################
########  Stage 1 of The Nginx Build   #########
############  The 'builder' image  #############
################################################
FROM alpine:3.7 AS builder

LABEL maintainer="chrisperkinsuk@gmail.com"

## NGINX ENV VARS
ENV NGINX_SRC_DIR=/usr/local/src
ENV NGINX_PATH=/usr/bin/nginx
ENV NGINX_MODULES_DIR=/usr/local/nginx/modules
ENV NGINX_CONFIG_FILE=/etc/nginx/nginx.conf
ENV NGINX_PID_FILE=/var/run/nginx.pid
ENV NGINX_ERROR_LOG=/var/log/nginx/error.log
ENV NGINX_ACCESS_LOG=/var/log/nginx/access.log

## Install packages needed by Nginx
##
## build-base - contains the packages to compile,
## build and install Nginx including a C compiler
RUN apk update && apk add --no-cache \
      build-base \
      pcre-dev \
      pcre-dev \
      libressl-dev \
      zlib \
      zlib-dev && \
      rm -rf /var/cache/apk/*

## Set-up the file system for Nginx
##
## Create a logs directory
## Create a PID file for Nginx
## Create an Error Log file
## Create an Access log file
RUN mkdir /var/log/nginx && \
    touch $NGINX_PID_FILE $(date +%s) && \
    touch $NGINX_ERROR_LOG $(date +%s) && \
    touch $NGINX_ACCESS_LOG $(date +%s)

## Copy and unzip the Nginx source
## files to the image
ADD nginx-1.15.7.tar.gz $NGINX_SRC_DIR

## Set the working Directory to the
## Nginx source directory
WORKDIR $NGINX_SRC_DIR/nginx-1.15.7

## Configure the Nginx Source code
## in preparation for installation
RUN ./configure \
      --conf-path=$NGINX_CONFIG_FILE \
      --error-log-path=$NGINX_ERROR_LOG \
      --http-log-path=$NGINX_ACCESS_LOG \
      --pid-path=$NGINX_PID_FILE \
      --with-http_ssl_module \
      --with-pcre \
      --sbin-path=$NGINX_PATH

## Compile the Configured Sources Files
## and install them to the OS image
RUN make && \
      make install

## Create a conf.d directory for holding
## virtual-host (Server) configuration files
RUN mkdir /etc/nginx/conf.d

## Copy in a default configuration file
## for Nginx to the OS image
COPY nginx.conf /etc/nginx/nginx.conf

## Copy in a default virtual-host (Server)
## file for Nginx to the OS image
COPY default.conf /etc/nginx/conf.d/default.conf

################################################
#######  Use Multistage buld to reduce   #######
#######  image size and attack surface   #######
################################################

################################################
########  Stage 2 of The Nginx Build   #########
################################################
FROM alpine:3.7

## Add the www-data user
RUN addgroup -g 1000 -S www-data \
    && adduser -u 1000 -D -S -G www-data www-data

## Install packages needed by Nginx
RUN apk update && apk add --no-cache \
      curl \
      pcre-dev \
      pcre-dev \
      libressl-dev \
      zlib \
      zlib-dev && \
      rm -rf /var/cache/apk/*

## Set-up the file system for Nginx
##
## Create a logs directory
## Create static html directory
## Create a PID file for Nginx
## Create an Error Log file
## Create an Access log file
RUN mkdir /var/log/nginx/ && \
    mkdir -p /var/www/html/ && \
    touch $NGINX_PID_FILE $(date +%s) && \
    touch $NGINX_ERROR_LOG $(date +%s) && \
    touch $NGINX_ACCESS_LOG $(date +%s)

## Copy the functional Nginx System from
## the 'builder' image to the final image
COPY --from=builder /etc/nginx /etc/nginx
COPY --from=builder /usr/local/nginx /usr/local/nginx
COPY --from=builder /usr/bin/nginx /usr/bin/nginx

## Start Nginx when a container is run
CMD ["nginx", "-g", "daemon off;"]