#! /bin/bash

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Description
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# performs pw genome alignment with nucmer
# extracts unique seq intervals in reference to build fasta using bedtools

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# I/O
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# input
REF=$1
QUERY_DIR=$2

# output
NO_QUERIES=$(ls ${QUERY_DIR} | wc -l)
REF_DIR=$(dirname $REF)
OUT_DIR=$(echo "${3%/}")
mkdir -p $OUT_DIR

# output::build_bedtools_files.sh
GENOMEFASTA="$OUT_DIR/ref_bedtools.fasta"
GENOMEBED="$OUT_DIR/ref_bedtools.bed"

# output::nucmer
NUCCOORS="$OUT_DIR/nuc.coors"
ANI="$OUT_DIR/ani.tsv"

# output::build_uni_files.sh
UNIFASTA="$OUT_DIR/uni_seq.nuc.fasta"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Instructions
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# search info
sleep 1
printf "\n\nReference: $REF\n"
sleep 1
printf "Query directory: $QUERY_DIR\n"
sleep 1
printf "Number of queries: $NO_QUERIES\n"



sleep 1
printf "Modifying reference genome fasta for analysis.\n"

# build ref_genome.fasta and ref_genome.bed files
build_bedtools_files.sh \
$REF \
$OUT_DIR;



sleep 1
# run nucmer
# run ANIm.sh to find similar queries to reference
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
  $GENOMEFASTA \
  $QUERY_DIR/$QUERY \
  2> $OUT_DIR/nuc.log;

  # build nuc.coors file
  show-coords -lcrT out.delta |
  tail -n +5 \
  >> $NUCCOORS;

  # build ani.tsv file
  paste \
  -d "\t" \
  <(echo $QUERY) \
  <(show-coords -rc out.delta | ANIm.sh) \
  >> $ANI;
  INDEX=$(expr $INDEX + 1);
done



sleep 1
printf "\nFinding unique sequences in reference genome.\n"

# build uni.fasta and uni.bed files
build_uni_files.sh \
$GENOMEFASTA \
$GENOMEBED \
$NUCCOORS \
$OUT_DIR;



# add header to nuc.coords file in case user wants to use
HEADER="S1\tE1\tS2\tE2\tLEN1\tLEN2\tIDY\tRLEN\tQLEN\tRCOV\tQCOV\tRCONTIG\tQCONTIG";
sed -i "1i $HEADER" $NUCCOORS;

# clean-up
rm out.delta;
