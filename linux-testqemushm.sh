#!/bin/bash

# run local tool if in path, otherwise call docker image
function xdocker-bash {
    if [ "$(which $1)" != "" ]
    then
        eval $*
    else
        local DOCKER_IMAGE=markfirmware/torokernel-bash:fpctest-1500623771948
        local COMMAND="docker run --rm -i -v $(pwd):/workdir --entrypoint /bin/bash $DOCKER_IMAGE -c \"$*\""
        log $COMMAND
        eval $COMMAND
    fi
}
function docker-bash {
        local DOCKER_IMAGE=markfirmware/torokernel-bash:fpctest-1500623771948
        local COMMAND="docker run --rm -i -v $(pwd):/workdir --entrypoint /bin/bash $DOCKER_IMAGE -c \"$*\""
        log $COMMAND
        eval $COMMAND
}

function torofpc {
    header torofpc $*
    local FPC="fpc -l- -v0ewn -B -Furtl -Furtl/drivers $*"
    log $FPC
    docker-bash $FPC |& tee -a $LOG
}

function log {
    echo $* >> $LOG
}

function header {
    log
    log $LONGDASHES
    log $SHORTDASHES $*
    log $LONGDASHES
}

SHORTDASHES=----------------
LONGDASHES="$SHORTDASHES$SHORTDASHES"
LONGDASHES="$LONGDASHES$LONGDASHES"

SCRIPT=linux-testqemushm.sh
LOG=artifacts/build.log
mkdir -p artifacts
log $(date)
header script: $SCRIPT
cat $SCRIPT >> $LOG
log

#for f in rtl/*.pas rtl/drivers/*.pas
#do
#   torofpc -TWin64 $f
#done

docker-bash "nasm -o markfirmware/head64.o -f elf64 markfirmware/head64.s"
docker-bash "fpc -B -s markfirmware/testelf.pas; cp -a link-with-multiboot.res link.res; ./ppas.sh"


#torofpc markfirmware/toroqemushm.pas
#torofpc build.pas
#docker-bash fpc -i

#/c/Program\ Files/qemu/qemu-system-x86_64 -m 512M -smp 2 -drive format=raw,file=toroqemushm.img
