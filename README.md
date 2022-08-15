<!--
SPDX-FileCopyrightText: 2022 Martin Byrenheid <martin@byrenheid.net>

SPDX-License-Identifier: GPL-3.0-or-later
-->

# Batchify

Inspired by the `opp_runall` tool from [OMNet++](https://omnetpp.org), batchify allows one to leverage [GNU Make]() in order to distribute the execution of multiple independent, single-threaded program or script executions among the processors of a system.

For example, given one has a program or script `doSomething` that accepts a single file path as input and does some processing on the file on this path (e.g., compute statistical values about the data contained in the file) and `doSomething` is to be executed on several files. Without batchify, one could do so with a shell script of the form

```sh
for FILE in `echo /path/to/files/*`; do 

doSomething $FILE > /path/to/output

done
```

However, in this case, the files are processed sequentially, so that no more than one instance of `doSomething` is running at any point in time. Given that almost every personal computer or server today has several CPU cores, the above script will always only make use of one core, if `doSomething` does not execute multiple threads in parallel. With batchify, one can create a `makefile` and subsequently use `make` to execute a desired number of instances of `doSomething` in parallel.

## Usage

The batchify script requires a single parameter, which is the path to a file holding a list of shell commands to be executed, where entries are separated by a line break. Batchify then prints a corresponding makefile to standard output.

For the example given above, this means that if one wants to perform the processing of the files on a PC with 4 cores, one can use batchify to leverage all four cores as follows:

```sh
# First, modify the for loop from the above example so that, instead of executing doSomething, it only writes the commands to be executed into a temporary text file.
CMD_LIST=`mktemp`
for FILE in `echo /path/to/files/*`; do 

echo "doSomething $FILE > /path/to/output" >> $CMD_LIST

done

# Second, call batchify on the generated command list and redirect its output into a makefile
batchify.sh $CMD_LIST > makefile

# Remove the list of commands, as it is not needed anymore
rm $CMD_LIST

# Use make to execute the commands in the makefile, using all four cores
make -j4
```

If the PC has 8 cores instead, one can leverage all eight cores by changing the last line of the above example to `make -j8`.

As default, batchify creates a separate make job for each single line in the command list. To reduce overhead in cases where many files needs to be processed but the processing of each file only takes a few seconds or milliseconds, batchify accepts a positive, non-zero integer as second parameter that lets batchify create a make job for groups of lines in the command list file. In the above example, changing the second step to

```sh
batchify.sh $CMD_LIST 10 > makefile
```

would cause batchify to create a makefile where the job consists of executing first ten commands in the command list file, the second job consists of executing the 11th to 20th command in the list, and so on.

# License

Batchify is licensed under the GPL 3 license, using the [REUSE tool](https://reuse.software/) from the Free Software Foundation Europe.
