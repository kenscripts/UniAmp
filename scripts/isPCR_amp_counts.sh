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

# dealing with primer pairs with 0 non-target amplification
count_check(){
AMPCOUNT_TMP=$1;
COUNT=$(wc -l < $AMPCOUNT_TMP);
ISPCR_OUT=$2;
if [[ $COUNT -eq 0 ]];
then
    tail -n +2 $ISPCR_OUT |
    # add primer pair name and add 0 for count
    awk \
    -F"\t" \
    -v OFS="\t" \
    '{
      split($6,pr1_name,".");
      $6=pr1_name[1];
      print $6,"0"
      }' |
    sort |
    uniq; 
else
    cat $AMPCOUNT_TMP;
fi
}

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
> $PCR_AMP_COUNT.tmp1 \
2> $PCR_AMP_COUNT.tmp1.err;

# get number of non-target amplicons
# remove header
tail -n +2 $ISPCR_OUT |
# filter pr_pairs that don't amplify;
grep -v "False" |
# ignore target amplicons
grep -v "$NAME" |
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
sort -t$'\t' -k6,6 |
$BEDTOOLS_PATH groupby -g 6 -c 1 -o count \
> $PCR_AMP_COUNT.tmp2 \
2> $PCR_AMP_COUNT.tmp2.err;

# combine counts
# fill in missing fields with 0
# -o auto is required for use with -e
join -t $'\t' -e0 -a1 -a2 -1 1 -2 1 -o auto \
<(sort -k1,1 <(count_check $PCR_AMP_COUNT.tmp1 $ISPCR_OUT)) \
<(sort -k1,1 <(count_check $PCR_AMP_COUNT.tmp2 $ISPCR_OUT)) \
> $PCR_AMP_COUNT;

##################################################
# Clean-Up
##################################################

rm $OUT_DIR/*.tmp*;
rm $OUT_DIR/*err;
