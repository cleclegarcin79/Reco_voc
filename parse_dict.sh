#!/bin/sh

cat ./conf/fr.dict | ./src/sort.py > ./var/fr.sorted.dict

if [ $? != 0 ]; then
    printf "Error when sorting dictionary: './var/fr.dict'\n"
	exit $ERROR_CODE
else
	printf "sorted './var/fr.dict' to './var/fr.sorted.dict' \n"
fi

cat ./conf/words.txt | ./src/sort.py > ./var/words.sorted.txt

if [ $? != 0 ]; then
    printf "Error when sorting dictionary: './var/words.txt'\n"
	exit $ERROR_CODE
else
	printf "sorted './var/words.txt' to './var/words.sorted.txt' \n"
fi


./bin.linux/HDMan -m -w ./var/words.sorted.txt -n ./var/monophones1 -l ./log/dlog ./var/dict.txt ./var/fr.sorted.dict

if [ $? != 0 ]; then
    printf "Error when executing command: './bin.linux/HDMan'\n"
	exit $ERROR_CODE
else
	printf "dict.txt written to ./var\n"
fi

printf "Done!\n"