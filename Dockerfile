FROM ubuntu:16.04
LABEL author="carlini.lorenzo@protonmail.com"
ENV OSPL_SOURCE=/root/opensplice
ENV GSOAP_MAJ_VER=2.8
ENV GSOAP_MIN_VER=135
ENV PYTHON_MAJ_VER=3.7
ENV PYTHON_MIN_VER=17
ARG BRANCH=master

COPY ./source/opensplice-$BRANCH.zip /tmp
# git clone https://github.com/PrismTech/opensplice.git -b $BRANCH $OSPL_SOURCE
COPY ./source/gsoap_$GSOAP_MAJ_VER.$GSOAP_MIN_VER.zip /tmp/
# wget https://downloads.sourceforge.net/project/gsoap2/gsoap_2.8.135.zip -O /tmp/gsoap_$GSOAP_MAJ_VER.$GSOAP_MIN_VER.zip \
COPY ./source/Python-$PYTHON_MAJ_VER.$PYTHON_MIN_VER.tgz /tmp/
# wget https://www.python.org/ftp/python/3.7.17/Python-3.7.17.tgz

# Get required packages
RUN apt-get update \
    && apt-get install -y gcc g++ make gawk bison flex perl git wget libssl-dev unzip autotools-dev autoconf libffi-dev zlib1g-dev libssl-dev

# Build Python from source
RUN cd /tmp/ \
&& tar xzf Python-$PYTHON_MAJ_VER.$PYTHON_MIN_VER.tgz \
&& cd Python-$PYTHON_MAJ_VER.$PYTHON_MIN_VER \
&& ./configure   \
&& make -j "$(nproc)" \
&& make install \
&& rm /tmp/Python-$PYTHON_MAJ_VER.$PYTHON_MIN_VER.tgz 

#Install Cython
RUN pip3 install --upgrade pip \
    && pip3 install wheel  \
    && pip3 install cython==0.29  \
    && pip3 install setuptools 
# ==0.27  
 
# Unzip and build gsoap
RUN unzip /tmp/gsoap_$GSOAP_MAJ_VER.$GSOAP_MIN_VER.zip -d /opt \
    && rm /tmp/gsoap_$GSOAP_MAJ_VER.$GSOAP_MIN_VER.zip \
    && cd /opt/gsoap-$GSOAP_MAJ_VER \
    && ./configure --prefix=$PWD/usr \
    && make && make install

ENV GSOAPHOME=/opt/gsoap-$GSOAP_MAJ_VER/usr
ENV PATH=$PATH:/opt/gsoap-$GSOAP_MAJ_VER/usr/bin
ENV SPLICE_TARGET=x86_64.linux-release
ENV SPLICE_REAL_TARGET=x86_64.linux-release
ENV SPLICE_HOST=x86_64.linux-release

# Unzip and build opensplice
RUN unzip /tmp/opensplice-$BRANCH.zip -d tmp/opensplice-$BRANCH \
    && mkdir -p $OSPL_SOURCE \
    && mv /tmp/opensplice-$BRANCH/opensplice-$BRANCH/* $OSPL_SOURCE/ \
    && cd $OSPL_SOURCE \
    && ln -s /opt/gsoap-$GSOAP_MAJ_VER/gsoap/stdsoap2.c /opt/gsoap-$GSOAP_MAJ_VER/usr/include/ \
    && /bin/bash -c "source configure $SPLICE_TARGET && make clean && make && make install"

VOLUME ["/root/opensplice"]