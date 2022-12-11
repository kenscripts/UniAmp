#! /bin/bash

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Description
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# returns single-copy, unique sequences using local alignment
# sequences are not duplicated in reference genome and are not found in queries;
# sequences are considered similar if:
# query coverage is > 75 % and percent identity is > 75 % 

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# I/O
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# input
UNISEQ=$1
REF_GNOME=$2
QUERY_GNOME=$3

# output
BLASTOUT=$4
SC_UNISEQ=$5

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Instructions
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# self blast to find duplicated sequences
local_blastn.sh \
$UNISEQ \
$REF_GNOME \
> $BLASTOUT;

# blast against queries to find common sequences
local_blastn.sh \
$UNISEQ \
$QUERY_GNOME \
>> $BLASTOUT;

# returns list of seq ids
awk \
'$5>75 && $6>75 {print $1}' \
$BLASTOUT |
sort |
uniq -c |
awk '$1 == 1 {print $2}' \
> $SC_UNISEQ.tmp;

# determine if there are sequences 
if [[ $(wc -l < $SC_UNISEQ.tmp) -eq 0 ]]; 
then
    echo "No sequences remaining";
    exit;
else
    # returns sequences using seq ids
    while read LINE;
    do
      bioawk \
      -v SEQID="$LINE" \
      -c fastx \
      '$name ~ SEQID {print ">"$name; print $seq}' \
      $UNISEQ \
      >> $SC_UNISEQ;
    done < $SC_UNISEQ.tmp;
fi

# clean-up
rm $SC_UNISEQ.tmp;
