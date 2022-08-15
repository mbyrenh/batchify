#!/bin/bash

# SPDX-FileCopyrightText: 2022 Martin Byrenheid <martin@byrenheid.net>
#
# SPDX-License-Identifier: GPL-3.0-or-later

CMD_LIST_FILE=$1

if [ -z "$CMD_LIST_FILE" ]; then
   echo "No command list file path given."
   exit 1
fi

if [ ! -f $CMD_LIST_FILE ]; then
   echo "Given command list file does not exist or is not a regular file."
   exit 1
fi

BATCH_SIZE=$2

if [ -z "$BATCH_SIZE" ]; then
   BATCH_SIZE=1
fi

if (( $BATCH_SIZE <= 0 )); then
   echo "Invalid batch size $BATCH_SIZE given."
   exit 1
fi

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
