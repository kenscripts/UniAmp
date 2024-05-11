#! /bin/bash

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
echo ""
echo "Description:"
echo "formats target genome sequence for bedtools and creates target genome bed"

echo ""
echo "Usage:"
echo "build_bedtools_files.sh <TARGET_GNOME> <OUT_DIR>"
  
echo ""
echo "Arguments:"
echo "<TARGET_GNOME> = path to target genome sequence"
echo "<OUT_DIR> = path to output directory"
  
echo ""
echo "Dependencies:"
echo "fasta_contig_length.py"

echo ""
echo "Output:"
echo "target_bedtools.fasta (fasta file of target genome for bedtools)"
echo "target_bedtools.bed (bed file of target genome for bedtools)"
  
echo ""
exit 1
fi

##################################################
# Input
##################################################

TARGET_GNOME=$1
OUT_DIR=${2%/}

##################################################
# Output
##################################################

TARGET_BTFASTA="$OUT_DIR/target_bedtools.fasta"
TARGET_BTBED="$OUT_DIR/target_bedtools.bed"

##################################################
# Formatting Target Genome Sequence
##################################################

# genome file modified to match nucmer output
# required for bedtools
sed \
-r 's/(>\S+).+/\1/' \
$TARGET_GNOME \
> $TARGET_BTFASTA;

# build genome bed file
# contains sizes of each contig
fasta_contig_length.py \
-i $TARGET_BTFASTA \
> $TARGET_BTBED;
