FROM amazonlinux:2016.09


ENV PCRE_VERSION 8.40
ENV OPENSSL_VERSION 1.0.2k
ENV APACHE_VERSION 2.4.25
ENV APR_VERSION 1.5.2
ENV APRU_VERSION 1.5.4

RUN yum -y update && yum -y install wget gcc gcc-c++ perl zlib-devel

# Download, configure and install PCRE
RUN wget -P /tmp https://ftp.pcre.org/pub/pcre/pcre-"${PCRE_VERSION}".tar.gz && \
    tar -xf /tmp/pcre-"${PCRE_VERSION}".tar.gz -C /tmp && \
    rm -f /tmp/pcre-"${PCRE_VERSION}".tar.gz
RUN cd /tmp/pcre-"${PCRE_VERSION}" && \
    ./configure --prefix=/opt/pcre/pcre-"${PCRE_VERSION}" && make && make install

# Download, configure and install OpenSSL
RUN wget -P /tmp https://www.openssl.org/source/openssl-"${OPENSSL_VERSION}".tar.gz && \
    tar -xf /tmp/openssl-"${OPENSSL_VERSION}".tar.gz -C /tmp && \
    rm -f /tmp/openssl-"${OPENSSL_VERSION}".tar.gz
RUN cd /tmp/openssl-"${OPENSSL_VERSION}" && \
    ./config --prefix=/opt/openssl/openssl-"${OPENSSL_VERSION}" shared zlib && make && make install

# Download, configure and install Apache
RUN wget -P /tmp http://www.dsgnwrld.com/am//httpd/httpd-"${APACHE_VERSION}".tar.gz && \
    tar -xf /tmp/httpd-"${APACHE_VERSION}".tar.gz -C /tmp && \
    rm -f /tmp/httpd-"${APACHE_VERSION}".tar.gz
RUN cd /tmp/httpd-"${APACHE_VERSION}" && \
    wget -P /tmp http://apache.mesi.com.ar//apr/apr-"${APR_VERSION}".tar.gz && \
    tar -xf /tmp/apr-"${APR_VERSION}".tar.gz -C ./srclib && \
    mv ./srclib/apr-"${APR_VERSION}" ./srclib/apr && \
    rm -f /tmp/apr-"${APR_VERSION}".tar.gz && \
    wget -P /tmp http://apache.mesi.com.ar//apr/apr-util-"${APRU_VERSION}".tar.gz && \
    tar -xf /tmp/apr-util-"${APRU_VERSION}".tar.gz -C ./srclib && \
    mv ./srclib/apr-util-"${APRU_VERSION}" ./srclib/apr-util && \
    rm -f /tmp/apr-util-"${APRU_VERSION}".tar.gz && \
    ./configure \
        --prefix=/opt/httpd/httpd-"${APACHE_VERSION}" \
        --sbindir=/usr/local/sbin \
        --with-ssl=/opt/openssl/openssl-"${OPENSSL_VERSION}" \
        --enable-ssl \
        --enable-ssl-staticlib-deps \
        --enable-mods-static=ssl \
        --enable-proxy \
        --with-included-apr \
        --with-pcre=/opt/pcre/pcre-"${PCRE_VERSION}" && \
    make && make install

# Clean up unnecessary artifacts
WORKDIR /opt/httpd/httpd-"${APACHE_VERSION}"/conf
RUN rm -rf /tmp/httpd-"${APACHE_VERSION}" && \
    rm -rf /tmp/openssl-"${OPENSSL_VERSION}" && \
    rm -rf /tmp/pcre-"${PCRE_VERSION}"

# Add extra configuration
RUN { echo 'ServerName localhost'; \
    echo 'LoadModule slotmem_shm_module modules/mod_slotmem_shm.so'; \
    echo 'LoadModule socache_shmcb_module modules/mod_socache_shmcb.so'; \
    } >> ./httpd.conf

# Define default command
CMD ["apachectl", "-D", "FOREGROUND"]

# Expose ports
EXPOSE 80 443
