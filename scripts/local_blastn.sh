#! /bin/bash

# Description:
# perform local blastn 

# Usage:
# local_blast.sh <BLAST_QUERY> <BLAST_SUBJECT>

# Arguments:
# <BLAST_QUERY> = query sequence for blastn comparison
# <BLAST_SUBJECT> = subject sequence for blastn comparison

# Dependencies:
# blastn

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
-evalue 1e-10 \
-outfmt "6 qseqid sseqid qlen length qcovs pident nident mismatch gaps qstart qend sstart send evalue bitscore" \
