#!/bin/bash

function docker-bash {
    if [ "$(which $1)" != "" ]
    then
        eval $*
    else
        local DOCKER_IMAGE=markfirmware/lazarus:markfirmware-x64-1500447372285
        local COMMAND="docker run --rm -i -v $(pwd):/workdir --entrypoint /bin/bash $DOCKER_IMAGE -c \"$*\""
        log $COMMAND
        eval $COMMAND
    fi
}

function callfpc {
    header callfpc $*
    local PROJECT=markfirmware
    local FPC="fpc -l- -v0ewn -B -Fu../rtl -Fu../rtl/drivers $*"
    log $FPC
    (docker-bash "cd $PROJECT; $FPC") |& tee -a $LOG
}

function log {
    echo $* >> $LOG
}

function header {
    log
    log ---------------------------------------------------------- $*
}

SCRIPT=linux-testqemushm.sh
LOG=artifacts/build.log
mkdir artifacts
log $(date)
header script: $SCRIPT
cat $SCRIPT >> $LOG
log

for f in rtl/*
do
    callfpc -TWin64 ../$f
done

#callfpc build.pas
#callfpc -TWin64 toroqemushm.pas

#/c/Program\ Files/qemu/qemu-system-x86_64 -m 512M -smp 2 -drive format=raw,file=toroqemushm.img
