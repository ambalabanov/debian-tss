FROM debian:testing
LABEL Maintainer="Andrey Balabanov <a.balabanov@icloud.com>"
LABEL version="1.0.0"
LABEL description="Base image for running TPM2 Software Stack (TSS) with IBM tpm simulator"

ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8
ENV LANGUAGE C.UTF-8

RUN apt update && \
    apt install -y \
	autoconf-archive \
	libcmocka0 \
  	libcmocka-dev \
  	procps \
  	iproute2 \
  	build-essential \
  	git \
  	pkg-config \
  	gcc \
  	libtool \
  	automake \
  	libssl-dev \
  	uthash-dev \
  	autoconf \
  	doxygen \
  	libjson-c-dev \
  	libini-config-dev \
  	libcurl4-openssl-dev \
  	uuid-dev \
  	libltdl-dev \
  	libusb-1.0-0-dev \
	libglib2.0-dev \
 	sqlite3 \
	libsqlite3-dev \
	libyaml-dev \
	libtpms-dev \
	pandoc \
    	python3 \
    	python3-pip \
	python3-bcrypt \
	python3-cryptography \
	python3-yaml \
	python3-pyasn1 \
	python3-pyasn1-modules \
	gnutls-bin \
	tpm2-tools \
	tpm2-openssl \
	libtpm2-pkcs11-1 \
	libtpm2-pkcs11-tools \
	python3-tpm2-pkcs11-tools \
	udev \
	dbus

RUN mkdir -p /tpm2/{ibmtpm,test}

WORKDIR /tpm2
RUN git clone --branch=3.2.x https://github.com/tpm2-software/tpm2-tss.git && \
    git clone https://github.com/tpm2-software/tpm2-abrmd.git

WORKDIR /tpm2/tpm2-tss
RUN ./bootstrap && \
    ./configure --with-udevrulesprefix && \
    make -j4 && \
    make install

WORKDIR /tpm2/tpm2-abrmd
RUN ./bootstrap && \
    ./configure --with-dbuspolicydir=/etc/dbus-1/system.d && \
    make -j4 && \
    make install

WORKDIR /tpm2/ibmtpm
ADD "https://downloads.sourceforge.net/project/ibmswtpm2/ibmtpm1682.tar.gz" ./
RUN tar -xf ibmtpm1682.tar.gz
WORKDIR /tpm2/ibmtpm/src
RUN make -j4
RUN cp tpm_server /usr/local/bin/

WORKDIR /
RUN ldconfig
ADD ./test /tpm2/test/
COPY entrypoint.sh /usr/local/bin/
CMD ["entrypoint.sh"]

