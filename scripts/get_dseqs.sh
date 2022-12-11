#! /bin/bash

COORS=$1
IDY=$2
GENOMEFASTA=$3
OUTNAME=$(echo $COORS | cut -d"." -f 1)

awk -v OFS="\t" -v IDY=$IDY '$7<IDY' $COORS > $OUTNAME.dseqs.coors

$BEDTOOLS_PATH getfasta \
-fi $GENOMEFASTA \
-bed <(awk '{OFS="\t"; print $12,$1,$2}' $OUTNAME.dseqs.coors) \
-fo $OUTNAME.dseqs.fasta

# add header to dseqs coors file
HEADER="S1\tE1\tS2\tE2\tLEN1\tLEN2\tIDY\tRLEN\tQLEN\tRCOV\tQCOV\tRCONTIG\tQCONTIG"
sed -i "1i $HEADER" $OUTNAME.dseqs.coors
