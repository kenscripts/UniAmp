#! /bin/bash

# Description:
# format target genome sequence for bedtools

# Usage:
# build_bedtools_files.sh <TARGET_GNOME> <OUT_DIR>

# Arguments:
# <TARGET_GNOME> = path to target genome sequence
# <OUT_DIR> = path to output directory

# Dependencies:
# fasta_contig_length.py

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
