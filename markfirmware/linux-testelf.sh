#!/bin/bash

function torodocker {
    if [ "$CIRCLECI" == "true" ]
    then
        log $*
        eval $* |& tee -a $LOG
    else
        local DOCKER_IMAGE=markfirmware/torodocker:torodocker-1500629424965
        local COMMAND="docker run --rm -i -v $(pwd):/workdir --entrypoint /bin/bash $DOCKER_IMAGE -c \"$*\""
        log $COMMAND
        eval $COMMAND |& tee -a $LOG
    fi
}

function log {
    echo $* | tee -a $LOG
}

function header {
    log
    log $LONGDASHES
    log $SHORTDASHES $*
    log $LONGDASHES
}

function showfile {
    header $1
    cat $1 >> $LOG
}

SHORTDASHES=----------------
LONGDASHES="$SHORTDASHES$SHORTDASHES"
LONGDASHES="$LONGDASHES$LONGDASHES"

LOG=build.log
rm -f $LOG

log $(date)

showfile testelf.pas
showfile head64.s

header building testelf.pas
torodocker "nasm -o head64.o -f elf64 head64.s"
torodocker "fpc -B -s testelf.pas && sed -i '/prt0/ i head64.o' link.res && ./ppas.sh"

header running qemu
torodocker qemu-system-x86_64 -kernel testelf

echo
echo see $LOG
