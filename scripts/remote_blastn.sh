#! /bin/bash

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
cat << EOF

Usage:
    remote_blastn.sh <TARGET_SEQ> <BLAST_DB> <ENTREZ_TERM>

Description:
    Performs a remote blastn against specified organisms in NCBI database. 

Arguments:
    <TARGET_SEQ>   path of target fasta for blastn search
    <BLAST_DB>     database for blastn search
    <TAXID>        taxid for blastn search 

Output:
    Stdout

EOF
    exit 0
fi

##################################################
# Inputs
##################################################

TARGET_SEQ=$1;
BLAST_DB=$2;
ENTREZ_TERM=$3;

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
-query $TARGET_SEQ \
-db $BLAST_DB \
-entrez_query $ENTREZ \
-task blastn \
-evalue 1e-10 \
-max_hsps 1 \
-max_target_seqs 100 \
-outfmt "6 qseqid sseqid qlen length qcovs pident nident mismatch gaps qstart qend sstart send evalue bitscore";
