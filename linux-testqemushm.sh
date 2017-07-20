#!/bin/bash

function docker-bash {
    eval $*
}

function xdocker-bash {
    if [ "$(which $1)" != "" ]
    then
        eval $*
    else
        local DOCKER_IMAGE=markfirmware/lazarus:markfirmware-x64-1500447372285
        local COMMAND="docker run --rm -i -v $(pwd):/workdir --entrypoint /bin/bash $DOCKER_IMAGE -c \"$*\""
        echo $COMMAND
        eval $COMMAND
    fi
}

function callfpc {
    local PROJECT=markfirmware
    local FPC="fpc -l- -v0ewn -B -Fu../rtl -Fu../rtl/drivers $*"
    (docker-bash "cd $PROJECT; $FPC") |& tee -a $LOG
}

function log {
    echo $* > $LOG
}

set -x

LOG=artifacts/build.log
mkdir artifacts
log $(date)
log
cat linux-testqemushm.sh > $LOG
log

log $(pwd)
log $(ls -ltR)

#callfpc build.pas
#callfpc -TWin64 toroqemushm.pas

#/c/Program\ Files/qemu/qemu-system-x86_64 -m 512M -smp 2 -drive format=raw,file=toroqemushm.img
