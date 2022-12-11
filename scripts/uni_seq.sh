#! /bin/bash

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Description
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# find unique sequences in references compared to query genomes
# perform pw genome alignment then local alignment

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# I/O
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# input
REF_GNOME=$1
QUERY_DIR=${2%/}
OUT_DIR=${3%/}

# output
UNIFASTA="$OUT_DIR/uni_seq.nuc.fasta";
FILTERED_FASTA="$OUT_DIR/uni_seq.filtered.fasta"
LOCAL_BLAST="$OUT_DIR/uni_seq.loc_blastn.tsv"
SINGLECOPY="$OUT_DIR/uni_seq.sc.fasta"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Local
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# function to check for empty fasta files
fasta_check(){
FASTA=$1;
COUNT=$(grep -c ">" $FASTA);
if [[ $COUNT -eq 0 ]];
then
    echo "No sequences remaining";
    exit;
else
    printf "Number of sequences: $COUNT\n";
fi
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Instructions
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

sleep 1
printf "\n>>> Searching for unique sequences (find_uni_seq.sh)"
sleep 1

# creates OUT_DIR
find_uni_seq.sh \
$REF_GNOME \
$QUERY_DIR \
$OUT_DIR;

# check if sequences are present
fasta_check $UNIFASTA;



sleep 1
printf "\n\n>>> Removing small sequences (<100 bp)\n\n"
sleep 1

# get sequences of appropriate size
bioawk \
-c fastx \
'length($seq) > 100 {print ">"$name;print $seq}' \
$UNIFASTA \
> $FILTERED_FASTA;

# check if sequences are present
fasta_check $FILTERED_FASTA;



sleep 1
printf "\n\n>>> Retrieving single-copy, unique sequences using local alignment (local_uniseq.sh)\n\n"
sleep 1

# get local unique sequences
local_uniseq.sh \
$FILTERED_FASTA \
$REF_GNOME \
<(cat $(find $QUERY_DIR -maxdepth 1 -type f )) \
$LOCAL_BLAST \
$SINGLECOPY;

# check for sequences
fasta_check $SINGLECOPY;
