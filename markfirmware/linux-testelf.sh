#!/bin/bash

function torodocker {
    if [ "$CIRCLECI" == "true" ]
    then
        log $*
        eval $* |& tee -a $LOG
    else
        local DOCKER_IMAGE=markfirmware/torodocker:torodocker-1500629424965
        local COMMAND="docker run --rm -i -v $(pwd):/workdir -p 1234:1234 --entrypoint /bin/bash $DOCKER_IMAGE -c \"$*\""
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

LOG=artifacts/build.log
mkdir -p artifacts
rm -f $LOG

log $(date)

showfile testelfprogram.pas
showfile head64.s

header building testelfprogram.pas
torodocker "nasm -o head64.o -f elf64 head64.s"
torodocker "fpc -B -s testelfprogram.pas && sed -i '/prt0/ i head64.o' link.res && ./ppas.sh"
cp -a testelfprogram artifacts

header running qemu
log the following command is not run during the cloud build:
log torodocker qemu-system-x86_64 -kernel testelfprogram -display none -s

echo
echo see $LOG
