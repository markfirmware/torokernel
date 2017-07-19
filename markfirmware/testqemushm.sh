#!/bin/bash

/c/lazarus/lazbuild --lazarusdir=/c/lazarus -B toroqemushm.lpi
/c/Program\ Files/qemu/qemu-system-x86_64 -m 512M -smp 2 -drive format=raw,file=ToroQemuShm.img
