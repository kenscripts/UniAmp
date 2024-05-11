#! /bin/bash

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
echo ""
echo "Description:"
echo "performs a remote blastn search and returns most unique query sequence"

echo ""
echo "Usage:"
echo "get_remote_uniseq.sh <QUERY_FASTA> <BLASTDB> <ENTREZ> <OUT_DIR>"

echo ""
echo "Arguments:"
echo "<QUERY_FASTA> = path for query fasta to use in blastn search"
echo "<BLAST_DB> = name of NCBI database to search against (e.g. nr)"
echo "<ENTREZ> = limit blastn search to specific entrez (e.g. 'Pseudomonas [organism]'"
echo "<OUT_DIR> = path to output directory"

echo ""
echo "Dependencies:"
echo "remote_blastn_lineage:::blastn"
echo "remote_blastn_lineage:::taxon"
echo "bioawk"


echo ""
echo "Output:"
echo "*.remblastn_out.tsv"
echo "*.remblastn_qstats.tsv"
echo "*.rem_uniq.fasta"

echo ""
exit 1
fi

##################################################
# Input
##################################################

QUERY_FASTA=$1;
BLAST_DB=$2;
ENTREZ="$3";
OUT_DIR=${4%/}

##################################################
# Output
##################################################

OUT_NAME=$(echo $QUERY_FASTA | xargs -n 1 basename | rev | cut -d"." -f2- | rev);
BLAST_OUT="$OUT_DIR/$OUT_NAME.remblastn_out.tsv";
QUERY_STATS="$OUT_DIR/$OUT_NAME.remblastn_qstats.tsv";
REM_UNISEQ="$OUT_DIR/$OUT_NAME.rem_uniq.fasta";

##################################################
# BLASTN w/ Lineage
##################################################

remote_blastn_lineage.sh \
$QUERY_FASTA \
$BLAST_DB \
"$ENTREZ" \
$OUT_DIR;

##################################################
# BLAST Stats
##################################################

sleep 1;
printf "\n>>> Summarizing BLASTN results for each query sequence\n\n";
sleep 1;

# get stats
get_blastn_stats.sh \
$QUERY_FASTA \
$BLAST_OUT \
$OUT_DIR;

##################################################
# Remote UniSeq
##################################################

sleep 1;
printf "\n>>> Extracting most unique sequence\n\n";
sleep 1;

# get most unique match
UNIQ_MATCH=$(head -n 1 $QUERY_STATS | cut -f1);
$BIOAWK_PATH \
-v SEQID="$UNIQ_MATCH" \
-c fastx \
'$name ~ SEQID {print ">"$name; print $seq}' \
$QUERY_FASTA \
> $REM_UNISEQ;

# print uni_seq name
echo $UNIQ_MATCH;
