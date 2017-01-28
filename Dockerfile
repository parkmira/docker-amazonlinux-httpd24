FROM amazonlinux:2016.09

ENV PCRE_VERSION 8.40
ENV OPENSSL_VERSION 1.0.2k

RUN yum -y update && yum -y install wget gcc gcc-c++ perl

# Download, configure and install PCRE
RUN wget -P /tmp https://ftp.pcre.org/pub/pcre/pcre-"${PCRE_VERSION}".tar.gz && \
    tar -xf /tmp/pcre-"${PCRE_VERSION}".tar.gz -C /tmp && \
    rm -f /tmp/pcre-"${PCRE_VERSION}".tar.gz
RUN cd /tmp/pcre-"${PCRE_VERSION}" && \
    ./configure --prefix=/usr/local/pcre && make && make install

# Download, configure and install OpenSSL
RUN wget -P /tmp https://www.openssl.org/source/openssl-"${OPENSSL_VERSION}".tar.gz && \
    tar -xf /tmp/openssl-"${OPENSSL_VERSION}".tar.gz -C /tmp && \
    rm -f /tmp/openssl-"${OPENSSL_VERSION}".tar.gz
RUN cd /tmp/openssl-"${OPENSSL_VERSION}" && \
    ./config --prefix=/usr/local/ssl --openssldir=/usr/local/ssl && make && make install
