#!/bin/bash

function torodocker {
    if [ "$CIRCLECI" == "true" ]
    then
        log $*
        eval $* |& tee -a $LOG
    else
        local DOCKER_IMAGE=markfirmware/torodocker
        local COMMAND="docker run --rm -i -u $(id -u):$(id -g) -v $(pwd):/workdir -p 1234:1234 --entrypoint /bin/bash $DOCKER_IMAGE -c \"$*\""
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

MULTIBOOT=toromultibootheader64
showfile $MULTIBOOT.s
showfile toroelftest.pas

header build toroelftest.pas
pushd ..
torodocker "nasm -o tests/$MULTIBOOT.o -f elf64 tests/$MULTIBOOT.s"
torodocker "fpc -l- -g -B -s -Fu./rtl -Fu./rtl/drivers tests/toroelftest.pas && sed -i '/prt0/ i tests/$MULTIBOOT.o' link.res && ./ppas.sh"
objdump -d tests/toroelftest > toroelftest.orig.disasm
sed -n '/^Disassembly/,/retq/p' toroelftest.orig.disasm >> $LOG

header patch out call to FPC_INITIALIZEUNITS
echo PASCALMAIN 554889e59090909090 >> elfpatch
torodocker /workdir/elfpatch/elfpatch.py --symbol-file elfpatch tests/toroelftest --apply
objdump -d tests/toroelftest > toroelftest.disasm
diff toroelftest.orig.disasm toroelftest.disasm >> $LOG
cp -a tests/toroelftest artifacts

header use gdb to observe counter changing
coproc torodocker \
    qemu-system-x86_64 \
    -kernel tests/toroelftest \
    -display none \
    -monitor stdio \
    -S \
    -s

torodocker gdb -q << __EOF__ \
    |& egrep -iv '^$|will be killed|not from terminal'
target remote localhost:1234
symbol-file tests/toroelftest
b 8
define cycle
  c
  printf "                                              Counter = %d\n",  counter
end
cycle
cycle
cycle
q
__EOF__
echo q >&${COPROC[1]}

popd

echo
echo see $LOG
