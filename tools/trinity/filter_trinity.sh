#!/bin/bash

echo $1 > tmp
awk -f warn.awk tmp
awk -f bug.awk tmp
rm tmp
