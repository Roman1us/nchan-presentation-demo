FROM nginx:latest AS builder

# Our NCHAN version
ENV NCHAN_VERSION 1.2.7

# For latest build deps, see https://github.com/nginxinc/docker-nginx/blob/master/mainline/alpine/Dockerfile
RUN apt update && apt install -y build-essential wget libpcre3-dev zlib1g-dev

# Download sources
RUN wget "http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" -O nginx.tar.gz && \
  wget "https://github.com/slact/nchan/archive/v${NCHAN_VERSION}.tar.gz" -O nchan.tar.gz

# Reuse same cli arguments as the nginx:alpine image used to build
RUN CONFARGS=$(nginx -V 2>&1 | sed -n -e 's/^.*arguments: //p') \
  tar -zxC /usr/src -f nginx.tar.gz && \
  tar -xzvf "nchan.tar.gz" && \
  NCHANDIR="$(pwd)/nchan-${NCHAN_VERSION}" && \
  cd /usr/src/nginx-$NGINX_VERSION && \
  ./configure --with-compat $CONFARGS --add-dynamic-module=$NCHANDIR && \
  make && \
  make install

FROM nginx:latest

COPY --from=builder /usr/local/nginx/modules/ngx_nchan_module.so /usr/local/nginx/modules/ngx_nchan_module.so

RUN sed -i '1s/^/load_module \/usr\/local\/nginx\/modules\/ngx_nchan_module.so;\n/' /etc/nginx/nginx.conf
