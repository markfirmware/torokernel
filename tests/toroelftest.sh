#!/bin/bash

function torodocker {
    if [ "$CIRCLECI" == "true" ]
    then
        log $*
        eval $* |& tee -a $LOG
    else
        local DOCKER_IMAGE=markfirmware/torodocker:torodocker-1500863107533
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

LOG=$(pwd)/artifacts/build.log
mkdir -p $(pwd)/artifacts
rm -f $LOG

log $(date)

showfile toroelftest.pas

header build toroelftest.pas
pushd ..
torodocker "fpc -B -Fu./rtl -Fu./rtl/drivers tests/toroelftest.pas"
popd

echo
echo see $LOG
