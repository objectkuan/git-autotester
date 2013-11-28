MAIN := ldv_main0_sequence_infinite_withcheck_stateful
V=@
default:
	@echo "make [ldv-cc|ldv-ld|aspect|blast|clean]"

all: ${MID_C} ${OUT_C}
#all: ldv-cc ldv-ld aspect blast

#ldv-cc:
${MID_C}: ${IN_C}
	$Vcp ${IN_C} ${MID_C}
	$Vjava -ea -jar ${LDV_HOME}/drv-env-gen/ldv_cc.jar ${MID_C} \
	--main -o ${OBJ_C} -c 0 -props ${LDV_HOME}/drv-env-gen/default.properties

ldv-ld:
	$Vjava -ea -jar ${LDV_HOME}/drv-env-gen/ldv_ld.jar ${OBJ_C} \
	-o ${OBJ_KO}

#aspect:
${OUT_C}: ${MID_C}
	$VLDV_COMMON_MODEL=${COMMON_MODEL} \
	${LDV_HOME}/ri/bin/compiler \
	--keep-prepared-file --keep \
	--in ${MID_C} --aspect "kernel-rules/models/${RULE}" --back-end src --out ${OUT_C} \
	--general-opts -Ikernel-rules \
	--aspect-preprocessing-opts "--include ${LDV_HOME}/ri/ri.aspect" \
	-- \
	-isystem /usr/lib/gcc/x86_64-linux-gnu/4.6/include \
	-I${LINUX_DIR}/include \
	-I${LINUX_DIR}/include/uapi \
	-I${LINUX_DIR}/include/generated \
	-I${LINUX_DIR}/include/generated/uapi \
	-I${LINUX_DIR}/arch/x86/include \
	-I${LINUX_DIR}/arch/x86/include/uapi \
	-I${LINUX_DIR}/arch/x86/include/generated \
	-I${LINUX_DIR}/arch/x86/include/generated/uapi \
	-include ${LINUX_DIR}/include/linux/kconfig.h \
	-D__KERNEL__ -D__KERN__ -D__LINUX_X86_ARCH__ \
	-U__GNUC_MINOR__ -D__GNUC_MINOR__=4 \
	-D 'KBUILD_BASENAME=\"test_main\"' -D 'KBUILD_MODNAME=\"test\"' \
	-DLDV_MAIN0_sequence_infinite_withcheck_stateful \
	-mcmodel=kernel -w \
	-include ${LDV_HOME}/kernel-rules/models/config-tracers.h

#blast:
	$V${LDV_HOME}/dscv/rcv/backends/blast/bin/pblast.opt ${OUT_C} \
	-predH 7 -craig 2 -ignoredupfn -enable-recursion -nolabelmeanssafe \
	-main ${MAIN} -L LDV_ERROR \
	-cldepth 0 -alias "" \

clean:
	$Vrm -rf *.mid.c *.o *.ko *.instrumented *.prepared *.macroinstrumented *.i *.out.c *.abs *.btr *.traces
	$Vrm -rf out.* ${COMMON_MODEL}
