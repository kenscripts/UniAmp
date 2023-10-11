#! /bin/bash

# Description:
# counts number of isPCR amplicons generated from target and non-target genomes

# Usage:
# isPCR_amp_counts.sh <ISPCR_OUT> <TARGET_GNOME> <OUT_DIR>

# Arguments:
# <ISPCR_OUT> = path to is-PCR output
# <TARGET_GNOME> = path to target genome sequence
# <OUT_DIR> = path to output directory

# Dependencies:
# None

##################################################
# Inputs
##################################################

ISPCR_OUT=$1
TARGET_GNOME=$2
OUT_DIR=${3%/}

TARGET_NAME=$(echo $TARGET_GNOME | xargs -n 1 basename | rev | cut -d"." -f2- | rev)

##################################################
# Outputs
##################################################

OUT_NAME=$(echo $ISPCR_OUT | xargs -n 1 basename | rev | cut -d"." -f2- | rev)
PCR_AMP_COUNT="$OUT_DIR/$OUT_NAME.amp_counts.tsv"

##################################################
# Amplicon Counts for Primer Pairs
##################################################

# get number of target amplicons
cat $ISPCR_OUT |
# filter pr_pairs that don't amplify
grep -v "False" |
# ignore non-target amplicons; removes header
grep "$TARGET_NAME" |
awk \
-F"\t" \
-v OFS="\t" \
'{
split($6,pr1_name,".");
$6=pr1_name[1];
split($9,pr2_name,".");
$9=pr2_name[1];
print $0
}' |
sort -t$'\t' -k6,6 |
$BEDTOOLS_PATH groupby -g 6 -c 1 -o count \
> $PCR_AMP_COUNT.tmp1

# get number of non-target amplicons
cat $ISPCR_OUT |
# filter pr_pairs that don't amplify;
grep -v "False" |
# ignore target amplicons
grep -v "$TARGET_GNOME" |
# modify primer names to summarize primer pair info
awk \
-F"\t" \
-v OFS="\t" \
'{
split($6,pr1_name,".");
$6=pr1_name[1];
split($9,pr2_name,".");
$9=pr2_name[1];
print $0
}' |
tail -n +2 |
sort -t$'\t' -k6,6 |
$BEDTOOLS_PATH groupby -g 6 -c 1 -o count \
> $PCR_AMP_COUNT.tmp2

# combine counts
# fill in missing fields with 0
# -o auto is required for use with -e
join -t $'\t' -e0 -a1 -a2 -1 1 -2 1 -o auto \
<(sort -k1,1 $PCR_AMP_COUNT.tmp1) \
<(sort -k1,1 $PCR_AMP_COUNT.tmp2) \
> $PCR_AMP_COUNT;

##################################################
# Clean-Up
##################################################

rm $OUT_DIR/*.tmp*;
