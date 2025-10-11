#! /bin/bash

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
cat << EOF

Usage:
    local_blast.sh <TARGET_SEQS> <QUERY_SEQS>

Description:
    Performs local alignment using blastn. E-value cutoff of 0.05 is used.

Arguments:
    <TARGET_SEQS>   target sequences for blastn comparison
    <QUERY_SEQS>    query sequences for blastn comparison

Dependencies:
    blastn

Output:
    stdout   blastn results (qseqid sseqid qlen length qcovs pident nident mismatch gaps qstart qend sstart send evalue bitscore)

EOF
    exit 0
fi

##################################################
# Inputs
##################################################

BLAST_QUERY=$1
BLAST_SUBJECT=$2

##################################################
# BLASTN
##################################################

$BLASTN_PATH \
-query $BLAST_QUERY \
-subject $BLAST_SUBJECT \
-evalue 0.05 \
-outfmt "6 qseqid sseqid qlen length qcovs pident nident mismatch gaps qstart qend sstart send evalue bitscore" \
