#! /bin/bash

# Description:
# finds unique sequences in references compared to query genomes by performing pw genome alignment then local alignment

# Usage:
# uni_seq.sh <REF_GNOME> <QUERY_DIR> <OUT_DIR>

# Arguments:
# <REF_GNOME> = path to reference genome sequence
# <QUERY_DIR> = path to directory containing query genomes
# <OUT_DIR> = path to output directory

# Dependencies:
# gnome_uniseq.sh:::nucmer
# gnome_uniseq.sh:::show-coords
# gnome_uniseq.sh:::bedtools
# bioawk
# local_uniseq.sh:::blastn

##################################################
# Inputs
##################################################

REF_GNOME=$1
QUERY_DIR=${2%/}
OUT_DIR=${3%/}

##################################################
# Outputs
##################################################

UNIFASTA="$OUT_DIR/uni_seq.nuc.fasta";
SIZED_UNIFASTA="$OUT_DIR/uni_seq.filtered.fasta"
SC_UNIFASTA="$OUT_DIR/uni_seq.sc.fasta"

##################################################
# Local
##################################################

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

##################################################
# Pair-wise Genome Alignment (gnome_uniseq.sh)
##################################################

sleep 1
printf "\n>>> Searching for unique sequences (gnome_uniseq.sh)"
sleep 1

# creates OUT_DIR
gnome_uniseq.sh \
$REF_GNOME \
$QUERY_DIR \
$OUT_DIR;

# check if sequences are present
fasta_check $UNIFASTA;

##################################################
# Removing Small Sequences
##################################################

sleep 1
printf "\n\n>>> Removing small sequences (<100 bp)\n\n"
sleep 1

# get sequences of appropriate size
$BIOAWK_PATH \
-c fastx \
'length($seq) > 100 {print ">"$name;print $seq}' \
$UNIFASTA \
> $SIZED_UNIFASTA;

# check if sequences are present
fasta_check $SIZED_UNIFASTA;

##################################################
# Local Alignment (local_uniseq.sh)
##################################################

sleep 1
printf "\n\n>>> Retrieving single-copy, unique sequences using local alignment (local_uniseq.sh)\n\n"
sleep 1

# get local unique sequences
local_uniseq.sh \
$SIZED_UNIFASTA \
$REF_GNOME \
<(cat $(find $QUERY_DIR -maxdepth 1 -type f )) \
$OUT_DIR;

# check for sequences
fasta_check $SC_UNIFASTA;
