FROM node:6.10.2

WORKDIR /workdir

RUN apt-get update && apt-get install -y libgtk2.0-dev

RUN node -v && npm install -g elm

RUN DEB=fpc_3.0.2-170225_amd64.deb && \
    wget -q -O $DEB \
    'https://downloads.sourceforge.net/project/lazarus/Lazarus%20Linux%20amd64%20DEB/Lazarus%201.6.4/fpc_3.0.2-170225_amd64.deb?r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Flazarus%2Ffiles%2FLazarus%2520Linux%2520amd64%2520DEB%2FLazarus%25201.6.4%2F&ts=1500438953&use_mirror=newcontinuum' && \
    dpkg -i $DEB && \
    rm $DEB

COPY markfirmware/docker/fpctest.pas .
RUN fpc -i && \
    fpc fpctest.pas

RUN DEB=fpc-src_3.0.2-170225_amd64.deb && \
    wget -q -O $DEB \
    'https://downloads.sourceforge.net/project/lazarus/Lazarus%20Linux%20amd64%20DEB/Lazarus%201.6.4/fpc-src_3.0.2-170225_amd64.deb?r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Flazarus%2Ffiles%2FLazarus%2520Linux%2520amd64%2520DEB%2FLazarus%25201.6.4%2F&ts=1500437637&use_mirror=newcontinuum' && \
    dpkg -i $DEB && \
    rm $DEB && \
\
    DEB=lazarus-project_1.6.4-0_amd64.deb && \
    wget -q -O $DEB \
    'https://downloads.sourceforge.net/project/lazarus/Lazarus%20Linux%20amd64%20DEB/Lazarus%201.6.4/lazarus-project_1.6.4-0_amd64.deb?r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Flazarus%2Ffiles%2FLazarus%2520Linux%2520amd64%2520DEB%2FLazarus%25201.6.4%2F&ts=1500439026&use_mirror=newcontinuum' && \
    dpkg -i $DEB && \
    rm $DEB

#RUN apt-get update && apt-get install -y binutils gcc git && \
#
#ENV PATH=/root/ultibo/core/fpc/bin:$PATH
#
#RUN apt-get update && apt-get install -y qemu-system-x86_64 python-pip imagemagick tftp atftp httpie && \
#    pip install parse
#
#WORKDIR /test
#COPY docker/test-with-examples.sh .
#RUN ./test-with-examples.sh
