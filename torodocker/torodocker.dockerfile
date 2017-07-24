FROM debian:jessie
 
WORKDIR /workdir

RUN echo deb http://ftp.debian.org/debian jessie-backports main \
        >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get -y dist-upgrade && \
    apt-get -y install \
        binutils gcc gdb git nasm python-pip wget && \
    apt-get -y -t jessie-backports install qemu-system-x86 && \
    pip install pyelftools && \
    git clone http://github.com/dpocock/elfpatch && \
    chmod u+x elfpatch/elfpatch.py

RUN wget -q -O fpc.deb 'http://downloads.sourceforge.net/project/lazarus/Lazarus%20Linux%20amd64%20DEB/Lazarus%201.6.2/fpc_3.0.0-151205_amd64.deb?r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Flazarus%2Ffiles%2FLazarus%2520Linux%2520amd64%2520DEB%2FLazarus%25201.6.2%2F&ts=1483204950&use_mirror=superb-sea2' && \
    dpkg -i fpc.deb && \
    rm fpc.deb && \
    fpc -i

COPY torodocker/fpctest.pas .
RUN  fpc fpctest.pas && \
     qemu-system-x86_64 --version
