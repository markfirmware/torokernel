#!/bin/sh
#
# CloudIt.sh <name>
#
# This script compiles the freepascal application in <name>
# within the Toro Kernel. This results in a disk image named 
# <name>.img. Then, this image is used to run a instance of 
# the app in a VM in QEMU. The script checks if the file <name>.qemu 
# exists. In that case, it uses the content of the file as parameters
# for qemu. The script also checks if the scripts <name>.pre and <name>.post
# exists. In that case, it executes those scripts as pre and post compilation.  
#
# Copyright (c) 2003-2016 Matias Vara <matiasevara@gmail.com>
# All Rights Reserved
#
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
qemu-system-x86_64 -m 512 -smp 2 -drive format=raw,file=./tests/ToroHello.img -serial file:debug -device isa-debug-exit,iobase=0xf4,iosize=0x04
cat debug
testhola=$(cat debug)

if [[ "$testhola" == *Hello*  ]]; then
    exit 0
else
    exit 1
fi

