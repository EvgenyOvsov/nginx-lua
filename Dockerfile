FROM ubuntu:latest
USER 0
RUN apt-get -y update
RUN apt-get install -y gcc git wget curl make libpcre++-dev zlib1g-dev

WORKDIR /opt/
RUN git clone https://github.com/openresty/lua-nginx-module.git
RUN git clone https://github.com/vision5/ngx_devel_kit
RUN git clone https://github.com/openresty/lua-resty-core.git
RUN git clone https://github.com/openresty/lua-resty-lrucache
RUN git clone https://github.com/openresty/lua-resty-mysql.git

RUN wget https://luajit.org/download/LuaJIT-2.1.0-beta3.tar.gz && tar -xzvf LuaJIT-2.1.0-beta3.tar.gz
WORKDIR /opt/LuaJIT-2.1.0-beta3
RUN make && make install DESTDIR=/usr/src/luajit2.1.0/build

WORKDIR /opt
RUN wget 'https://nginx.org/download/nginx-1.13.6.tar.gz'
RUN tar -xzf nginx-1.13.6.tar.gz
WORKDIR /opt/nginx-1.13.6/
ENV LUAJIT_BUILD=/usr/src/luajit2.1.0/build/usr/local
ENV LUAJIT_LIB=$LUAJIT_BUILD/lib
ENV LUAJIT_INC=$LUAJIT_BUILD/include/luajit-2.1

RUN ./configure --prefix=/opt/nginx \
--with-ld-opt="-Wl,-rpath,$LUAJIT_LIB" \
--add-module=/opt/ngx_devel_kit \
--add-module=/opt/lua-nginx-module
RUN make -j2 && make install
RUN echo "alias nginx=/opt/nginx/sbin/nginx" > ~/.bashrc

