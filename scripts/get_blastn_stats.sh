#! /bin/bash

# Description:
# returns BLAST statistics (median qcov, pdt, bitscore) for each query sequence

# Usage:
# get_blastn_stats.sh <QUERY_FASTA> <QUERY_BLASTN> <OUT_DIR>

# Arguments:
# <QUERY_FASTA> = path to query fasta used in blastn search
# <QUERY_BLASTN> = path to blast results of query fasta
# <OUT_DIR> = path to output directory

# Dependencies:
# None

##################################################
# Inputs
##################################################

QUERY_FASTA=$1;
QUERY_BLASTN=$2;
OUT_DIR=${3%/};

##################################################
# Outputs
##################################################

OUT_NAME=$(echo $QUERY_BLASTN | xargs -n 1 basename | rev | cut -d"." -f2- | rev);
QUERY_STATS="$OUT_DIR/$OUT_NAME.qstats.tsv";

# tmp files
TMP_BLAST="$OUT_DIR/blastn.tmp";
TMP_BLAST2="$OUT_DIR/blastn.tmp2";
TMP_MATCHES="$OUT_DIR/matches.tmp";

##################################################
# Instructions
##################################################

for QUERY in $(grep ">" $QUERY_FASTA | sed 's/>//g');
do
   # match found?
   if [[ $(wc -l < <(grep "$QUERY" $QUERY_BLASTN)) -eq 0 ]];
   then
       paste \
       <(echo $QUERY) \
       <(echo -e "0\t0\t0\t0\t0\t0") \
       >> $TMP_MATCHES;
   else
       # get top hit for query
       grep "$QUERY" $QUERY_BLASTN |
       head -n 1 \
       > $TMP_BLAST;
     
       # get info for top hit
       QUERY_LEN=$(cut -f3 $TMP_BLAST);
       TOP_COV=$(cut -f5 $TMP_BLAST);
       TOP_PIDT=$(cut -f6 $TMP_BLAST);
       TOP_BIT_SCORE=$(cut -f15 $TMP_BLAST);
       # scale returns float output
       TOP_NBS=$(echo "scale=2; $TOP_BIT_SCORE/$QUERY_LEN" | bc);
    
       # get all hits for query
       grep "$QUERY" $QUERY_BLASTN > $TMP_BLAST2;
    
       # get median coverage of all hits
       MED_COV=$(
       cat $TMP_BLAST2 |
       cut -f5 |
       sort -n |
       awk \
       '{
         count[NR]=$1} END {
         if (NR % 2 == 1) {print count[(NR+1)/2]}
         else {print (count[(NR/2)] + count[(NR/2) + 1]) / 2.0}
        }'
       );
    
       # get median percent identity of all hits
       MED_PIDT=$(
       cat $TMP_BLAST2 |
       cut -f6 |
       sort -n |
       awk \
       '{
         count[NR]=$1} END {
         if (NR % 2 == 1) {print count[(NR+1)/2]}
         else {print (count[(NR/2)] + count[(NR/2) + 1]) / 2.0}
        }'
       );
    
       # get median bitscore / query length of all hits
       MED_NBS=$(
       cat $TMP_BLAST2 |
       cut -f15 |
       sort -n |
       awk \
       -v LEN="$QUERY_LEN" \
       '{
         count[NR]=$1} END {
         if (NR % 2 == 1) {print (count[(NR+1)/2]) / LEN}
         else {print ((count[(NR/2)] + count[(NR/2) + 1]) / 2.0) / LEN}
        }'
       );
    
       # match statistics for each query
       paste \
       <(echo $QUERY) \
       <(echo $TOP_COV) \
       <(echo $TOP_PIDT) \
       <(echo $TOP_NBS) \
       <(echo $MED_COV) \
       <(echo $MED_PIDT) \
       <(echo $MED_NBS) \
       >> $TMP_MATCHES;
   fi;
done

# sort queries from most uniq to least uniq
cat $TMP_MATCHES |
sort -nk4,4 -nk7,7 \
> $QUERY_STATS;

# clean-up
rm $OUT_DIR/*.tmp*;
