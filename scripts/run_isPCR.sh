#! /bin/bash

# Description:
# runs in-silico PCR (ispcr) using input primers and checks if amplification occurs with primer pairs

# Usage:
# run_isPCR.sh <PRIMER_TSV> <QUERY_PATHS> <OUT_DIR>

# Arguments:
# <PRIMER_TSV> = path to file containing primer pair name and sequences
# <QUERY_PATHS> = path to file containing file paths to query genomes for ispcr
# <OUT_DIR> = path to output directory

# Dependencies:
# run_isPCR.sh:::usearch

# Notes:
# uses search_pcr command from usearch to get amplicon info
# - maxdiffs 5
# - min 25
# - max 2500
# modify as needed below

##################################################
# Inputs
##################################################

PRIMER_TSV=$1
QUERY_PATHS=$2
OUT_DIR=${3%/}

##################################################
# Outputs
##################################################

OUT_NAME=$(echo $PRIMER_TSV | xargs -n 1 basename | rev | cut -d"." -f2- | rev)
ISPCR_HITS="$OUT_DIR/$OUT_NAME.ispcr.tsv"

##################################################
# isPCR (usearch -search_pcr)
##################################################

# create isPCR file
for GNOME_PATH in $(cat $QUERY_PATHS);
do
  # get genome file name
  GNOME_FILE=$(basename $GNOME_PATH);

  # track progress
  echo -e "Running isPCR on $GNOME_FILE";

  # run ispcr using each primer pair
  while read LINE;
  do
    # generate primer fasta from pb results for usearch
    echo $LINE |
    awk '{print ">"$1".forward\n",$2,"\n>"$1".reverse\n",$3}' \
    > $OUT_DIR/primer.fasta.tmp;

    # get query genome
    cat $GNOME_PATH > $OUT_DIR/query.fasta.tmp;

    # run ispcr
    $USEARCH_PATH \
    -search_pcr $OUT_DIR/query.fasta.tmp \
    -db $OUT_DIR/primer.fasta.tmp \
    -strand both \
    -maxdiffs 5 \
    -minamp 25 \
    -maxamp 2500 \
    -pcrout ${ISPCR_HITS}.tmp \
    2>> $OUT_DIR/usearch.stderr \
    1>> $OUT_DIR/usearch.stdout;

    # get line count for filling in gnome_file column
    NO_OF_LINES=$(wc -l ${ISPCR_HITS}.tmp | cut -d" " -f1);

    # generate ispcr final output
    paste \
    <(yes "$GNOME_FILE" | head -n $NO_OF_LINES) \
    <(cat $ISPCR_HITS.tmp) \
    >> $ISPCR_HITS.tmp2;
  done < $PRIMER_TSV;
done

##################################################
# Primer-Pair Amplification (isPCR_amp_check.py)
##################################################

# add header and determine primer pair amplification
isPCR_amp_check.py \
$ISPCR_HITS.tmp2 \
> $ISPCR_HITS;

##################################################
# Clean-Up
##################################################

# clean-up tmp files
rm $OUT_DIR/*.tmp*;
