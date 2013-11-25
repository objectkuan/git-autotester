#!/bin/bash

echo "===================="
echo "shellTest"
echo "===================="

thisfile_dir="$(dirname "$0")"
test_path=`pwd`
if [ -r 'gcc' ]
then 
	echo "[shellTest] ccache symbolic link exist..."
else
	ln -s /usr/bin/ccache gcc
	ln -s /usr/bin/ccache g++
	ln -s /usr/bin/ccache arm-linux-gcc
	ln -s /usr/bin/ccache arm-linux-g++
fi
export PATH="${test_path}:$PATH"
echo "[shellTest] build kernel using ccache..."

img_pure="${thisfile_dir}/img/debian7.2.pure.qcow2"
bzImage='arch/x86/boot/bzImage'

#判断是否安装qemu
if [ -x '/usr/bin/qemu-system-i386' ]
then
	echo "[shellTest] qemu installed!"
else
	echo "[shellTest] please install qemu!"
	exit
fi

#img_pure exist?
if [ ! -f $img_pure ]
then
	echo "[shellTest] img_pure not exist. check it..."
	exit
fi

#判断bzImage是否存在
if [ -f $bzImage ]
then
	echo "[shellTest] bzImage   ready..."
else
	echo "[shellTest] $bzImage not exist, making bzImage..."
	make ARCH=i386 defconfig
	make ARCH=i386 bzImage -j `cat /proc/cpuinfo |grep processor|wc -l`
	if [ -f $bzImage ]
	then
		echo "[shellTest] bzImage ready..."
	else
		echo "[shellTest] making bzImage failed..."
		echo "[shellTest] exit..."
		exit
	fi
fi

#当前是否有可使用的测试镜像，没有的话拷贝一个过来,保证原来的不受污染
if [ -f "`find ./ -name "*debian7.2.pure.qcow2"`" ]
then
	img_used="`find ./ -name "*debian7.2.pure.qcow2"`"
else
	img_used="`date +%y%m%d%H%M%S`.debian7.2.pure.qcow2"
	cp $img_pure $img_used
fi
#test pure img
${thisfile_dir}/timer.sh $img_used 60 &
qemu-system-i386 -kernel $bzImage -hda $img_used -append "root=/dev/sda1 console=ttyS0,115200n8 console=tty0" -serial stdio -vnc :33

#收尾
make mrproper
