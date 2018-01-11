#!/bin/sh

cat ./testprompts.txt | ./src/conv2mlf.py > ./var/words.mlf

if [ $? != 0 ]; then
    printf "Error when parsing prompts: './testprompts.txt'\n"
	exit $ERROR_CODE
else
	printf "converted './testprompts.txt' to './var/words.mlf' \n"
fi

printf "Done!\n"