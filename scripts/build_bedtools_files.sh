#! /bin/bash

# Description:
# format reference genome sequence for bedtools

# Usage:
# build_bedtools_files.sh <REF_GNOME> <OUT_DIR>

# Arguments:
# <REF_GNOME> = path to reference genome sequence
# <OUT_DIR> = path to output directory

# Dependencies:
# fasta_contig_length.py

##################################################
# Input
##################################################

REF_GNOME=$1
OUT_DIR=${2%/}

##################################################
# Output
##################################################

REF_BTFASTA="$OUT_DIR/ref_bedtools.fasta"
REF_BTBED="$OUT_DIR/ref_bedtools.bed"

##################################################
# Formatting Reference Genome Sequence
##################################################

# genome file modified to match nucmer output
# required for bedtools
sed \
-r 's/(>\S+).+/\1/' \
$REF_GNOME \
> $REF_BTFASTA;

# build genome bed file
# contains sizes of each contig
fasta_contig_length.py \
-i $REF_BTFASTA \
> $REF_BTBED;
