#!/bin/sh

LINUX_DIR=`pwd`
LDV_HOME=/home/hjq/lab/sv/ldv-install
MY_BLAST=`dirname $0`
cd ${MY_BLAST}
MY_BLAST=`pwd`
cd -
MAIN=ldv_main0_sequence_infinite_withcheck_stateful
ERROR=LDV_ERROR
ANALYSIS_DIR=${LINUX_DIR}/drivers/tty/vt
RULESFILE=${MY_BLAST}/kernel-rules/models/0008.aspect

export PATH=$PATH:${LDV_HOME}/bin:${LDV_HOME}/dscv/rcv/backends/blast/bin
OUT_DIR=${MY_BLAST}/blast-out/${LINUX_DIR##*/}
COMMON_MODEL=${OUT_DIR}/ldv_common_model.c
mkdir -p ${OUT_DIR}

cd ${LINUX_DIR}
make allyesconfig > /dev/null
make init > /dev/null
cd -

find ${ANALYSIS_DIR} -name "*.c" | \
	while read IN_C
	do
		echo ===========================
		echo BLAST:start analysis ${IN_C}
		BASENAME=`basename ${IN_C}`
		DIRNAME=`dirname ${IN_C}`
		WORK_DIR=${OUT_DIR}/${DIRNAME#*drivers/}
		mkdir -p ${WORK_DIR}
		MID_C=${WORK_DIR}/${BASENAME%.c}.mid.c
		OBJ_C=${WORK_DIR}/${BASENAME%.c}.o
		OBJ_KO=${WORK_DIR}/${BASENAME%.c}.ko
		TRACES=${WORK_DIR}/${BASENAME%.c}.traces

		ls ${RULESFILE} | \
			while read RULES
			do

				RULESNAME=`basename ${RULES}`
				NAME=`grep ${RULESNAME} ${MY_BLAST}/kernel-rules/models/rules | cut -f 2 -d :`
				TITLE=`grep ${RULESNAME} ${MY_BLAST}/kernel-rules/models/rules | cut -f 3 -d :`
				SUMMARY=`grep ${RULESNAME} ${MY_BLAST}/kernel-rules/models/rules | cut -f 4 -d :`
				OUT_C=${WORK_DIR}/${BASENAME%.c}.${RULESNAME}.out.c

				cd ${MY_BLAST}
				`LINUX_DIR=${LINUX_DIR} LDV_HOME=${LDV_HOME} IN_C=${IN_C} MID_C=${MID_C} OBJ_C=${OBJ_C} OBJ_KO=${OBJ_KO} OUT_C=${OUT_C} COMMON_MODEL=${COMMON_MODEL} RULE=${RULESNAME} make all`
				cd -

				if [ -f ${TRACES} ]
				then
					echo "***begin*******************"
					echo ERROR:FILENAME:${IN_C}
					echo ERROR:RULES:${RULESNAME}
					echo ERROR:RULESNAME:${NAME}
					echo ERROR:RULESTITLE:${TITLE}
					echo ERROR:RULESSUMMARY:${SUMMARY}
					echo ERROR:TRACES:${TRACES}
					echo "***end*********************"
				fi
			done
		echo BLAST:end analysis ${IN_C}
		echo ===========================
	done

cd ${LINUX_DIR}
make mrproper > /dev/null
cd -
