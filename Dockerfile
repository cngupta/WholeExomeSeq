FROM ubuntu:14.04
MAINTAINER Chirag Gupta <cxg040@uark.edu>
USER root
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --force-yes \
    curl \
    g++ \
    make \
    python \
    libboost-dev \
    libboost-thread-dev \
    libboost-system-dev \
    zlib1g-dev \
    ncurses-dev \
    unzip \
    gzip \
    bzip2 \
    libxml2-dev \
    libxslt-dev \
    python-pip \
    python-dev \
    git \
    s3cmd \
    time \
    wget \
    python-virtualenv \
    default-jre \
    default-jdk 
 


RUN adduser --disabled-password --gecos '' ubuntu && adduser ubuntu sudo && echo "ubuntu    ALL=(ALL)   NOPASSWD:ALL" >> /etc/sudoers.d/ubuntu
ENV HOME /home/ubuntu
USER ubuntu
RUN mkdir ${HOME}/bin
RUN mkdir ${HOME}/tmp  # for picard runs
WORKDIR ${HOME}/bin


#download Trimmomatic 0.38 
RUN  wget http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/Trimmomatic-0.38.zip
RUN unzip Trimmomatic-0.38.zip 


#download Samtools
RUN wget https://github.com/samtools/samtools/releases/download/1.9/samtools-1.9.tar.bz2 && tar xvjf samtools-1.9.tar.bz2 
WORKDIR ${HOME}/bin/samtools-1.9
RUN ./configure --disable-bz2 --disable-lzma 
RUN make
WORKDIR ${HOME}/bin

#download Picard
USER root
ENV VERSION "1.141"
ENV NAME "picard-tools"
ENV ZIP ${NAME}-${VERSION}.zip
ENV URL https://github.com/broadinstitute/picard/releases/download/${VERSION}/${ZIP}

RUN wget -q $URL -O ${ZIP} && \
    unzip $ZIP && \
    rm $ZIP && \
    cd ${NAME}-${VERSION} && \
    mv * /usr/local/bin && \
    cd .. && \
    bash -c 'echo -e "#!/bin/bash\njava -jar /usr/local/bin/picard.jar \$@" > /usr/local/bin/picard' && \
    chmod +x /usr/local/bin/picard && \
    rm -rf ${NAME}-${VERSION} 

USER ubuntu

#download bwa
RUN wget https://github.com/lh3/bwa/releases/download/v0.7.17/bwa-0.7.17.tar.bz2 && tar xvjf bwa-0.7.17.tar.bz2
WORKDIR ${HOME}/bin/bwa-0.7.17
RUN make  
WORKDIR ${HOME}/bin

#download varscan2
RUN git clone https://github.com/dkoboldt/varscan.git

RUN mkdir ${HOME}/scripts
RUN mkdir ${HOME}/genome
ADD call_variants.pl ${HOME}/scripts
ADD genome ${HOME}/genome

USER root

ENV PATH ${PATH}:${HOME}/bin/:${HOME}/bin/bwa-0.7.17/:${HOME}/bin/varscan/:${HOME}/bin/samtools-1.9/:${HOME}/bin/Trimmomatic-0.38/:/usr/local/bin/	





