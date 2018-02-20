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

#Attention！
#If use --with-jemalloc as well as ARIA2_STATIC = yes , the glibc >=2.25 is necessary
apt-get install -y autoconf autopoint automake gettext libtool pkg-config libcppunit-dev quilt

cd /tmp

#手动获取版本号
Aria2_Version=1.33.1

#自动获取版本号
#Aria2_Version=$(wget -qO- "https://github.com/q3aql/aria2-static-builds/tags"| grep "/q3aql/aria2-static-builds/releases/tag/"| head -n 1| awk -F "/tag/v" '{print $2}'| sed 's/\">//') && echo -e "${aria2_new_ver}"

wget -c -O aria2.tar.gz https://github.com/aria2/aria2/releases/download/release-$Aria2_Version/aria2-$Aria2_Version.tar.gz
mkdir ./aria2
tar -xzf aria2.tar.gz -C ./aria2 --strip-components 1
cd aria2
quilt new 8192Threads
quilt add ./src/OptionHandlerFactory.cc
sed -i s"/1\, 16\,/1\, 128\,/" ./src/OptionHandlerFactory.cc  
sed -i s"/1_m\, 1_g\,/256_k\, 1_g\,/" ./src/OptionHandlerFactory.cc  
quilt refresh
#screen -S aria2

#COMPILER AND PATH
PREFIX=/usr
C_COMPILER="gcc"
CXX_COMPILER="g++"




## BUILD ##
##DEP_DIR=/opt/aria2/build_libs/ ##
##LDFLAGS="-L$DEP_DIR/lib" \ ##
#CPPFLAGS="-I$DEP_DIR/include" \ ##



PKG_CONFIG_PATH=/opt/aria2/build_libs/lib/pkgconfig/ \
LD_LIBRARY_PATH=/opt/aria2/build_libs/lib/ \
CC="$C_COMPILER" \
CXX="$CXX_COMPILER" \
./configure \
    --prefix=$PREFIX \
	--with-tcmalloc \
    --without-libxml2 \
    --without-libgcrypt \
    --without-libnettle \
    --without-gnutls \
    --without-libgmp \
	--with-openssl \
    --with-libssh2 \
    --with-sqlite3 \
	--with-libexpat\
	--with-libcares \
	--with-libz \
	--with-ca-bundle='/etc/ssl/certs/ca-certificates.crt' \
    --enable-static \
	ARIA2_STATIC=yes \
    --enable-shared=no
	
make -j && strip ./src/aria2c
