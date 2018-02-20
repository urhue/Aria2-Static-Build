#!/bin/bash

# In this configuration, the following dependent libraries are compiled:
#
# * zlib
# * c-ares
# * expat
# * sqlite3
# * openSSL
# * libssh2
# * tcmalloc

#Attention！
#If the parameters with-tcmalloc as well as ARIA2_STATIC = yes are selected when compiling , the glibc >=2.25 is necessary

#Maybe You Need Debian Testing.
#And the compiling passed When I use Debian Testing

#Debian Testing
#apt update && apt install checkinstall
#sed -i 's/stretch/testing/g' /etc/apt/sources.list
#apt update && apt upgrade -y


#IMPORTANT: Require install #gcc-mingw-w64-x86-64 g++-mingw-w64-x86-64
export HOST=x86_64-w64-mingw32
apt-get update
apt-get install -y gcc-mingw-w64 g++-mingw-w64  pkg-config autoconf automake autotools-dev autopoint libtool git gcc g++ gettext make quilt unzip screen libxslt-dev xsltproc docbook-xsl libcppunit-dev curl binutils build-essential bzip2 cpp dh-autoreconf dpkg-dev
#apt-get -t sid install libc6 libc6-dev libc6-dbg
#CHECK TOOL FOR DOWNLOAD
DOWNLOADER="wget -c"


## DEPENDENCES ##
ZLIB=http://sourceforge.net/projects/libpng/files/zlib/1.2.11/zlib-1.2.11.tar.gz

OPENSSL=https://www.openssl.org/source/openssl-1.0.2n.tar.gz

EXPAT=https://sourceforge.net/projects/expat/files/expat/2.2.5/expat-2.2.5.tar.bz2

SQLITE3=http://www.sqlite.org/2018/sqlite-autoconf-3220000.tar.gz

C_ARES=https://c-ares.haxx.se/download/c-ares-1.14.0.tar.gz

SSH2=https://www.libssh2.org/download/libssh2-1.8.0.tar.gz

LIBUNWIND=https://github.com/libunwind/libunwind/releases/download/v1.2.1/libunwind-1.2.1.tar.gz

TCMALLOC=https://github.com/gperftools/gperftools/releases/download/gperftools-2.6.3/gperftools-2.6.3.tar.gz


## CONFIG ##
BUILD_DIRECTORY=/tmp/
HOST=x86_64-w64-mingw32
PREFIX=/usr/x86_64-w64-mingw32

## BUILD ##
cd $BUILD_DIRECTORY
#
 # zlib build
  $DOWNLOADER $ZLIB -O zlib.tar.gz
  mkdir ./zlib
  tar -xzf zlib.tar.gz -C ./zlib --strip-components 1
  cd ./zlib
  CC=$HOST-gcc CXX=$HOST-g++ AR=$HOST-ar RANLIB=$HOST-ranlib ./configure --prefix=$PREFIX --static
  make
  make install
#
 # expat build
  cd ..
  $DOWNLOADER $EXPAT -O expat.tar.bz2
  mkdir ./expat
  tar -jxf expat.tar.bz2 -C ./expat --strip-components 1
  cd ./expat
  CC=$HOST-gcc CXX=$HOST-g++ AR=$HOST-ar RANLIB=$HOST-ranlib ./configure --prefix=$PREFIX --host=$HOST --enable-static --enable-shared
  make
  make install
#
 # c-ares build
  cd ..
  $DOWNLOADER $C_ARES -O c-ares.tar.gz
  mkdir ./c-ares
  tar -xzf c-ares.tar.gz -C ./c-ares --strip-components 1
  cd ./c-ares
  CC=$HOST-gcc CXX=$HOST-g++ AR=$HOST-ar RANLIB=$HOST-ranlib ./configure --prefix=$PREFIX --host=$HOST --enable-static --disable-shared
  make
  make install
#
 # Openssl build
  cd ..
  $DOWNLOADER $OPENSSL -O openssl.tar.gz
  mkdir ./openssl
  tar -xzf openssl.tar.gz -C ./openssl --strip-components 1
  cd ./openssl
  ./Configure mingw64 --cross-compile-prefix=$HOST- --prefix=$PREFIX shared
  make
  make install
#
 # sqlite3
  cd ..
  $DOWNLOADER $SQLITE3 -O sqlite3.tar.gz
  mkdir ./sqlite3
  tar -xzf sqlite3.tar.gz -C ./sqlite3 --strip-components 1
  cd ./sqlite3
  CC=$HOST-gcc CXX=$HOST-g++ AR=$HOST-ar RANLIB=$HOST-ranlib ./configure --prefix=$PREFIX --host=$HOST --enable-static --enable-shared
  make
  make install
#
 # libssh2
  cd ..
  $DOWNLOADER $SSH2 -O libssh2.tar.gz
  mkdir ./libssh2
  tar -xzf libssh2.tar.gz -C ./libssh2 --strip-components 1
  cd ./libssh2
  rm -rf $PREFIX/lib/pkgconfig/libssh2.pc
  CC=$HOST-gcc CXX=$HOST-g++ AR=$HOST-ar RANLIB=$HOST-ranlib ./configure --prefix=$PREFIX --host=$HOST --enable-static --disable-shared
  make
  make install
#  
  #LIBUNWIND for tcmalloc
  cd ..
  $DOWNLOADER $LIBUNWIND -O libunwind.tar.gz
  mkdir ./libunwind
  tar -xzf libunwind.tar.gz -C ./libunwind --strip-components 1
  cd ./libunwind
  #PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig/ LD_LIBRARY_PATH=$PREFIX/lib/ CC="$C_COMPILER" CXX="$CXX_COMPILER" ./configure --prefix=$PREFIX --enable-static --disable-shared
  ./configure 
  make && make install
#  
  #TCMALLOC
  cd ..
  $DOWNLOADER $TCMALLOC -O tcmalloc.tar.gz
  mkdir ./tcmalloc
  tar -xzf tcmalloc.tar.gz -C ./tcmalloc --strip-components 1
  cd ./tcmalloc
  CC=$HOST-gcc CXX=$HOST-g++ AR=$HOST-ar RANLIB=$HOST-ranlib ./configure --prefix=$PREFIX --host=$HOST 
  #--disable-cpu-profiler --disable-heap-profiler --disable-heap-checker --disable-debugalloc --enable-minimal #--enable-frame-pointers #Not necessary after the installation of libunwind
  #--enable-static --disable-shared  #Not necessary
  make && make install
#  
#
 #cleaning
  cd ..
  rm -rf c-ares*
  rm -rf sqlite*
  rm -rf zlib*
  rm -rf expat*
  rm -rf openssl*
  rm -rf libssh2*
  rm -rf tcmalloc*
#
 echo "finished!"
