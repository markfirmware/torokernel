#!/bin/bash

# run local tool if in path, otherwise call docker image
function docker-bash {
    if [ "$(which $1)" == "" ]
    then
        eval $*
    else
        local DOCKER_IMAGE=markfirmware/torokernel-bash:fpctest-1500618241106
        local COMMAND="docker run --rm -i -v $(pwd):/workdir --entrypoint /bin/bash $DOCKER_IMAGE -c \"$*\""
        log $COMMAND
        eval $COMMAND
    fi
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

#docker-bash "fpc -B -s markfirmware/testelf.pas; cp -a link-with-multiboot.res link.res; ./ppas.sh"

docker-bash nasm -o head32.o -f elf head32.s

#torofpc markfirmware/toroqemushm.pas
#torofpc build.pas
#docker-bash fpc -i

#/c/Program\ Files/qemu/qemu-system-x86_64 -m 512M -smp 2 -drive format=raw,file=toroqemushm.img
