#!/bin/bash

function callfpc {
    header callfpc $*
    local FPC="fpc -l- -v0ewn -B -Fu../rtl -Fu../rtl/drivers $*"
    log $FPC
    eval $FPC |& tee -a $LOG
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

LONGDASHES=-
LONGDASHES="$LONGDASHES$LONGDASHES"
LONGDASHES="$LONGDASHES$LONGDASHES"
LONGDASHES="$LONGDASHES$LONGDASHES"
LONGDASHES="$LONGDASHES$LONGDASHES"
SHORTDASHES=$LONGDASHES
LONGDASHES="$LONGDASHES$LONGDASHES"
LONGDASHES="$LONGDASHES$LONGDASHES"


SCRIPT=linux-testqemushm.sh
LOG=artifacts/build.log
mkdir artifacts
log $(date)
header script: $SCRIPT
cat $SCRIPT >> $LOG
log

cd rtl
for f in *.pas drivers/*.pas
do
    callfpc -TWin64 ../$f
done

#cd markfirmware
#callfpc build.pas
#callfpc -TWin64 toroqemushm.pas

#/c/Program\ Files/qemu/qemu-system-x86_64 -m 512M -smp 2 -drive format=raw,file=toroqemushm.img
