FROM alpine:3.7

ENV INSTALL_DIR=/opt/nginx

RUN apk update && apk add --no-cache \


## Set the new working directory
WORKDIR $INSTALL_DIR

## Add downloaded source for nginx
## from https://nginx.org/download/nginx-1.15.7.tar.gz
ADD nginx-1.15.7.tar.gz /opt/nginx
