#!/bin/sh

NGINX_VERSION=${NGINX_VERSION-1.14.2}
PCRE_VERSION=${PCRE_VERSION-8.37}
HEADERS_MORE_VERSION=${HEADERS_MORE_VERSION-0.261}
ZLIB_VERSION=${ZLIB_VERSION-1.2.11}

nginx_tarball_url=http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
pcre_tarball_url=http://iweb.dl.sourceforge.net/project/pcre/pcre/${PCRE_VERSION}/pcre-${PCRE_VERSION}.tar.bz2
headers_more_nginx_module_url=https://github.com/openresty/headers-more-nginx-module/archive/v${HEADERS_MORE_VERSION}.tar.gz
zlib_url=http://zlib.net/zlib-${ZLIB_VERSION}.tar.gz

temp_dir=$(mktemp -d /tmp/nginx.XXXXXXXXXX)

echo "Serving files from /tmp on $PORT"
cd /tmp
python -m SimpleHTTPServer $PORT &

cd $temp_dir
echo "Temp dir: $temp_dir"

echo "Downloading $nginx_tarball_url"
curl -L $nginx_tarball_url | tar xzv

echo "Downloading $pcre_tarball_url"
(cd nginx-${NGINX_VERSION} && curl -L $pcre_tarball_url | tar xvj )

echo "Downloading $headers_more_nginx_module_url"
(cd nginx-${NGINX_VERSION} && curl -L $headers_more_nginx_module_url | tar xvz )

echo "Downloading $zlib_url"
(cd nginx-${NGINX_VERSION} && curl -L $zlib_url | tar xvz )

(
  cd nginx-${NGINX_VERSION}
  ./configure \
    --with-pcre=pcre-${PCRE_VERSION} \
    --with-zlib=zlib-${ZLIB_VERSION} \
    --with-http_gzip_static_module \
    --with-http_realip_module \
    --with-http_ssl_module \
    --prefix=/app/wallarm \
    --add-module=${temp_dir}/nginx-${NGINX_VERSION}/headers-more-nginx-module-${HEADERS_MORE_VERSION} \
    --sbin-path=/app/wallarm/sbin/nginx \
    --conf-path=/app/wallarm/etc/nginx/nginx.conf \
    --http-client-body-temp-path=/tmp/nginx/client_temp \
    --http-proxy-temp-path=/tmp/nginx/proxy_temp \
    --http-fastcgi-temp-path=/tmp/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/tmp/nginx/uwsgi_temp \
    --http-scgi-temp-path=/tmp/nginx/scgi_temp \
    --group=dyno \
    --with-compat \
    --with-file-aio \
    --with-threads \
    --with-http_dav_module \
    --with-http_realip_module \
    --with-http_ssl_module \
    --with-http_v2_module
    #--error-log-path=/var/log/nginx/error.log \
    #--http-log-path=/var/log/nginx/access.log \
    #--pid-path=/var/run/nginx.pid \
    #--lock-path=/var/run/nginx.lock \
  make install
)
