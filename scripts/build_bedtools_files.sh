#! /bin/bash


GENOME=$1
OUT_DIR=$(echo "${2%/}")
OUT_FASTA="$OUT_DIR/ref_bedtools.fasta"
OUT_BED="$OUT_DIR/ref_bedtools.bed"


# genome file modified to match nucmer output
# required for bedtools
sed -r 's/(>\S+).+/\1/' $GENOME > $OUT_FASTA


# build genome bed file
# contains sizes of each contig
fasta_contig_length.py -i $OUT_FASTA > $OUT_BED
