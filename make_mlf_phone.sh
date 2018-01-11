#!/bin/sh

./bin.linux/HLEd -l '*' -d ./var/dict.txt -i ./var/phones0.mlf ./conf/mkphones0.led ./var/words.mlf

if [ $? != 0 ]; then
    printf "Error when executing command: './bin.linux/HLEd'\n"
	exit $ERROR_CODE
else
	printf "phones0.mlf written to ./var\n"
fi

printf "Done!\n"