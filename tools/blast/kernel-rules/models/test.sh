#!/bin/sh

ls *.aspect | \
	while read rule
	do
		echo ${rule}
	done
