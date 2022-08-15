#!/bin/bash

# Write makefile into a temporary directory
TMP_DIR=`mktemp -d`
batchify $1 $2 > $TMP_DIR/makefile

if (( $? != 0 )); then
   echo -n "Batchify failed: "
   cat $TMP_DIR/makefile
   rm -rf $TMP_DIR
   exit 1
fi

NUM_PARALLEL=$3

# If no number of parallel processes is given,
# use all available CPUs
if [ -z "$NUM_PARALLEL" ]; then
   NUM_PARALLEL=`nproc`
fi

if (( $NUM_PARALLEL <= 0 )); then
   echo "Invalid number of parallel processes given."
   exit 1
fi

make -C $TMP_DIR -j $NUM_PARALLEL

rm -rf $TMP_DIR
