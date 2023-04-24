FROM debian:testing
LABEL Maintainer="Andrey Balabanov <a.balabanov@icloud.com>"
LABEL version="1.0.0"
LABEL description="Base image for running TPM2 Software Stack (TSS) with IBM tpm simulator"

ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8
ENV LANGUAGE C.UTF-8

RUN apt update && \
    apt install -y \
  	build-essential \
  	libssl-dev \
	gnutls-bin \
	tpm2-tools \
	tpm2-openssl \
	tpm2-abrmd \
	libtss2-tcti-tabrmd0 \
	libtpm2-pkcs11-1 \
	libtpm2-pkcs11-tools \
	python3-tpm2-pkcs11-tools \
	clevis-tpm2 \
	clevis-luks \
	dbus

RUN mkdir -p /tpm2/ibmtpm
WORKDIR /tpm2/ibmtpm
ADD "https://downloads.sourceforge.net/project/ibmswtpm2/ibmtpm1682.tar.gz" ./
RUN echo "651800d0b87cfad55b004fbdace4e41dce800a61 *ibmtpm1682.tar.gz" | sha1sum -c - &&\
    tar -xf ibmtpm1682.tar.gz
WORKDIR /tpm2/ibmtpm/src
RUN make -j$(nproc)
RUN cp tpm_server /usr/local/bin/
WORKDIR /
RUN rm -rf /tpm2/ibmtpm/src
RUN ldconfig
ADD ./test /tpm2/test/
COPY entrypoint.sh /usr/local/bin/
ENV TPM2TOOLS_TCTI=tabrmd
CMD ["entrypoint.sh"]
