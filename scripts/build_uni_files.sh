#! /bin/bash

# Description:
# takes nucmer output, extracts unique refence sequence intervals, and builds unique reference sequences

# Usage:
# build_uni_files.sh <REF_BTFASTA> <REF_BTBED> <NUCCOORS> <OUT_DIR>

# Arguments:
# <REF_BTFASTA> = reference genome fasta sequence formatted to match nucmer output
# <REF_BTBED> = sizes of contigs in reference genome sequence in bed format
# <NUCCOORS> = coordinate output from nucmer
# <OUT_DIR> = path to output directory

# Dependencies:
# bedtools

##################################################
# Input
##################################################

REF_BTFASTA=$1
REF_BTBED=$2
NUCCOORS=$3
OUT_DIR=${4%/}

##################################################
# Output
##################################################

UNIBED="$OUT_DIR/uni_seq.nuc.bed"
UNIFASTA="$OUT_DIR/uni_seq.nuc.fasta"

##################################################
# Unique Reference Sequence Intervals (UNIBED)
##################################################

# convert nucmer coords into bed fmt
# merge overlapping alignments
awk -v OFS="\t" '{print $12,$1,$2}' $NUCCOORS |
$BEDTOOLS_PATH sort |
$BEDTOOLS_PATH merge \
> $UNIBED.tmp;

# find intervals specific to reference sequence
# achieved by finding intervals not in nucmer bed
# removed 1 bp intervals
$BEDTOOLS_PATH complement \
-i $UNIBED.tmp \
-g $REF_BTBED |
awk -v OFS="\t" '($3-$2)>1' \
> $UNIBED;

##################################################
# Unique Reference Sequences (UNIFASTA)
##################################################

$BEDTOOLS_PATH getfasta \
-fi $REF_BTFASTA \
-bed $UNIBED \
-fo $UNIFASTA \
2> $OUT_DIR/bedtools.err;

# clean-up
rm $UNIBED.tmp;
