#!/bin/bash

echo "===================="
echo "trinityTest"
echo "===================="

thisfile_dir="$(dirname "$0")"
test_path=`pwd`
if [ -r 'gcc' ]
then 
	echo "[trinityTest] ccache symbolic link exist..."
else
	ln -s /usr/bin/ccache gcc
	ln -s /usr/bin/ccache g++
	ln -s /usr/bin/ccache arm-linux-gcc
	ln -s /usr/bin/ccache arm-linux-g++
fi
export PATH="${test_path}:$PATH"
echo "[trinityTest] build kernel using ccache..."

img_trinity="$thisfile_dir/img/debian7.2.trinity.qcow2"
bzImage='arch/x86/boot/bzImage'

#判断是否安装qemu
if [ -x '/usr/bin/qemu-system-i386' ]
then
	echo "[trinityTest] qemu installed!"
else
	echo "[trinityTest] please install qemu!"
	exit
fi

#判断bzImage是否存在
if [ -f $bzImage ]
then
	echo "[trinityTest] bzImage   ready..."
else
	echo "[trinityTest] $bzImage not exist, making bzImage..."
	make ARCH=i386 defconfig
	make ARCH=i386 bzImage -j `cat /proc/cpuinfo |grep processor|wc -l`
	if [ -f $bzImage ]
	then
		echo "[trinityTest] bzImage ready..."
	else
		echo "[trinityTest] making bzImage failed..."
		echo "[trinityTest] exit..."
		exit
	fi
fi

echo "[trinityTest] img_trinity:$img_trinity"

#查找是否存在可用的测试镜像，没有就拷贝一个过来
if [ -f "`find ./ -name "*debian7.2.trinity.qcow2"`" ]
then
	img_used="`find ./ -name "*debian7.2.trinity.qcow2"`"
else
	img_used="`date +%y%m%d%H%M%S`.debian7.2.trinity.qcow2"
	cp $img_trinity $img_used
fi

#test
${thisfile_dir}/timer.sh ${img_used} 240 &
qemu-system-i386 -kernel $bzImage -hda $img_used -append "root=/dev/sda1 console=ttyS0,115200n8 console=tty0" -serial stdio -vnc :33

#收尾
make mrproper
