FROM debian:jessie

WORKDIR /workdir

RUN apt-get update && \
    apt-get -y dist-upgrade && \
    apt-get -y install binutils gcc git wget

RUN wget -q -O fpc.deb 'http://downloads.sourceforge.net/project/lazarus/Lazarus%20Linux%20amd64%20DEB/Lazarus%201.6.2/fpc_3.0.0-151205_amd64.deb?r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Flazarus%2Ffiles%2FLazarus%2520Linux%2520amd64%2520DEB%2FLazarus%25201.6.2%2F&ts=1483204950&use_mirror=superb-sea2' && \
    dpkg -i fpc.deb && \
    rm fpc.deb

COPY markfirmware/docker/fpctest.pas .
RUN fpc -i && \
    fpc fpctest.pas

# 'https://downloads.sourceforge.net/project/lazarus/Lazarus%20Linux%20amd64%20DEB/Lazarus%201.6.4/fpc_3.0.2-170225_amd64.deb?r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Flazarus%2Ffiles%2FLazarus%2520Linux%2520amd64%2520DEB%2FLazarus%25201.6.4%2F&ts=1500438953&use_mirror=newcontinuum' && \

#RUN apt-get update && apt-get install -y binutils gcc git && \
#ENV PATH=/root/ultibo/core/fpc/bin:$PATH
#RUN apt-get update && apt-get install -y qemu-system-x86_64 python-pip imagemagick tftp atftp httpie && \
#    pip install parse
#COPY docker/test-with-examples.sh .
#RUN ./test-with-examples.sh
