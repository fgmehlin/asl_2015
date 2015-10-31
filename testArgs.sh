#!/bin/bash

echo "$#"

for var in "$@"
do
	echo "param x : $var" >> config.txt
done


