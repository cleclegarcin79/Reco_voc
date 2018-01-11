#!/bin/sh

./bin.linux/HSGen -l -n 200 ./var/wdnet.txt ./var/dict.txt > testprompts.txt

if [ $? != 0 ]; then
    printf "Error when executing command: './bin.linux/HSGen'\n"
	exit $ERROR_CODE
else
	printf "testprompts.txt written to ./\n"
fi

printf "Done!\n"