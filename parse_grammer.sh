#!/bin/sh

./bin.linux/HParse ./var/gram.txt ./var/wdnet.txt

if [ $? != 0 ]; then
    printf "Error when executing command: './bin.linux/HParse'\n"
	exit $ERROR_CODE
else
	printf "wdnet.txt written to ./var\n"
fi

printf "Done!\n"