#! /bin/bash

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Description
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# count number of amplicons generated for each primer pair by isPCR

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# I/O
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# input
ISPCR_TSV=$1
REF_FILE=$2

# output
OUT_DIR=$(dirname $ISPCR_TSV)
OUT_NAME=$(echo $ISPCR_TSV | xargs -n 1 basename | rev | cut -d"." -f2- | rev)
PCR_AMP_COUNT="$OUT_DIR/$OUT_NAME.amp_counts.tsv"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Instructions
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# get number of reference amplicons
cat $ISPCR_TSV |
# filter pr_pairs that don't amplify
grep -v "False" |
# ignore non-reference amplicons; removes header
grep "$REF_FILE" |
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
bedtools groupby -g 6 -c 1 -o count \
> $PCR_AMP_COUNT.tmp1

# get number of non-reference amplicons
cat $ISPCR_TSV |
# filter pr_pairs that don't amplify;
grep -v "False" |
# ignore reference amplicons
grep -v "$REF_FILE" |
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
bedtools groupby -g 6 -c 1 -o count \
> $PCR_AMP_COUNT.tmp2

# combine counts
# fill in missing fields with 0
# -o auto is required for use with -e
join -t $'\t' -e0 -a1 -a2 -1 1 -2 1 -o auto \
<(sort -k1,1 $PCR_AMP_COUNT.tmp1) \
<(sort -k1,1 $PCR_AMP_COUNT.tmp2) \
> $PCR_AMP_COUNT;

# remove tmp files
rm $OUT_DIR/*.tmp*;
