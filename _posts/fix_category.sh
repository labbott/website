#!/bin/bash

for i in `ls *.markdown`; do
	sed -i .bak 's/categories:/category:/' $i
done
