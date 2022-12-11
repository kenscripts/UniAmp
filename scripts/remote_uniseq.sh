#! /bin/bash

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Description
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# searches for matches to query sequences in NCBI nt database
# retrieves the most unique sequence

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# I/O
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# input
QUERY_FASTA=$1;
QUERY_BLASTN=$2;
OUT_DIR=${3%/}

# output
BLASTN_NAME=$(echo $QUERY_BLASTN | xargs -n 1 basename | rev | cut -d"." -f2- | rev);
BLASTN_STATS="$OUT_DIR/$BLASTN_NAME.qstats.tsv";
FASTA_NAME=$(echo $QUERY_FASTA | xargs -n 1 basename | rev | cut -d"." -f2- | rev);
REM_UNISEQ="$OUT_DIR/$FASTA_NAME.rem_uniq.fasta";

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Instructions
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

sleep 1;
printf "\n>>> Summarizing BLASTN results for each query sequence\n\n";
sleep 1;

# get stats
get_query_blast_stats.sh \
$QUERY_FASTA \
$QUERY_BLASTN \
$OUT_DIR;



sleep 1;
printf "\n>>> Extracting most unique sequence\n\n";
sleep 1;

# get most unique match
UNIQ_MATCH=$(head -n 1 $BLASTN_STATS | cut -f1);
bioawk \
-v SEQID="$UNIQ_MATCH" \
-c fastx \
'$name ~ SEQID {print ">"$name; print $seq}' \
$QUERY_FASTA \
> $REM_UNISEQ;

# print uni_seq name
echo $UNIQ_MATCH;
