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

#echo "kernel.pid_max=3000000" >> /etc/sysctl.conf
#sysctl -p

#IMPORTANT: Require install #gcc-mingw-w64-x86-64 g++-mingw-w64-x86-64

export HOST=x86_64-w64-mingw32
apt-get update
apt-get install -y gcc-mingw-w64 g++-mingw-w64  pkg-config autoconf automake autotools-dev autopoint curl wget libtool git gcc g++ gettext make quilt unzip screen libxslt-dev xsltproc docbook-xsl libcppunit-dev curl binutils build-essential bzip2 cpp dh-autoreconf dpkg-dev
apt-get install -y autoconf autopoint automake gettext libtool pkg-config libcppunit-dev 
apt-get upgrade -y ca-certificates
#### 定义函数以获取最新版 ####
curl_opts=(curl --connect-timeout 15 --retry 3
    --retry-delay 5 --silent --location --insecure --fail)

clean_html_index() {
    local url="$1"
    local filter="${2:-(?<=href=\")[^\"]+\.(tar\.(gz|bz2|xz)|7z)}"
    "${curl_opts[@]}" -l "$url" | grep -ioP "$filter" | sort -uV
	}

clean_html_index_sqlite() {
    local url="$1"
    local filter="${2:-(\d+\/sqlite-autoconf-\d+\.tar\.gz)}"
    "${curl_opts[@]}" -l "$url" | grep -ioP "$filter" | sort -uV | tail -1
}

get_last_version() {
    local filelist="$1"
    local filter="$2"
    local version="$3"
    local ret
    ret="$(echo "$filelist" | grep -E "$filter" | sort -V | tail -1)"
    [[ -n "$version" ]] && ret="$(echo "$ret" | grep -oP "$version")"
    echo "$ret"
}

get_openssl_last_version() {
    local filelist="$1"
    local filter="$2"
    local version="$3"
    local ret
    ret="$(echo "$filelist" | grep -E "$filter" | sort -V -r | tail -1)"
    [[ -n "$version" ]] && ret="$(echo "$ret" | grep -oP "$version")"
    echo "$ret"
}
########################

##### 获取最新版本	######

#libssh2
libssh2_ver="$(clean_html_index https://libssh2.org/download/)" &&
libssh2_ver="$(get_last_version "$libssh2_ver" libssh2 "1\.\d+\.\d")"
libssh2_ver="${libssh2_ver:-1.8.0}"
libssh2_url="https://libssh2.org/download/libssh2-${libssh2_ver}.tar.gz"

#expat
expat_ver="$(clean_html_index https://sourceforge.net/projects/expat/files/expat/ 'expat/[0-9]+\.[0-9]+\.[0-9]+')"
expat_ver="$(get_last_version "${expat_ver}" expat '2\.\d+\.\d+')"
expat_ver="${expat_ver:-2.2.5}"
expat_url="https://downloads.sourceforge.net/project/expat/expat/${expat_ver}/expat-${expat_ver}.tar.bz2"

#sqlite3
sqlite_ver=$(clean_html_index_sqlite "https://www.sqlite.org/download.html")
[[ ! "$sqlite_ver" ]] && sqlite_ver="2018/sqlite-autoconf-3220000.tar.gz"
sqlite_url="https://www.sqlite.org/${sqlite_ver}"

#c-ares
[[ ! "$cares_ver" ]] && cares_ver="$(clean_html_index https://c-ares.haxx.se/)" &&
cares_ver="$(get_last_version "$cares_ver" c-ares "1\.\d+\.\d")"
cares_ver="${cares_ver:-1.13.0}"
cares_url="https://c-ares.haxx.se/download/c-ares-${cares_ver}.tar.gz"

#zlib
zlib_ver="$(clean_html_index https://sourceforge.net/projects/libpng/files/zlib/ 'zlib/[0-9]+\.[0-9]+\.[0-9]+')"
zlib_ver="$(get_last_version "${zlib_ver}" zlib '1\.\d+\.\d+')"
zlib_ver="${zlib_ver:-1.2.11}"
zlib_url="https://downloads.sourceforge.net/project/libpng/zlib/${zlib_ver}/zlib-${zlib_ver}.tar.gz"

#openssl LTS版
openssl_ver="$(clean_html_index https://www.openssl.org/source/ 'openssl-[0-9]+\.[0-9]+\.[0-9]+[a-z]+')"
#openssl_ver="$(clean_html_index https://www.openssl.org/source/ )" #获取所有版本
openssl_ver="$(get_openssl_last_version "${openssl_ver}" openssl '1\.\d+\.\d+[a-z]+')"
openssl_url="https://www.openssl.org/source/openssl-${openssl_ver}.tar.gz"

#libunwind（不接受rc版本,Windows上不需要）
#libunwind_ver="$(clean_html_index http://download.savannah.gnu.org/releases/libunwind/ 'libunwind-[0-9]+\.[0-9]+(\.[0-9])*[^\-\w]')"
#libunwind_ver="$(get_last_version "${libunwind_ver}" libunwind '1\.\d+\.\d+')"
#libunwind_url="https://github.com/libunwind/libunwind/releases/download/v$libunwind_ver/libunwind-$libunwind_ver.tar.gz"

