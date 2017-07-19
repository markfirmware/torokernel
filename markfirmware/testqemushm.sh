#!/bin/bash

exec {STDOUT}>&1 > pre-report.txt

PROGRAM=toroqemushm

function finish {
    local EXITCODE=$1
    shift
    local MESSAGE="$*"

    echo
    echo $MESSAGE
    exec >&- >&$STDOUT

    kill -9 $QEMUPID > /dev/null 2>&1

    sed 's/\x1B\[K//g' pre-report.txt | sed 's/^(qemu) .*\x1B\[D//' > test-report.txt
    rm pre-report.txt
    unix2dos test-report.txt 2> /dev/null

    echo see test-report.txt
    exit $EXITCODE
}

date

function show {
    echo $*
    eval "$*"
}

function monitor {
    echo $* >&$MONITOR
}

function drain {
    local FD=$1
    shift
    echo
    echo $* ...
    while read -t 2 line <&$FD
    do
        echo $line
    done
}

function delay {
    local SECONDS=$1
    shift
    echo $* ...
    sleep $SECONDS
}

echo
echo compiling ...
cat $PROGRAM.pas
/c/lazarus/lazbuild --lazarusdir=/c/lazarus -B toroqemushm.lpi $PROGRAM.lpi > build.log
cat build.log | egrep -i 'error:' > errors-build.txt
grep . errors-build.txt > /dev/null
if [[ $? == 0 ]]
then
    echo
    cat errors-build.txt
    echo
    finish 1 build failure
fi

echo
echo sha1 ...
sha1sum $PROGRAM.img
sha1sum $PROGRAM.lp[ir]
sha1sum $PROGRAM.pas

echo
echo qemu ...
/c/Program\ Files/qemu/qemu-system-x86_64 \
    -m 512M \
    -display none \
    -drive format=raw,file=toroqemushm.img \
    -monitor tcp::39004,server,nodelay \
    -serial  tcp::39000,server,nodelay \
    -serial  tcp::39001,server,nodelay \
    -serial  tcp::39002,server,nodelay \
    -serial  tcp::39003,server,nodelay \
    2> qemu.stderr \
    &
QEMUPID=$!
echo connecting ...
exec {MONITOR}<>/dev/tcp/localhost/39004
exec {SERIAL0}<>/dev/tcp/localhost/39000
exec {SERIAL1}<>/dev/tcp/localhost/39001
exec {SERIAL2}<>/dev/tcp/localhost/39002
exec {SERIAL3}<>/dev/tcp/localhost/39003

delay 4 running
sleep 1
monitor xp/20w 0x3f00020
monitor quit
drain $MONITOR qemu monitor
wait
echo

echo qemu.stderr ...
cat qemu.stderr
#show egrep -iv 'alsa' qemu.stderr

echo
echo tools ...
sha1sum /c/Program\ Files/qemu/qemu-system-x86_64 --version
sha1sum /c/Program\ Files/qemu/qemu-system-x86_64.exe
sha1sum /c/lazarus/fpc/3.0.2/bin/x86_64-win64/fpc.exe
sha1sum /c/lazarus/lazbuild.exe

echo
find ../rtl -type f -exec sha1sum '{}' ';'

finish 0 succeeded
