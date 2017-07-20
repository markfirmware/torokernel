#!/bin/bash

function docker-bash {
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

function fpc {
    local PROJECT=markfirmware
    local FPC="fpc -l- -B -Fu../rtl -Fu../rtl/drivers $*"
    docker-bash "cd $PROJECT; $FPC" | tee -a artifacts/build.log
}

pwd
ls -lt

#mkdir artifacts
#touch artifacts/build.log
#fpc build.pas
#fpc -TWin64 toroqemushm.pas

#/c/Program\ Files/qemu/qemu-system-x86_64 -m 512M -smp 2 -drive format=raw,file=toroqemushm.img
