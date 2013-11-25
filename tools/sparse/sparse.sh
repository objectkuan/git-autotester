#!/bin/bash

test_path=`pwd`
if [ -r 'g++' ]
then
	echo "[build_spare] ccache symbolic link exist..."
else
	ln -s /usr/bin/ccache gcc
	ln -s /usr/bin/ccache g++
	ln -s /usr/bin/ccache arm-linux-gcc
	ln -s /usr/bin/ccache arm-linux-g++
fi
export PATH="${test_path}:$PATH"
echo "[build_spare] build kernel using ccache..."

make defconfig
make -j `cat /proc/cpuinfo | grep processor |wc -l` C=1 2>&1
make mrproper
