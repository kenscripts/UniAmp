#! /bin/bash

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
	cat << EOF

Usage:
local_uniseq.sh <SIZED_UNIFASTA> <TARGET_GNOME> <QUERY_GNOMES> <OUT_DIR>

Description:
    Performs blastn local alignments of target-target and target-queries.
    Returns single-copy sequences unique to target genome sequence.

Arguments:
    <SIZED_UNIFASTA>   sequences (> 100 bp) unique to target genome sequence
    <TARGET_GNOME>     path to target genome sequence
    <QUERY_GNOMES>     path to directory containing query genomes
    <OUT_DIR>          path to output directory

Dependencies:
    local_blastn.sh:::blastn

Output:
    uni_seq.loc_blastn.tsv   blastn results from target-target and target-queries alignments
    uni_seq.sc.fasta         single-copy sequences unique to target genome sequence

EOF
    exit 0
fi

##################################################
# Input
##################################################

SIZED_UNIFASTA=$1
TARGET_GNOME=$2
QUERY_GNOMES=$3
OUT_DIR=$4

##################################################
# Output
##################################################

BLASTOUT="$OUT_DIR/uni_seq.loc_blastn.tsv"
SC_UNIFASTA="$OUT_DIR/uni_seq.sc.fasta"

##################################################
# BLAST
##################################################

# self blast to find duplicated sequences
local_blastn.sh \
$SIZED_UNIFASTA \
$TARGET_GNOME \
> $BLASTOUT;

# blast against queries to find common sequences
local_blastn.sh \
$SIZED_UNIFASTA \
$QUERY_GNOMES \
>> $BLASTOUT;

# determine number of similar hits for each sequence
# sequences are considered similar if:
# query coverage is > 75 % and percent identity is > 75 % 
# returns list of seq ids
awk \
'$5>75 && $6>75 {print $1}' \
$BLASTOUT |
sort |
uniq -c |
awk '$1 == 1 {print $2}' \
> $SC_UNIFASTA.tmp;

# determine if there are sequences 
if [[ $(wc -l < $SC_UNIFASTA.tmp) -eq 0 ]]; 
then
    echo "No sequences remaining";
    exit;
else
    # returns sequences using seq ids
    while read LINE;
    do
      $BIOAWK_PATH \
      -v SEQID="$LINE" \
      -c fastx \
      '$name ~ SEQID {print ">"$name; print $seq}' \
      $SIZED_UNIFASTA \
      >> $SC_UNIFASTA;
    done < $SC_UNIFASTA.tmp;
fi

# clean-up
rm $SC_UNIFASTA.tmp;
