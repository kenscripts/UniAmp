#! /bin/bash

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
cat << EOF

Usage:
    gnome_uniseq.sh <TARGET_GNOME> <QUERY_DIR> <OUT_DIR>

Description:
    Performs pairwise genome alignment and extracts unique target sequences.

Arguments:
    <TARGET_GNOME>   path to target genome sequence
    <QUERY_DIR>      path to directory containing query genomes
    <OUT_DIR>        path to output directory

Dependencies:
    build_bedtools_files.sh:::bedtools
    nucmer
    build_uni_files.sh:::bedtools

Output:
    target_bedtools.fasta   fasta file of target genome for bedtools
    target_bedtools.bed     bed file of target genome for bedtools
    nuc.coors               coordinate file from nucmer
    ani.tsv                 average nucleotide identity calculated from nucmer output
    uni_seq.nuc.bed         bed file of unique target genome sequences
    uni_seq.nuc.fasta       fasta file of unique target genome sequences

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

NO_QUERIES=$(ls ${QUERY_DIR} | wc -l)

# output::build_bedtools_files.sh
TARGET_BTFASTA="$OUT_DIR/target_bedtools.fasta"
TARGET_BTBED="$OUT_DIR/target_bedtools.bed"

# output::nucmer
NUCCOORS="$OUT_DIR/nuc.coors"
ANI="$OUT_DIR/ani.tsv"

# output::build_uni_files.sh
UNIFASTA="$OUT_DIR/uni_seq.nuc.fasta"

##################################################
# Search Info
##################################################

sleep 1
printf "\n\nTarget: $TARGET_GNOME\n\n"
sleep 1
printf "Query directory: $QUERY_DIR\n\n"
sleep 1
printf "Number of queries: $NO_QUERIES\n\n"

##################################################
# File Formatting
##################################################

sleep 1
printf "Modifying target genome fasta for analysis.\n\n"

# build target_genome.fasta and target_genome.bed files
build_bedtools_files.sh \
$TARGET_GNOME \
$OUT_DIR;

##################################################
# Pairwise Genome Alignment (nucmer)
##################################################

sleep 1
INDEX=1
for QUERY in $(ls -p $QUERY_DIR | grep -v /);
do 
  echo -ne "Aligning query $INDEX of $NO_QUERIES to target.\r";

  # nucmer command; modify nucmer command as needed
  # -b: length of poor scoring region allowed by alignment extension
  # -c: cluster length
  # -g: maximum gap between clusters
  # -l: length of MUM
  # initially used -b 75 but changed to default
  # to maximize unique sequence retrieval for qPCR set b = 75
  $NUCMER_PATH \
  $TARGET_BTFASTA \
  $QUERY_DIR/$QUERY \
  2> $OUT_DIR/nuc.log;

  # build nuc.coors file
  $SHOWCOORDS_PATH -lcrT out.delta |
  tail -n +5 \
  >> $NUCCOORS;

  # run ANIm.sh to find similar queries to target
  # build ani.tsv file
  paste \
  -d "\t" \
  <(echo $QUERY) \
  <($SHOWCOORDS_PATH -rc out.delta | ANIm.sh) \
  >> $ANI;
  INDEX=$(expr $INDEX + 1);
done

##################################################
# Unique Target Sequences
##################################################

sleep 1
printf "\nFinding unique sequences in target genome.\n"

# build uni.fasta and uni.bed files
build_uni_files.sh \
$TARGET_BTFASTA \
$TARGET_BTBED \
$NUCCOORS \
$OUT_DIR;

# add header to nuc.coords file in case user wants to use
HEADER="S1\tE1\tS2\tE2\tLEN1\tLEN2\tIDY\tRLEN\tQLEN\tRCOV\tQCOV\tRCONTIG\tQCONTIG";
sed -i "1i $HEADER" $NUCCOORS;

# clean-up
rm out.delta;
