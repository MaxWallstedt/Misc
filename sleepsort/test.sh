#!/bin/bash

if [ $# -lt 1 ]
then
	echo -e "ERROR: Wrong usage\n" >&2
	echo "Usage:" >&2

	if [[ $EUID -eq 0 ]]
	then
		echo -e "\t# $0 <Space separated int array>" >&2
	else
		echo -e "\t$ $0 <Space separated int array>" >&2
	fi

	exit -1
fi

if [ ! -f "sleepsort" ]
then
	echo -e "ERROR: File \"sleepsort\" does not exist" >&2

	if [ -f "sleepsort.c" ]
	then
		echo -e "\nYou need to compile \"sleepsort.c\"" >&2
	fi

	exit -1
fi

i=1

while [ $i -le 10 ]
do
	echo "Test $i: "
	./sleepsort $@
	echo ""
	i=$(expr $i + 1)
done
