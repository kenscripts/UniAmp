#! /bin/bash

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
cat << EOF

Usage:
    get_remote_uniseq.sh <QUERY_FASTA> <BLAST_DB> <TAXID> <OUT_DIR>

Description:
    Performs a remote blastn search and returns most unique query sequence

Arguments:
    <QUERY_FASTA>   path for query fasta to use in blastn search
    <BLAST_DB>      name of NCBI database to search against 
    <TAXID>         taxid for blastn search 
    <OUT_DIR>       path to output directory

Dependencies:
    remote_blastn_lineage:::blastn
    remote_blastn_lineage:::taxon
    bioawk"

Output:
    {}.remblastn_out.tsv
    {}.remblastn_qstats.tsv
    {}.rem_uniq.fasta

EOF
    exit 0
fi

##################################################
# Input
##################################################

QUERY_FASTA=$1;
BLAST_DB=$2;
TAXID=$3;
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

remote_blastn.sh \
$QUERY_FASTA \
$BLAST_DB \
$TAXID \
> $BLASTOUT;

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
