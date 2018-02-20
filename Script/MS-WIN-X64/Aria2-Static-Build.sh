#!/bin/bash

# In this configuration, the following dependent libraries will be used:
#
# * zlib
# * c-ares
# * expat
# * sqlite3
# * openSSL
# * libssh2
# * tcmalloc
#
# After this configuration, Aria2 will be compiled as a static binary.

apt-get install -y autoconf autopoint automake gettext libtool pkg-config libcppunit-dev quilt

cd /tmp

#手动获取版本号
Aria2_Version=1.33.1

#自动获取版本号
#Aria2_Version=$(wget -qO- "https://github.com/q3aql/aria2-static-builds/tags"| grep "/q3aql/aria2-static-builds/releases/tag/"| head -n 1| awk -F "/tag/v" '{print $2}'| sed 's/\">//') && echo -e "${aria2_new_ver}"

wget -c -O aria2.tar.gz https://github.com/aria2/aria2/releases/download/release-1.33.1/aria2-$Aria2_Version.tar.gz
mkdir ./aria2
tar -xzf aria2.tar.gz -C ./aria2 --strip-components 1
cd aria2
quilt new 8192Threads
quilt add ./src/OptionHandlerFactory.cc
sed -i s"/1\, 16\,/1\, 128\,/" ./src/OptionHandlerFactory.cc  
sed -i s"/1_m\, 1_g\,/256_k\, 1_g\,/" ./src/OptionHandlerFactory.cc  
quilt refresh

#screen -S aria2
HOST=x86_64-w64-mingw32
PREFIX=/usr/x86_64-w64-mingw32



./configure \
    --host=$HOST \
    --prefix=$PREFIX \
    --with-tcmalloc \
    --without-included-gettext \
    --disable-nls \
    --with-libcares \
    --without-gnutls \
    --without-wintls \
    --with-openssl \
    --with-sqlite3 \
    --without-libxml2 \
    --with-libexpat \
    --with-libz \
    --without-libgmp \
    --with-libssh2 \
    --without-libgcrypt \
    --without-libnettle \
    --with-cppunit-prefix=$PREFIX \
    --with-ca-bundle='/etc/ssl/certs/ca-certificates.crt' \
    --enable-static \
    ARIA2_STATIC=yes \
    CPPFLAGS="-I$PREFIX/include" \
    LDFLAGS="-L$PREFIX/lib" \
    PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig"

make -j && $HOST-strip ./src/aria2c.exe
