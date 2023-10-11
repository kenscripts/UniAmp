#! /bin/bash

# Description:
# parses primer blast output, performs in-silico PCR, and determines number of amplicons produced by each primer pair

# Usage:
# uni_pcr.sh <PB_HTML> <GNOME_PATHS> <TARGET_GNOME> <OUT_DIR>

# Arguments:
# <PB_HTML> = path to Primer-BLAST html output
# <GNOME_PATHS> = path to file containing file paths to target and query genomes
# <TARGET_GNOME> = path to target genome sequence
# <OUT_DIR> = path to output directory

# Dependencies:
# run_isPCR.sh:::usearch

##################################################
# Inputs
##################################################

PB_HTML=$1
GNOME_PATHS=$2
TARGET_GNOME=$3
OUT_DIR=${4%/}
OUT_NAME=$(echo $PB_HTML | xargs -n 1 basename | rev | cut -d"." -f2- | rev)

##################################################
# Outputs
##################################################

PB_RESULTS="$OUT_DIR/$OUT_NAME.tsv"
PB_PRIMERS="$OUT_DIR/$OUT_NAME.primers.tsv"
ISPCR_OUT="$OUT_DIR/$OUT_NAME.primers.ispcr.tsv"
ISPCR_AMPCOUNTS="$OUT_DIR/$OUT_NAME.primers.ispcr.amp_counts.tsv"
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
printf "\n>>> Performing in-silico PCR on genomes in $(echo $GNOME_PATHS | xargs -n 1 basename) (run_isPCR.sh):\n\n"
sleep 1

# generate primer tsv file
# run_isPCR didn't accept from stdin
cut -f2,6,15 $PB_RESULTS |
tail -n +2 \
> $PB_PRIMERS;

# find amplicons in specified genomes
# generates *.ispcr.tsv file
run_isPCR.sh \
$PB_PRIMERS \
$GNOME_PATHS \
$OUT_DIR;

##################################################
# Amplicon Counts for Primer Pairs (isPCR_amp_counts.sh)
##################################################

sleep 1
printf "\n\n>>> Tabulating number of isPCR amplicons for each primer pair (isPCR_amp_counts.sh)\n\n"
sleep 1

# get isPCR amplicon count
isPCR_amp_counts.sh \
$ISPCR_OUT \
$TARGET_GNOME \
$OUT_DIR;

##################################################
# Create UniPCR File
##################################################

# join together pb results and isPCR non-reference amplicon counts
join -t $'\t' -1 2 -2 1 \
<(tail -n +2 $PB_RESULTS | sort -k2,2) \
<(sort -k1,1 $ISPCR_AMPCOUNTS) \
> $UNIPCR_OUT;

# add header
HEADER="Primer_pair\tUnique_sequence\t"
HEADER+=$(head -n 1 $PB_RESULTS | cut -f3- | sed 's/\n//g')
HEADER+="\tTarget_amplicons\tNontarget_amplicons"
sed -i "1i $HEADER" $UNIPCR_OUT;
