#! /bin/bash

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Description
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# run in-silico PCR (ispcr) using primers to check for amplicons in genomes
# uses search_pcr command from usearch to get amplicon info

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# I/O
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# input
PRIMER_TSV=$1
QUERY_PATHS=$2

# ouput
OUT_DIR=$(dirname $PRIMER_TSV)
OUT_NAME=$(echo $PRIMER_TSV | xargs -n 1 basename | rev | cut -d"." -f2- | rev)
ISPCR_HITS="$OUT_DIR/$OUT_NAME.ispcr.tsv"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Instructions
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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
    usearch_v11 -search_pcr \
    $OUT_DIR/query.fasta.tmp \
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

# add header and determine primer pair amplification
add_isPCR_amp.py \
$ISPCR_HITS.tmp2 \
> $ISPCR_HITS

# clean-up tmp files
rm $OUT_DIR/*.tmp*;
