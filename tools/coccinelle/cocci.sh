#!/bin/bash

blacklist=( \
scripts/coccinelle/null/deref_null.cocci \
scripts/coccinelle/null/kmerr.cocci \
scripts/coccinelle/free/iounmap.cocci \
scripts/coccinelle/free/pci_free_consistent.cocci \
scripts/coccinelle/locks/call_kern.cocci \
scripts/coccinelle/locks/double_lock.cocci \
scripts/coccinelle/locks/mini_lock.cocci \
scripts/coccinelle/misc/orplus.cocci
)

function in_black()
{
    for blackitem in ${blacklist[@]}; do
        if [ $1 = $blackitem ]; then
             return 1;
        fi
    done
    return 0;
}

COCCI=api/memdup_user.cocci
DIR=drivers/net

#for f in `find scripts/coccinelle/ -name '*.cocci' -type f | sort`; do
#    exist=$(in_black $f);
#    if [ "$?" = "0" ]; then
#	date
#        echo "###### $f"
#        make coccicheck MODE=report COCCI=$f
#    fi
#done

make coccicheck MODE=report M=$DIR COCCI=scripts/coccinelle/$COCCI
