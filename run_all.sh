#!/bin/sh

mkdir log

./parse_grammer.sh

if [ $? != 0 ]; then
	exit $ERROR_CODE
fi

./parse_dict.sh

if [ $? != 0 ]; then
	exit $ERROR_CODE
fi


./generate_samples.sh

if [ $? != 0 ]; then
	exit $ERROR_CODE
fi

printf "Done!\n"