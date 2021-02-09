#!/bin/bash

CMD_LIST_FILE=$1
BATCH_SIZE=$2

BATCHFILE=`mktemp`
BATCH_NO=0
CMD_NO=0
cat $CMD_LIST_FILE | while read LINE; do

  if [ $CMD_NO = 0 ]; then
	  echo "batch${BATCH_NO}:" >> $BATCHFILE
  fi

  echo -e "\t${LINE}" >> $BATCHFILE

  CMD_NO=$((CMD_NO + 1))
  if [ $CMD_NO = $BATCH_SIZE ]; then
	  BATCH_NO=$(($BATCH_NO + 1))
	  CMD_NO=0
  fi

done

NUM_JOBS=`cat $CMD_LIST_FILE | wc -l`
BATCH_NUM=$(($NUM_JOBS / $BATCH_SIZE))

if [ $(($BATCH_NUM * $BATCH_SIZE)) = $NUM_JOBS ]; then
   BATCH_NUM=$((BATCH_NUM - 1))
fi

echo -n "TARGETS="
for ((I=0; I <= ${BATCH_NUM}; I++)); do
   echo -n "batch${I} "
done
echo ""
echo ".PHONY: \$(TARGETS)"
echo "all: \$(TARGETS)"
echo -e "\t@echo All tasks completed."
cat $BATCHFILE

rm $BATCHFILE
