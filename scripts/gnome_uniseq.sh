#! /bin/bash

# Description:
# performs pw genome alignment and extracts unique reference sequences

# Usage:
# gnome_uniseq.sh <REF_GNOME> <QUERY_DIR> <OUT_DIR>

# Arguments:
# <REF_GNOME> = path to reference genome sequence
# <QUERY_DIR> = path to directory containing query genomes
# <OUT_DIR> = path to directory for output

# Dependencies:
# build_bedtools_files.sh:::bedtools
# nucmer
# build_uni_files.sh:::bedtools

##################################################
# Inputs
##################################################

REF_GNOME=$1
QUERY_DIR=$2
OUT_DIR=${3%/}

##################################################
# Outputs
##################################################

NO_QUERIES=$(ls ${QUERY_DIR} | wc -l)
REF_DIR=$(dirname $REF_GNOME)
mkdir -p $OUT_DIR

# output::build_bedtools_files.sh
REF_BTFASTA="$OUT_DIR/ref_bedtools.fasta"
REF_BTBED="$OUT_DIR/ref_bedtools.bed"

# output::nucmer
NUCCOORS="$OUT_DIR/nuc.coors"
ANI="$OUT_DIR/ani.tsv"

# output::build_uni_files.sh
UNIFASTA="$OUT_DIR/uni_seq.nuc.fasta"

##################################################
# Search Info
##################################################

sleep 1
printf "\n\nReference: $REF_GNOME\n"
sleep 1
printf "Query directory: $QUERY_DIR\n"
sleep 1
printf "Number of queries: $NO_QUERIES\n"

##################################################
# File Formatting
##################################################

sleep 1
printf "Modifying reference genome fasta for analysis.\n"

# build ref_genome.fasta and ref_genome.bed files
build_bedtools_files.sh \
$REF_GNOME \
$OUT_DIR;

##################################################
# Pairwise Genome Alignment (nucmer)
##################################################

sleep 1
INDEX=1
for QUERY in $(ls -p $QUERY_DIR | grep -v /);
do 
  echo -ne "Aligning query $INDEX of $NO_QUERIES to reference.\r";

  # nucmer command; modify nucmer command as needed
  # -b: length of poor scoring region allowed by alignment extension
  # -c: cluster length
  # -g: maximum gap between clusters
  # -l: length of MUM
  # initially used -b 75 but changed to default
  # to maximize unique sequence retrieval for qPCR set b = 75
  $NUCMER_PATH \
  $REF_BTFASTA \
  $QUERY_DIR/$QUERY \
  2> $OUT_DIR/nuc.log;

  # build nuc.coors file
  $SHOWCOORDS_PATH -lcrT out.delta |
  tail -n +5 \
  >> $NUCCOORS;

  # run ANIm.sh to find similar queries to reference
  # build ani.tsv file
  paste \
  -d "\t" \
  <(echo $QUERY) \
  <($SHOWCOORDS_PATH -rc out.delta | ANIm.sh) \
  >> $ANI;
  INDEX=$(expr $INDEX + 1);
done

##################################################
# Unique Reference Sequences
##################################################

sleep 1
printf "\nFinding unique sequences in reference genome.\n"

# build uni.fasta and uni.bed files
build_uni_files.sh \
$REF_BTFASTA \
$REF_BTBED \
$NUCCOORS \
$OUT_DIR;

# add header to nuc.coords file in case user wants to use
HEADER="S1\tE1\tS2\tE2\tLEN1\tLEN2\tIDY\tRLEN\tQLEN\tRCOV\tQCOV\tRCONTIG\tQCONTIG";
sed -i "1i $HEADER" $NUCCOORS;

# clean-up
rm out.delta;
