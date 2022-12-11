#! /bin/bash


# input files
# genome fasta formatted for bedtools
GENOMEFASTA=$1
# genome contig sizes formatted for bedtools
GENOMEBED=$2
# nucmer output
NUCCOORS=$3


# output directory and files
OUT_DIR=$(echo "${4%/}")
UNIBED="$OUT_DIR/uni_seq.nuc.bed"
UNIFASTA="$OUT_DIR/uni_seq.nuc.fasta"


# convert nucmer coords into bed fmt
# merge overlapping alignments
awk -v OFS="\t" '{print $12,$1,$2}' $NUCCOORS |
bedtools sort |
bedtools merge > $UNIBED.tmp


# find $REF specific intervals
# achieved by finding intervals not in nucmer bed
# removed 1 bp intervals
bedtools complement -i $UNIBED.tmp -g $GENOMEBED |
awk -v OFS="\t" '($3-$2)>1' > $UNIBED   


# extract $REF specific sequences \
# using $REF specific intervals
bedtools getfasta \
-fi $GENOMEFASTA \
-bed $UNIBED \
-fo $UNIFASTA 2> $OUT_DIR/bedtools.err


# clean-up
rm $UNIBED.tmp
