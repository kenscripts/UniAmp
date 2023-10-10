#! /bin/bash

# Description:
# parses primer blast output, performs in-silico PCR, and determines number of amplicons produced by each primer pair

# Usage:
# uni_pcr.sh <PB_HTML> <QUERY_PATHS> <OUT_DIR>

# Arguments:
# <PB_HTML> = path to Primer-BLAST html output
# <QUERY_PATHS> = path to file containing file paths to query genomes
# <OUT_DIR> = path to output directory

# Dependencies:
# gnome_uniseq.sh:::nucmer
# gnome_uniseq.sh:::show-coords
# gnome_uniseq.sh:::bedtools
# bioawk
# local_uniseq.sh:::blastn

##################################################
# Inputs
##################################################

PB_HTML=$1
QUERY_PATHS=$2
OUT_DIR=${3%/}

##################################################
# Outputs
##################################################

OUT_NAME=$(echo $PB_HTML | xargs -n 1 basename | rev | cut -d"." -f2- | rev)
PB_RESULTS="$OUT_DIR/$OUT_NAME.tsv"
PRIMER_TSV="$OUT_DIR/$OUT_NAME.tmp"
ISPCR_OUT="$OUT_DIR/$OUT_NAME.ispcr.tsv"
ISPCR_AMPCOUNTS="$OUT_DIR/$OUT_NAME.ispcr.amp_counts.tsv"
UNIPCR_OUT="$OUT_DIR/$OUT_NAME.uni_pcr.tsv"

##################################################
# Parse Primer-BLAST (pb_parser.py)
##################################################

sleep 1
printf "\n>>> Parsing primer-blast output (pb_parser.py)\n\n"
sleep 1

# parse primer blast html output into tsv
# uses beautifulsoup and python3
pb_parser.py \
$PB_HTML \
> $PB_RESULTS;

##################################################
# In-Silico PCR (run_isPCR.py)
##################################################

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

##################################################
# Amplicon Counts (isPCR_amp_counts.sh)
##################################################

sleep 1
printf "\n\n>>> Tabulating number of isPCR amplicons for each primer pair (isPCR_amp_counts.sh)\n\n"
sleep 1

# get isPCR amplicon count
isPCR_amp_counts.sh \
$ISPCR_OUT \
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
