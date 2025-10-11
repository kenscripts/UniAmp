#! /bin/bash

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
cat << EOF

Usage:
    uni_seq.sh <TARGET_GNOME> <QUERY_DIR> <OUT_DIR>

Description:
    Finds unique sequences in target genome compared to query genomes by performing pw genome alignment then local alignment.

Arguments:
    <TARGET_GNOME>   path to target genome sequence
    <QUERY_DIR>      path to directory containing query genomes
    <OUT_DIR>        path to output directory

Dependencies:
    gnome_uniseq.sh:::nucmer
    gnome_uniseq.sh:::show-coords
    gnome_uniseq.sh:::bedtools
    bioawk
    local_uniseq.sh:::blastn

Intermediate Output:
    target_bedtools.bed         bed file of target genome for bedtools
    target_bedtools.fasta.fai   index of target genome for bedtools
    target_bedtools.fasta       fasta file of target genome for bedtools
    bedtools.err                errors from bedtools
    nuc.coors                   coordinate file from nucmer
    nuc.log                     log for nucmer
    ani.tsv                     average nucleotide identity calculated from nucmer output
    uni_seq.nuc.bed             bed file of unique target genome sequences
    uni_seq.nuc.fasta           fasta file of unique target genome sequences
    uni_seq.filtered.fasta      fasta file of unique target genome sequences > 100 bp 
    uni_seq.loc_blastn.tsv      blastn results from target-target and target-queries alignments

Main Output:
    uni_seq.log        log for uni_seq.sh
    uni_seq.sc.fasta   single-copy sequences unique to target genome sequence

EOF
    exit 0
fi

##################################################
# Inputs
##################################################

TARGET_GNOME=$1
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
$TARGET_GNOME \
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
$TARGET_GNOME \
<(cat $(find $QUERY_DIR -maxdepth 1 -type f )) \
$OUT_DIR;

# check for sequences
fasta_check $SC_UNIFASTA;
