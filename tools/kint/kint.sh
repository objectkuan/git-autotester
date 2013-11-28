#!/bin/bash

echo "======================="
echo "Kint test"
echo "======================="

pwd_dir="$(pwd)"
this_script_dir="$(dirname "$0")"
cd $this_script_dir
this_script_sdir="$(pwd)"
cd $pwd_dir

#判断是否配置好llvm&clang 3.1的环境
clang_path=$(which clang)
if [ "$clang_path" != "" ]; then
	clang_version=$(clang --version | grep 3.1)
	if [ "$clang_version" != "" ]; then
		echo "[Kint test] The version of clang is satisfiable, test continues..."
	else
		echo "[Kint test] The version of clang is unsatisfiable, please build and install clang 3.1 firstly before the test, test stop."
		exit 1
	fi
else
	echo "[Kint test] Can't find clang in your computer, please install llvm&clang 3.1 before test, test stop."
	exit 1
fi

#判断是否存在编译好的kint
#cd $this_script_dir
kint_path=$(find "$this_script_sdir"/kint)
if [ "$kint_path" != "" ]; then
	echo "[Kint test] Find kint folder, check build folder..."
	kint_build_path=$(find "$this_script_sdir"/kint/build/bin)
	if [ "$kint_build_path" != "" ]; then
		echo "[Kint test] Find kint/build/bin folder, check excutable files..."
		#检测pintck
		pintck=$this_script_sdir'/kint/build/bin/pintck'
		if [ -x "$pintck" ]; then
			echo "[Kint test] Find pintck, continue..."
		else
			echo "[Kint test] Can not find pintck, or pintck is unusable, test stop."
			exit 1
		fi
		#检测kint-build
		kint_build=$this_script_sdir'/kint/build/bin/kint-build'
		if [ -x "$kint_build" ]; then
			echo "[Kint test] Find kint_build, continue..."
		else
			echo "[Kint test] Can not find kint_build, or kint_build is unusable, test stop."
			exit 1
		fi
	else
		echo "[Kint test] Can not find kint build folder, please build kint before test, test stop."
	fi
else
	echo "[Kint test] Can not find kint folder, please build kint in the current folder, test stop."
#	echo "[Kint test] Can not find kint folder, download and build kint now..."
	#download and build kint now
#	echo "[Kint test] Downloading kint sources..."
#	cd ..
#	git clone git://g.csail.mit.edu/kint
#	if [ $? != 0 ]; then
#		echo "[Kint test] Download failed, test stop. "
#		exit 1
#	fi
#	echo "[Kint test] Download kint sources successfully."
#	echo "[Kint test] Patching kint sources now..."
#	cd kint/
#	patch -bp1 < ../kint-tool/IntRewrite.patch
#	patch -bp1 < ../kint-tool/IntLibcalls.patch
#	if [ $? != 0 ]; then
#		echo "Patch failed, test stop."
#		exit 1
#	fi
#	echo "Patch successfully, continue.."
#	echo "[Kint test] Building kint now..."
#	autoreconf -fvi
#	mkdir build
#	cd build/
#	../configure
#	make
#	if [ $? != 0 ]; then 
#		echo "[Kint test] Build kint failed, test stop."
#		exit 1
#	fi
#	echo "[Kint test] Build kint successfully."
#	echo "[Kint test] Finish downloading and building kint, test continue."
fi

#使用kint对内核进行编译
make mrproper
#使用allyesconfig，确保检测结果的完善
make allyesconfig
"$kint_build" make -j `cat /proc/cpuinfo | grep processor| wc -l` 2>&1 >/tmp/kint.result
$pintck
#清理
make mrproper

#使用结果过滤脚本
rm_repeat=$this_script_sdir'/kint-tool/rm-rep'
if [ -x "$rm_repeat" ]; then
	echo "[Kint test] Find rm_repeat tool, check kint results..."
	kint_result=$pwd_dir'/pintck.txt'
	if [ -f $kint_result ]; then
		echo "[Kint test] Find pintck.txt, start to delete repeated results..."
		$rm_repeat $kint_result
		if [ $? = 0 ]; then
			echo "[Kint test] Delete repeated results successfully."
		else
			echo "[Kint test] Delete repeated results failed."
			exit 1
		fi
	else
		echo "[Kint test] Can not find pintck.txt, kint may be failed when analyze the kernel."
		exit 1
	fi
else
	echo "[Kint test] Can not find rm_repeat tool, please put the tool in the kint folder."
	exit 1
fi
#here comes the results by xuyongjian
cat pintck-filtered.txt 
#end xuyongjian
