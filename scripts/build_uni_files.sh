#! /bin/bash

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
echo ""
echo "Description:"
echo "takes nucmer output, extracts unique target sequence intervals, and builds unique target sequences"

echo ""
echo "Usage:"
echo "build_uni_files.sh <TARGET_BTFASTA> <TARGET_BTBED> <NUCCOORS> <OUT_DIR>"

echo ""
echo "Arguments:"
echo "<TARGET_BTFASTA> = target genome fasta sequence formatted to match nucmer output"
echo "<TARGET_BTBED> = sizes of contigs in target genome sequence in bed format"
echo "<NUCCOORS> = coordinate output from nucmer"
echo "<OUT_DIR> = path to output directory"

echo ""
echo "Dependencies:"
echo "bedtools"

echo ""
echo "Output:"
echo "uni_seq.nuc.bed (bed file of unique target genome sequences)"
echo "uni_seq.nuc.fasta (fasta file of unique target genome sequences)"

echo ""
exit 1
fi

##################################################
# Input
##################################################

TARGET_BTFASTA=$1
TARGET_BTBED=$2
NUCCOORS=$3
OUT_DIR=${4%/}

##################################################
# Output
##################################################

UNIBED="$OUT_DIR/uni_seq.nuc.bed"
UNIFASTA="$OUT_DIR/uni_seq.nuc.fasta"

##################################################
# Unique Target Sequence Intervals (UNIBED)
##################################################

# convert nucmer coords into bed fmt
# merge overlapping alignments
awk -v OFS="\t" '{print $12,$1,$2}' $NUCCOORS |
$BEDTOOLS_PATH sort |
$BEDTOOLS_PATH merge \
> $UNIBED.tmp;

# find intervals specific to target sequence
# achieved by finding intervals not in nucmer bed
# removed 1 bp intervals
$BEDTOOLS_PATH complement \
-i $UNIBED.tmp \
-g $TARGET_BTBED |
awk -v OFS="\t" '($3-$2)>1' \
> $UNIBED;

##################################################
# Unique Target Sequences (UNIFASTA)
##################################################

$BEDTOOLS_PATH getfasta \
-fi $TARGET_BTFASTA \
-bed $UNIBED \
-fo $UNIFASTA \
2> $OUT_DIR/bedtools.err;

##################################################
# Clean-Up
##################################################

rm $UNIBED.tmp;
