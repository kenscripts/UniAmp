#! /bin/bash

# entrez query doesn't input correctly; need to use blastn command separately

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Descriptions
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# performs remote blastn against specificed organism sequences in NCBI nt database 
# output is sent to stdout

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# I/O
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# input
QUERY=$1;
ENTREZ=$2;

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Instructions
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# print entrez search query
printf '\nEntrez Query: "%s"\n' "${ENTREZ[@]}"

# entrez input is stored as an array; expand array into 1 string
#-entrez_query $(printf '"%s"' "${ENTREZ[@]}") \
blastn \
-remote \
-query $QUERY \
-db nt \
-entrez_query XXX
-task blastn \
-evalue 1e-10 \
-max_hsps 1 \
-max_target_seqs 100 \
-outfmt "6 qseqid sseqid qlen length qcovs pident nident mismatch gaps qstart qend sstart send evalue bitscore";
