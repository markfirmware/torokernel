#!/bin/bash

function callfpc {
    header callfpc $*
    local FPC="fpc -l- -v0ewn -B -Furtl -Furtl/drivers $*"
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

for f in rtl/*.pas rtl/drivers/*.pas
do
    callfpc -TWin64 $f
done

#callfpc build.pas
#callfpc -TWin64 toroqemushm.pas

#/c/Program\ Files/qemu/qemu-system-x86_64 -m 512M -smp 2 -drive format=raw,file=toroqemushm.img
