#!/bin/bash
#take care of c++ 4.7(for making llvm 3.1) by xuyongjian
if [ -d "/usr/include/x86_64-linux-gnu/c++/4.7/bits" ]
then
	sudo mkdir /usr/include/c++/4.7/x86_64-linux-gnu
	echo "已经创建/usr/include/c++/4.7/x86_64-linux-gnu"
	sudo ln -s /usr/include/x86_64-linux-gnu/c++/4.7/bits /usr/include/c++/4.7/x86_64-linux-gnu/bits
	if [ -r /usr/include/c++/4.7/x86_64-linux-gnu/bits/c++config.h ]
	then
		echo "成功创建软链接 /usr/include/c++/4.7/x86_64-linux-gnu/bits"
	else
		echo "处理c++4.7失败? this should never happens, but if you input the wrong passwd, e..."
	fi
else
	echo "c++ 4.7 not exist..."
fi
#end xuyongjian

echo "====================================="
echo "Build LLVM and Clang 3.1"
echo "====================================="

#get path of the script
pwd_dir="$(pwd)"
this_script_dir="$(dirname "$0")"
cd $this_script_dir
this_script_sdir="$(pwd)"

#download llvm and clang sources
echo "Download llvm and clang sources now..."
mkdir llvm-3.1
cd llvm-3.1
svn co http://llvm.org/svn/llvm-project/llvm/tags/RELEASE_31/final llvm
if [ $? != 0 ]; then
	echo "Download llvm failed, stop."
	exit 1
fi
cd llvm/tools/
svn co http://llvm.org/svn/llvm-project/cfe/tags/RELEASE_31/final clang
if [ $? != 0 ]; then
	echo "Download clang failed, stop."
	exit 1
fi
cd ../projects/
svn co http://llvm.org/svn/llvm-project/compiler-rt/tags/RELEASE_31/final compiler-rt
if [ $? != 0 ]; then
	echo "Download compiler-rt failed, stop."
	exit 1
fi
cd ../..
echo "Download sources successfully."

#build and install llvm
echo "Configuring llvm start..."
mkdir build
cd build
../llvm/configure --enable-optimized --enable-targets=host --enable-bindings=none --enable-shared --enable-debug-symbols
if [ $? != 0 ]; then
	echo "Configuring llvm failed, stop."
	exit 1
fi
echo "Building llvm start..."
make -j `cat /proc/cpuinfo | grep processor |wc -l`
if [ $? != 0 ]; then
	echo "Building llvm failed, stop."
	exit 1
fi
echo "Installing llvm start..."
sudo make install
if [ $? != 0 ]; then
	echo "Installing llvm failed, stop."
	exit 1
fi


#判断是否配置好llvm&clang 3.1的环境
clang_path=$(which clang)
if [ "$clang_path" != "" ]; then
    clang_version=$(clang --version | grep 3.1)
    if [ "$clang_version" != "" ]; then
        echo "Building and installing LLVM and Clang successfully."
    else
        echo "Building and installing LLVM and Clang failed, stop."
        exit 1
    fi
else
    echo "Building and installing LLVM and Clang fialed, stop."
    exit 1
fi

#download and build kint now
echo "Downloading kint sources..."
cd $this_script_sdir
git clone git://g.csail.mit.edu/kint
if [ $? != 0 ]; then
    echo "Download failed, test stop. "
    exit 1
fi
echo "Download kint sources successfully."
echo "Patching kint sources now..."
cd kint/
patch -bp1 < ../kint-tool/IntRewrite.patch
patch -bp1 < ../kint-tool/IntLibcalls.patch
if [ $? != 0 ]; then
    echo "Patch failed, test stop."
    exit 1
fi
echo "Patch successfully, continue.."
echo "Building kint now..."
autoreconf -fvi
mkdir build
cd build/
../configure
make -j `cat /proc/cpuinfo | grep processor |wc -l` 
#cp the builed kint to tools/kint/ by xuyongjian
cp ../ ../../../../tools/kint/kint -r
#end xuyongjian
if [ $? != 0 ]; then
    echo "Build kint failed, test stop."
    exit 1
fi
echo "Build kint successfully."

