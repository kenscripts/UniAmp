#! /bin/bash

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Description
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# perform local blastn with custom output format
# output is sent to stdout

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# I/O
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# input
BLAST_QUERY=$1
BLAST_SUBJECT=$2

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Instructions
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

$BLASTN_PATH \
-query $BLAST_QUERY \
-subject $BLAST_SUBJECT \
-evalue 1e-10 \
-outfmt "6 qseqid sseqid qlen length qcovs pident nident mismatch gaps qstart qend sstart send evalue bitscore" \
