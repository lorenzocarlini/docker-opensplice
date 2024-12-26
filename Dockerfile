FROM ubuntu:16.04
LABEL author="carlini.lorenzo@protonmail.com"
ENV OSPL_SOURCE=/tmp/opensplice
ENV GSOAP_MAJ_VER=2.8
ENV GSOAP_MIN_VER=135
ENV PYTHON_MAJ_VER=3.9
ENV PYTHON_MIN_VER=6
ENV SPLICE_TARGET=x86_64.linux-release
ENV SPLICE_REAL_TARGET=x86_64.linux-release
ENV SPLICE_HOST=x86_64.linux-release
ARG BRANCH=master

# Install dependencies for Git, cloning and building
RUN apt-get update \
    && apt-get install -y gcc g++ make gawk bison flex perl git wget libssl-dev unzip autotools-dev autoconf libffi-dev zlib1g-dev libssl-dev openjdk-8-jdk git

# Clone the repository containing the .deb files
RUN git clone https://github.com/lorenzocarlini/ubuntu-16.04-backports.git /tmp/ubuntu-16.04-backports

# Install Python .deb from the backports repo
COPY ./source/opensplice-$BRANCH.zip /tmp

RUN dpkg -i /tmp/ubuntu-16.04-backports/python3/$PYTHON_MAJ_VER.$PYTHON_MIN_VER/python$PYTHON_MAJ_VER.$PYTHON_MIN_VER_amd64.deb
RUN dpkg -i /tmp/ubuntu-16.04-backports/gsoap/$GSOAP_MAJ_VER.$GSOAP_MIN_VER/gsoap$GSOAP_MAJ_VER.$GSOAP_MIN_VER_amd64.deb

# Install Cythonls
RUN pip3 install --upgrade pip \
    && pip3 install wheel  \
    # Python 3.9+ specific, --build-option is deprecated and needs to be invoked through --config-settings
    && pip3 install cython==0.29.37 --config-settings="--build-option=--no-cython-compile"\
    && pip3 install setuptools 
 
# Unzip and build opensplice
RUN unzip /tmp/opensplice-$BRANCH.zip -d tmp/opensplice-$BRANCH \
    && mkdir -p $OSPL_SOURCE \
    && mv /tmp/opensplice-$BRANCH/opensplice-$BRANCH/* $OSPL_SOURCE/ 

WORKDIR $OSPL_SOURCE 
RUN ./configure x86_64.linux-release 
RUN chmod +x envs-x86_64.linux-release.sh
RUN echo "\n make \n cd install \n make" >> envs-x86_64.linux-release.sh
RUN ./envs-x86_64.linux-release.sh

RUN mv $OSPL_SOURCE/install/HDE /opt/HDE
RUN apt-get clean

ENV OSPL_HOME=/opt/HDE/x86_64.linux
ENV PATH=$OSPL_HOME/bin:$PATH
ENV OSPL_URI=file://$OSPL_HOME/etc/config/ospl.xml
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$OSPL_HOME/lib
ENV CPATH=$OSPL_HOME/include:$OSPL_HOME/include/sys:${CPATH}
