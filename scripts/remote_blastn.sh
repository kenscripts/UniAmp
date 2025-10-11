#! /bin/bash

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
cat << EOF

Usage:
    remote_blastn.sh <TARGET_SEQ> <ENTREZ_TERM>

Description:
    Performs remote blastn against specificed organism sequences in NCBI nt database. 

Arguments:
    <TARGET_SEQ>
    <ENTREZ_TERM>

Output:
    Stdout

EOF
    exit 0
fi

##################################################
# Inputs
##################################################

QUERY=$1;
ENTREZ=$2;

##################################################
# Remote BLASTN
##################################################

# print entrez search query
printf '\nEntrez Query: "%s"\n' "${ENTREZ[@]}"

# entrez input is stored as an array; expand array into 1 string
#-entrez_query $(printf '"%s"' "${ENTREZ[@]}") \
# entrez query doesn't input correctly; need to use blastn command separately
$BLASTN_PATH \
-remote \
-query $QUERY \
-db nt \
-entrez_query $ENTREZ \
-task blastn \
-evalue 1e-10 \
-max_hsps 1 \
-max_target_seqs 100 \
-outfmt "6 qseqid sseqid qlen length qcovs pident nident mismatch gaps qstart qend sstart send evalue bitscore";
