#!/bin/bash

OUT="env.txt"

uname -s -o -m > $OUT
gcc --version|head -1 >> $OUT
arm-eabi-gcc --version|head -1 >>$OUT
qemu-system-x86_64 --version|head -1 >>$OUT
emulator-arm -version|head -1 >> $OUT
