#! /bin/bash

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Description
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# parses primer blast output into tsv
# runs in-silico PCR against specified genomes 

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# I/O
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# input
PB_HTML=$1
QUERY_PATHS=$2
REF_FILE_NAME=$3

# output
OUT_DIR=$(dirname PB_HTML)
OUT_NAME=$(echo $PB_HTML | xargs -n 1 basename | rev | cut -d"." -f2- | rev)
PB_RESULTS="$OUT_DIR/$OUT_NAME.tsv"
PRIMER_TSV="$OUT_DIR/$OUT_NAME.tmp"
PB_RESULTS_ISPCR="$OUT_DIR/$OUT_NAME.ispcr.tsv"
ISPCR_AMPCOUNTS="$OUT_DIR/$OUT_NAME.ispcr.amp_counts.tsv"
UNIPCR_OUT="$OUT_DIR/$OUT_NAME.uni_pcr.tsv"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Instructions
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

sleep 1
printf "\n>>> Parsing primer-blast output (pb_parser.py)\n\n"
sleep 1

# parse primer blast html output into tsv
# uses beautifulsoup and python3
pb_parser.py \
$PB_HTML \
> $PB_RESULTS;



sleep 1
printf "\n>>> Performing in-silico PCR on genomes in $QUERY_PATHS (run_isPCR.sh):\n\n"
sleep 1

# generate primer tsv file
# run_isPCR didn't accept from stdin
cut -f2,6,15 $PB_RESULTS |
tail -n +2 \
> $PRIMER_TSV;

# find amplicons in specified genomes
# generates *.ispcr.tsv file
run_isPCR.sh \
$PRIMER_TSV \
$QUERY_PATHS;



sleep 1
printf "\n\n>>> Tabulating number of isPCR amplicons for each primer pair (isPCR_amp_counts.sh)\n\n"
sleep 1

# get isPCR amplicon count
isPCR_amp_counts.sh \
$PB_RESULTS_ISPCR \
$REF_FILE_NAME;

# join together pb results and isPCR non-reference amplicon counts
join -t $'\t' -1 2 -2 1 \
<(tail -n +2 $PB_RESULTS | sort -k2,2) \
<(sort -k1,1 $ISPCR_AMPCOUNTS) \
> $UNIPCR_OUT;

# add header
HEADER="Primer_pair\tUnique_sequence\t"
HEADER+=$(head -n 1 $PB_RESULTS | cut -f3- | sed 's/\n//g')
HEADER+="\tRef_amplicons\tNonref_amplicons"
sed -i "1i $HEADER" $UNIPCR_OUT;