#tcmalloc
gperftools_ver="$(clean_html_index https://github.com/gperftools/gperftools/tags)"
gperftools_ver="$(get_last_version "${gperftools_ver}" gperftools '2\.\d+\.\d+')"
gperftools_url="https://github.com/gperftools/gperftools/releases/download/gperftools-$gperftools_ver/gperftools-$gperftools_ver.tar.gz"

#aria2 但是实际上并未用到，后文用的git获取源码
aria2_ver="$(clean_html_index https://github.com/aria2/aria2/tags)"
aria2_ver="$(get_last_version "${aria2_ver}" aria2 '1\.\d+\.\d+')"
aria2_url="https://github.com/aria2/aria2/releases/download/release-$aria2_ver/aria2-$aria2_ver.tar.gz"

##################################3

#CHECK TOOL FOR DOWNLOAD
DOWNLOADER="wget -c -t 5" #出错则重试五次
## DEPENDENCES ##
ZLIB=$zlib_url

OPENSSL=$openssl_url

EXPAT=$expat_url

SQLITE3=$sqlite_url

C_ARES=$cares_url

SSH2=$libssh2_url

#LIBUNWIND=$libunwind_url

TCMALLOC=$gperftools_url

ARIA2=$aria2_url #但是实际上并未用到，后文用的git获取源码


## CONFIG ##
BUILD_DIRECTORY=/tmp/
HOST=x86_64-w64-mingw32
PREFIX=/usr/x86_64-w64-mingw32

## Capture Shell directory , To patch aria2
script_path=$(dirname $(readlink -f $0))

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
  #Tcmalloc use windows-specific api to capture backtraces. LIBUNWIND is not used on windows.
  #cd ..
  #$DOWNLOADER $LIBUNWIND -O libunwind.tar.gz
  #mkdir ./libunwind
  #tar -xzf libunwind.tar.gz -C ./libunwind --strip-components 1
  #cd ./libunwind
  #PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig/ LD_LIBRARY_PATH=$PREFIX/lib/ CC="$C_COMPILER" CXX="$CXX_COMPILER" ./configure --target=$HOST --enable-static #
  #./configure  --enable-static  #--target=$HOST
  #--enable-shared
  #./configure --prefix=$PREFIX --enable-static --disable-shared
  #./configure --target=$HOST --enable-static --enable-shared
  #make && make install
#  
  #TCMALLOC
  cd ..
  $DOWNLOADER $TCMALLOC -O tcmalloc.tar.gz
  mkdir ./tcmalloc
  tar -xzf tcmalloc.tar.gz -C ./tcmalloc --strip-components 1
  cd ./tcmalloc
  CC=$HOST-gcc CXX=$HOST-g++ AR=$HOST-ar RANLIB=$HOST-ranlib ./configure --prefix=$PREFIX --host=$HOST --enable-static --enable-frame-pointers
  #--enable-shared 
  #--disable-cpu-profiler --disable-heap-profiler --disable-heap-checker --disable-debugalloc --enable-minimal #--enable-frame-pointers #Not necessary after the installation of libunwind
  #--enable-static --disable-shared  #Not necessary
  make && make install
#  
#
 #cleaning
  cd ..
  ldconfig
  rm -rf c-ares*
  rm -rf sqlite*
  rm -rf zlib*
  rm -rf expat*
  rm -rf openssl*
  rm -rf libssh2*
  rm -rf libunwind*
  rm -rf tcmalloc*
#
 echo "dependencies installation finished!"
 
 #Aria2 Build
  sleep 1
  # $DOWNLOADER $ARIA2 -O aria2.tar.gz 使用wget下载aria2
  #mkdir ./aria2
  #tar -xzf aria2.tar.gz -C ./aria2 --strip-components 1
  #cd aria2
  
  git config --global user.email "i@urhue.com"
  git clone https://github.com/aria2/aria2 --depth=1 --config http.sslVerify=false
  cd ./aria2

# Bump up version number to 1.33.1
  wget https://github.com/aria2/aria2/commit/b9d74ca88bb8d8c53ccbfc7e95e05f9e2a155455.patch
  git am b9d74ca88bb8d8c53ccbfc7e95e05f9e2a155455.patch
    
  pushd $script_path/../../Patch
  git am ./aria2-*.patch
  popd
  
  #screen -S aria2
  autoreconf -fi
  
HOST=x86_64-w64-mingw32
PREFIX=/usr/x86_64-w64-mingw32

./configure \
    --host=$HOST \
    --prefix=$PREFIX \
	--disable-nls \
    --without-included-gettext \
	--without-libxml2 \
    --without-libgmp \
	--without-gnutls \
    --without-wintls \
    --without-libgcrypt \
    --without-libnettle \
    --with-libcares \
    --with-openssl \
    --with-sqlite3 \
    --with-libexpat \
    --with-libz \
    --with-libssh2 \
    --with-cppunit-prefix=$PREFIX \
	--with-tcmalloc \
    --with-ca-bundle='/etc/ssl/certs/ca-certificates.crt' \
    --enable-static \
    ARIA2_STATIC=yes \
    CPPFLAGS="-I$PREFIX/include" \
    LDFLAGS="-L$PREFIX/lib" \
    PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig"

make && $HOST-strip ./src/aria2c.exe
echo "Aria2 Static Build Finished!" 
