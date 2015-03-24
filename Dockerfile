FROM ubuntu:14.04

# Install Virtuoso prerequisites
RUN apt-get update \
        && apt-get install -y build-essential debhelper autotools-dev autoconf automake unzip wget net-tools git libtool flex bison gperf gawk m4 libssl-dev libreadline-dev openssl

ENV VIRTUOSO_COMMIT ebbe27b982dad9f50eba015a8c2aae9584dcdb53

# Get Virtuoso source code from GitHub and checkout specific commit
RUN git clone https://github.com/openlink/virtuoso-opensource.git \
        && cd virtuoso-opensource \
        && git checkout ${VIRTUOSO_COMMIT}

# Make and install Virtuoso (by default in /usr/local/virtuoso-opensource)
WORKDIR /virtuoso-opensource
RUN ./autogen.sh \
        && CFLAGS="-O2 -m64" && export CFLAGS && ./configure \
        && make && make install \
        && ln -s /usr/local/virtuoso-opensource/var/lib/virtuoso/ /var/lib/virtuoso
        
# Add Virtuoso bin to the PATH
ENV PATH /usr/local/virtuoso-opensource/bin/:$PATH

# Add Virtuoso config
ADD virtuoso.ini /virtuoso.ini

# Add startup script
ADD startup.sh /startup.sh

WORKDIR /var/lib/virtuoso/db
EXPOSE 8890
EXPOSE 1111

CMD ["/bin/bash", "/startup.sh"]