#!/bin/bash

for i in `ls *.markdown`; do
	echo -en "---\nlayout: post\n" > /tmp/a
	tail -n+2 $i >> /tmp/a
	mv /tmp/a $i
done
