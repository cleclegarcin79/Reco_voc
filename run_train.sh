#!/bin/sh
skip_10=0

if [ -x "$(command -v julia)" ]; then
	printf "Julia is installed, continuing...\n"
else
	printf "Please install Julia to run this script: apt-get install julia\n"
	exit 0
fi

chmod +x ./clean.sh
printf "cleaning old files (if present)\n"
./clean.sh

if [ ! -d "log" ]; then
	mkdir log
fi
if [ ! -d "var" ]; then
	mkdir var
fi

if [ ! -d "mfc" ]; then
	mkdir mfc
	mkdir mfc/train
	mkdir mfc/test
fi

if [ ! -d "HMM" ]; then
	mkdir HMM
	mkdir HMM/hmm0
	mkdir HMM/hmm1
	mkdir HMM/hmm2
	mkdir HMM/hmm3
	mkdir HMM/hmm4
	mkdir HMM/hmm5
	mkdir HMM/hmm6
	mkdir HMM/hmm7
	mkdir HMM/hmm8
	mkdir HMM/hmm9
	mkdir HMM/hmm10
	mkdir HMM/hmm11
	mkdir HMM/hmm12
	mkdir HMM/hmm13
	mkdir HMM/hmm14
	mkdir HMM/hmm15
fi

chmod +x ./src/*.py
chmod +x ./bin.linux/*

##################################
#### Grammar Parsing (step 1) ####
##################################

./bin.linux/HParse ./conf/gram.txt ./var/wdnet.txt

if [ $? != 0 ]; then
    printf "Error when executing command: './bin.linux/HParse'\n"
	exit $ERROR_CODE
else
	printf "wdnet.txt written to ./var\n"
fi

#####################################
#### Dictionary Parsing (step 2) ####
#####################################

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

cat ./var/monophones1 | ./src/create_monophones0.py > ./var/monophones0

if [ $? != 0 ]; then
    printf "Error when generating monophones0: './var/monophones0'\n"
	exit $ERROR_CODE
else
	printf "created './var/monophones0' \n"
fi

######################################
#### Samples generation (step 3) #####
######################################

if [ ! -f "testprompts.txt" ]; then
	./bin.linux/HSGen -l -n 200 ./var/wdnet.txt ./var/dict.txt > testprompts.txt

	if [ $? != 0 ]; then
	    printf "Error when executing command: './bin.linux/HSGen'\n"
		exit $ERROR_CODE
	else
		printf "testprompts.txt written to ./\n"
	fi
fi

################################
#### Parse prompts (step 4) ####
################################

cat ./testprompts.txt | ./src/conv2mlf.py > ./var/words.mlf

if [ $? != 0 ]; then
    printf "Error when parsing prompts: './testprompts.txt'\n"
	exit $ERROR_CODE
else
	printf "converted './testprompts.txt' to './var/words.mlf' \n"
fi

##################################
#### make MLF phones (step 4) ####
##################################

./bin.linux/HLEd -l '*' -d ./var/dict.txt -i ./var/phones0.mlf ./conf/mkphones0.led ./var/words.mlf

if [ $? != 0 ]; then
    printf "Error when executing command: './bin.linux/HLEd'\n"
	exit $ERROR_CODE
else
	printf "phones0.mlf written to ./var\n"
fi

./bin.linux/HLEd -l '*' -d ./var/dict.txt -i ./var/phones1.mlf ./conf/mkphones1.led ./var/words.mlf

if [ $? != 0 ]; then
    printf "Error when executing command: './bin.linux/HLEd'\n"
	exit $ERROR_CODE
else
	printf "phones1.mlf written to ./var\n"
fi

#################################
#### convert to MFC (step 5) ####
#################################

./src/generate_mfc_config.py train > ./var/codetr_train.scp

if [ $? != 0 ]; then
    printf "Error when generating mfc config: './var/codetr_train.scp'\n"
	exit $ERROR_CODE
else
	printf "generated './var/codetr_train.scp'\n"
fi

./src/generate_mfc_config.py test > ./var/codetr_test.scp

if [ $? != 0 ]; then
    printf "Error when generating mfc config: './var/codetr_test.scp'\n"
	exit $ERROR_CODE
else
	printf "generated './var/codetr_test.scp'\n"
fi

./src/generate_mfc_config.py train partial > ./var/train.scp

if [ $? != 0 ]; then
    printf "Error when generating mfc config: './var/train.scp'\n"
	exit $ERROR_CODE
else
	printf "generated './var/train.scp'\n"
fi

./src/generate_mfc_config.py test partial > ./var/test.scp

if [ $? != 0 ]; then
    printf "Error when generating mfc config: './var/test.scp'\n"
	exit $ERROR_CODE
else
	printf "generated './var/test.scp'\n"
fi

./bin.linux/HCopy -T 1 -C ./conf/wave_config -S ./var/codetr_train.scp > ./log/convert_train_log

if [ $? != 0 ]; then
    printf "Error when executing command: './bin.linux/HCopy'\n"
	exit $ERROR_CODE
else
	printf "parsed ./WAVE/train \n"
fi

./bin.linux/HCopy -T 1 -C ./conf/wave_config_test -S ./var/codetr_test.scp > ./log/convert_test_log

if [ $? != 0 ]; then
    printf "Error when executing command: './bin.linux/HCopy'\n"
	exit $ERROR_CODE
else
	printf "parsed ./WAVE/test \n"
fi

################################
#### HMM Trainning (step 6) ####
################################

./bin.linux/HCompV -C ./conf/HMM_config -f 0.01 -m -S ./var/train.scp -M ./HMM/hmm0 ./conf/HMM_proto

if [ $? != 0 ]; then
    printf "Error when executing command: './bin.linux/HCompV'\n"
	exit $ERROR_CODE
else
	printf "saved HMM to ./HMM/hmm0/HMM_proto\n"
fi

cat ./HMM/hmm0/vFloors | ./src/generate_macro.py > ./HMM/hmm0/macros

if [ $? != 0 ]; then
    printf "Error when generating: 'macros'\n"
	exit $ERROR_CODE
else
	printf "generated 'macros' \n"
fi

cat ./HMM/hmm0/HMM_proto | ./src/generate_hmmdefs.py ./var/monophones0 > ./HMM/hmm0/hmmdefs

if [ $? != 0 ]; then
    printf "Error when generating: 'hmmdefs'\n"
	exit $ERROR_CODE
else
	printf "generated 'hmmdefs' \n"
fi

./bin.linux/HERest -C ./conf/HMM_config -I ./var/phones0.mlf -t 250.0 150.0 1000.0 -S ./var/train.scp -H ./HMM/hmm0/macros -H ./HMM/hmm0/hmmdefs -M ./HMM/hmm1 ./var/monophones0 > ./log/HMM_update_1

if [ $? != 0 ]; then
    printf "Error when executing command: './bin.linux/HERest'\n"
	exit $ERROR_CODE
else
	printf "updated HMM 1\n"
fi

./bin.linux/HERest -C ./conf/HMM_config -I ./var/phones0.mlf -t 250.0 150.0 1000.0 -S ./var/train.scp -H ./HMM/hmm1/macros -H ./HMM/hmm1/hmmdefs -M ./HMM/hmm2 ./var/monophones0 > ./log/HMM_update_2

if [ $? != 0 ]; then
    printf "Error when executing command: './bin.linux/HERest'\n"
	exit $ERROR_CODE
else
	printf "updated HMM 2\n"
fi

./bin.linux/HERest -C ./conf/HMM_config -I ./var/phones0.mlf -t 250.0 150.0 1000.0 -S ./var/train.scp -H ./HMM/hmm2/macros -H ./HMM/hmm2/hmmdefs -M ./HMM/hmm3 ./var/monophones0 > ./log/HMM_update_3

if [ $? != 0 ]; then
    printf "Error when executing command: './bin.linux/HERest'\n"
	exit $ERROR_CODE
else
	printf "updated HMM 3\n"
fi

#####################################
#### HMM silence fixing (step 7) ####
#####################################

cat ./HMM/hmm3/hmmdefs | ./src/add_sp.py > ./HMM/hmm4/hmmdefs
cp ./HMM/hmm3/macros ./HMM/hmm4/macros

if [ $? != 0 ]; then
    printf "Error when adding sp to 'hmmdefs'\n"
	exit $ERROR_CODE
else
	printf "added sp to 'hmmdefs' 4\n"
fi

cat ./var/monophones0 | ./src/create_monophones1.py > ./var/monophones1

if [ $? != 0 ]; then
    printf "Error when generating monophones1: './var/monophones1'\n"
	exit $ERROR_CODE
else
	printf "created './var/monophones1' \n"
fi

./bin.linux/HHEd -H ./HMM/hmm4/macros -H ./HMM/hmm4/hmmdefs -M ./HMM/hmm5 ./conf/sil.hed ./var/monophones1

if [ $? != 0 ]; then
    printf "Error when executing command: './bin.linux/HHEd'\n"
	exit $ERROR_CODE
else
	printf "update HMM for 'sp' 5\n"
fi

./bin.linux/HERest -C ./conf/HMM_config -I ./var/phones1.mlf -t 250.0 150.0 1000.0 -S ./var/train.scp -H ./HMM/hmm5/macros -H ./HMM/hmm5/hmmdefs -M ./HMM/hmm6 ./var/monophones1 > ./log/HMM_update_6

if [ $? != 0 ]; then
    printf "Error when executing command: './bin.linux/HERest'\n"
	exit $ERROR_CODE
else
	printf "updated HMM 6\n"
fi

./bin.linux/HERest -C ./conf/HMM_config -I ./var/phones1.mlf -t 250.0 150.0 1000.0 -S ./var/train.scp -H ./HMM/hmm6/macros -H ./HMM/hmm6/hmmdefs -M ./HMM/hmm7 ./var/monophones1 > ./log/HMM_update_7

if [ $? != 0 ]; then
    printf "Error when executing command: './bin.linux/HERest'\n"
	exit $ERROR_CODE
else
	printf "updated HMM 7\n"
fi

######################################
#### realigning the data (step 8) ####
######################################

cat ./var/dict.txt | ./src/add_silence.py ./var/dict.txt

if [ $? != 0 ]; then
    printf "Error when adding silence to : './var/dict.txt'\n"
	exit $ERROR_CODE
else
	printf "added silence to : './var/dict.txt' \n"
fi

./bin.linux/HVite -l '*' -o SWT -b SILENCE -C ./conf/HMM_config -a -H ./HMM/hmm7/macros -H ./HMM/hmm7/hmmdefs -i ./var/aligned.mlf -m -t 250.0 150.0 1000.0 -y lab -I ./var/words.mlf -S ./var/train.scp  ./var/dict.txt ./var/monophones1

if [ $? != 0 ]; then
    printf "Error when executing command: './bin.linux/HVite'\n"
	exit $ERROR_CODE
else
	printf "realigned the data\n"
fi

./bin.linux/HERest -C ./conf/HMM_config -I ./var/aligned.mlf -t 250.0 150.0 1000.0 -S ./var/train.scp -H ./HMM/hmm7/macros -H ./HMM/hmm7/hmmdefs -M ./HMM/hmm8 ./var/monophones1 > ./log/HMM_update_8

if [ $? != 0 ]; then
    printf "Error when executing command: './bin.linux/HERest'\n"
	exit $ERROR_CODE
else
	printf "updated HMM 8\n"
fi

./bin.linux/HERest -C ./conf/HMM_config -I ./var/aligned.mlf -t 250.0 150.0 1000.0 -S ./var/train.scp -H ./HMM/hmm8/macros -H ./HMM/hmm8/hmmdefs -M ./HMM/hmm9 ./var/monophones1 > ./log/HMM_update_9

if [ $? != 0 ]; then
    printf "Error when executing command: './bin.linux/HERest'\n"
	exit $ERROR_CODE
else
	printf "updated HMM 9\n"
fi

#################################
#### make triphones (step 9) ####
#################################

./bin.linux/HLEd -A -D -T 1 -n ./var/triphones1 -l '*' -i ./var/wintri.mlf ./conf/mktri.led ./var/aligned.mlf > ./log/step9-HLEd.txt

if [ $? != 0 ]; then
    printf "Error when executing command: './bin.linux/HLEd'\n"
	exit $ERROR_CODE
else
	printf "new aligned phones parsed\n"
fi

cat ./var/monophones1 | ./src/generate_mktri_config.py > ./var/mktri.hed

if [ $? != 0 ]; then
    printf "Error when generating : './var/mktri.hed'\n"
	exit $ERROR_CODE
else
	printf "generated : './var/mktri.hed' \n"
fi

./bin.linux/HHEd -B -H ./HMM/hmm9/macros -H ./HMM/hmm9/hmmdefs -M ./HMM/hmm10 ./var/mktri.hed ./var/monophones1

if [ $? != 0 ]; then
    printf "Error when executing command: './bin.linux/HHEd'\n"
	exit $ERROR_CODE
else
	printf "cloned to HMM 10\n"
fi


./bin.linux/HERest -B -C ./conf/HMM_config -I ./var/wintri.mlf -t 250.0 150.0 1000.0 -S ./var/train.scp -H ./HMM/hmm10/macros -H ./HMM/hmm10/hmmdefs -M ./HMM/hmm11 ./var/triphones1 > ./log/HMM_update_11

if [ $? != 0 ]; then
    printf "Error when executing command: './bin.linux/HERest'\n"
	exit $ERROR_CODE
else
	printf "updated HMM 11\n"
fi

./bin.linux/HERest -B -C ./conf/HMM_config -I ./var/wintri.mlf -t 250.0 150.0 1000.0 -s ./var/stats -S ./var/train.scp -H ./HMM/hmm11/macros -H ./HMM/hmm11/hmmdefs -M ./HMM/hmm12 ./var/triphones1 > ./log/HMM_update_12

if [ $? != 0 ]; then
    printf "Error when executing command: './bin.linux/HERest'\n"
	exit $ERROR_CODE
else
	printf "updated HMM 12\n"
fi

########################################
#### Tied-State Triphones (step 10) ####
########################################

cp ./conf/tree.hed ./var/tree.hed
julia ./src/mkclscript.jl ./var/monophones0 ./var/tree.hed

if [ $? != 0 ]; then
    printf "Error when generating : './var/tree.hed'\n"
	exit $ERROR_CODE
else
	printf "generated : './var/tree.hed' \n"
fi

./bin.linux/HDMan -b sp -n ./var/fulllist0 -g ./conf/maketriphones.ded -l ./log/flog  ./var/beep-tri ./var/dict.txt

if [ $? != 0 ]; then
    printf "Error when executing command: './bin.linux/HDMan'\n"
	exit $ERROR_CODE
else
	printf "fulllist0 and beep-tri written to ./var\n"
fi

cat ./var/fulllist0 | ./src/fill_fulllist.py ./var/monophones0 > ./var/fulllist

if [ $? != 0 ]; then
    printf "Error when updating fulllist: './var/fulllist'\n"
	exit $ERROR_CODE
else
	printf "created fulllist\n"
fi

./bin.linux/HHEd -B -H ./HMM/hmm12/macros -H ./HMM/hmm12/hmmdefs -M ./HMM/hmm13 ./var/tree.hed ./var/triphones1 > ./log/HHed_step10_log

if [ $? != 0 ]; then
    printf "Error when executing command: './bin.linux/HHEd'\n"
	exit $ERROR_CODE
else
	printf "added tied-state triphones to HMM 13\n"
fi

./bin.linux/HERest -B -C ./conf/HMM_config -I ./var/wintri.mlf -t 250.0 150.0 3000.0 -S ./var/train.scp -H ./HMM/hmm13/macros -H ./HMM/hmm13/hmmdefs -M ./HMM/hmm14 ./var/tiedlist > ./log/HMM_update_14

if [ $? != 0 ]; then
    printf "Error when executing command: './bin.linux/HERest'\n"
	exit $ERROR_CODE
else
	printf "updated HMM 14\n"
fi

./bin.linux/HERest -B -C ./conf/HMM_config -I ./var/wintri.mlf -t 250.0 150.0 3000.0 -S ./var/train.scp -H ./HMM/hmm14/macros -H ./HMM/hmm14/hmmdefs -M ./HMM/hmm15 ./var/tiedlist > ./log/HMM_update_15

if [ $? != 0 ]; then
    printf "Error when executing command: './bin.linux/HERest'\n"
	exit $ERROR_CODE
else
	printf "updated HMM 15\n"
fi


printf "\n------------------------\n"
printf "Finished without errors!"
printf "\n------------------------\n\n"