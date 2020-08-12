ARG NGINX_VERSION=1.16.1
ARG NGINX_RTMP_VERSION=1.2.1
ARG FFMPEG_VERSION=4.2.2
# FORKED FROM alfg/nginx-rtmp

##############################
# Build the NGINX-build image.
FROM alpine:3.12 as build-nginx
ARG NGINX_VERSION
ARG NGINX_RTMP_VERSION

# Build dependencies.
RUN apk add --update \
    build-base \
    ca-certificates \
    curl \
    gcc \
    libc-dev \
    libgcc \
    linux-headers \
    make \
    musl-dev \
    openssl \
    openssl-dev \
    pcre \
    pcre-dev \
    pkgconf \
    pkgconfig \
    zlib-dev

# Get nginx source.
RUN cd /tmp && \
    wget https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && \
    tar zxf nginx-${NGINX_VERSION}.tar.gz && \
    rm nginx-${NGINX_VERSION}.tar.gz

# Get nginx-rtmp module.
RUN cd /tmp && \
    wget https://github.com/arut/nginx-rtmp-module/archive/v${NGINX_RTMP_VERSION}.tar.gz && \
    tar zxf v${NGINX_RTMP_VERSION}.tar.gz && rm v${NGINX_RTMP_VERSION}.tar.gz

# Compile nginx with nginx-rtmp module.
RUN cd /tmp/nginx-${NGINX_VERSION} && \
    ./configure \
    --prefix=/usr/local/nginx \
    --add-module=/tmp/nginx-rtmp-module-${NGINX_RTMP_VERSION} \
    --conf-path=/etc/nginx/nginx.conf \
    --with-threads \
    --with-file-aio \
    --with-http_ssl_module \
    --with-debug \
    --with-cc-opt="-Wimplicit-fallthrough=0" && \
    cd /tmp/nginx-${NGINX_VERSION} && make && make install

##########################
# Build the release image.
FROM alpine:3.12
LABEL MAINTAINER Samuel Bubienko <sam@spoleczne.it>

# set keys env
ENV YOUTUBE_KEY="" FACEBOOK_KEY=""

RUN apk add --update \
    ca-certificates \
    gettext \
    openssl \
    pcre \
    stunnel \
    openrc


COPY --from=build-nginx /usr/local/nginx /usr/local/nginx
COPY --from=build-nginx /etc/nginx /etc/nginx


# Add NGINX path, config and static files.
ENV PATH "${PATH}:/usr/local/nginx/sbin"
COPY nginx.conf /etc/nginx/nginx.conf.template
# COPY stunnel4 /etc/default/stunnel
COPY stunnel.conf /etc/stunnel/stunnel.conf
RUN mkdir /var/log/stunnel && \
    touch /var/log/stunnel/stunnel.log &&\
    chown -R stunnel:stunnel /var/log/stunnel/stunnel.log &&\
    mkdir /var/run/stunnel &&\
    chown stunnel:stunnel /var/run/stunnel


EXPOSE 1935

CMD envsubst < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf &&\
    stunnel &&\
    nginx -g 'daemon off;'