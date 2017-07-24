FROM debian:jessie
 
WORKDIR /workdir

RUN apt-get update && \
    apt-get -y dist-upgrade && \
    apt-get -y install binutils gcc git qemu-system-x86 wget

RUN wget -q -O fpc.deb 'http://downloads.sourceforge.net/project/lazarus/Lazarus%20Linux%20amd64%20DEB/Lazarus%201.6.2/fpc_3.0.0-151205_amd64.deb?r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Flazarus%2Ffiles%2FLazarus%2520Linux%2520amd64%2520DEB%2FLazarus%25201.6.2%2F&ts=1483204950&use_mirror=superb-sea2' && \
    dpkg -i fpc.deb && \
    rm fpc.deb

COPY markfirmware/docker/fpctest.pas .
RUN fpc -i && \
    fpc fpctest.pas

RUN apt-get -y install nasm python-pip && \
    pip install pyelftools && \
    git clone http://github.com/dpocock/elfpatch
