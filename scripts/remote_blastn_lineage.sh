#! /bin/bash

# Description:
# performs remote blastn search and attaches subject sequence lineage using taxonkit

# Usage:
# remote_blastn_lineage.sh <QUERY_FASTA> <BLAST_DB> <TAXON> <OUT_DIR>

# Arguments:
# <QUERY_FASTA> = path for query fasta to use in blastn search
# <BLAST_DB> = name of NCBI database to search in (e.g. nr)
# <TAXON> = limit blastn search to specific taxon (used as entrez query for [organism])
# <OUT_DIR> = path to output directory

# Dependencies:
# blastn
# taxonkit

# Notes:
# Tests were performed to make sure entrez query was working properly
# entrez queries were first used at the genus level ("Bosea")
# using this output further entrez queries were used for specific species ("Bosea vaviloviae" and "Bosea vestrisii")
# only matches from specific species were returned indicating entrez query for [organism] seems to work properly

##################################################
# Inputs
##################################################

QUERY_FASTA=$1
BLAST_DB=$2
TAXON=$3
OUT_DIR=$4

##################################################
# Outputs
##################################################

OUT_NAME=$(echo $QUERY_FASTA | xargs -n 1 basename | rev | cut -d"." -f2- | rev);
BLAST_OUT="$OUT_DIR/$OUT_NAME.remblastn_out.tsv"

##################################################
# Remote BLASTN
##################################################

printf "\n>>> Performing remote blastn\n\n" >&2
printf "query sequences:\n" >&2
grep ">" $QUERY_FASTA | sed 's/>//g' >&2
printf "\nncbi database: $BLAST_DB\n" >&2
printf "\nblastn stderr:\n" >&2

# get tax-ids w/ BLAST
$BLASTN_PATH \
-remote \
-query $QUERY_FASTA \
-db $BLAST_DB \
-entrez_query "$TAXON [organism]" \
-task blastn \
-evalue 0.1 \
-max_target_seqs 25 \
-max_hsps 1 \
-outfmt "6 qseqid sseqid qlen length qcovs pident nident mismatch gaps qstart qend sstart send evalue bitscore staxids" |
sort -k16,16 \
> $BLAST_OUT.tmp1;

##################################################
# Lineage of BLASTN Matches (taxonkit)
##################################################

printf "\n>>> Getting lineage for blastn matches\n\n" >&2

cut -f16 $BLAST_OUT.tmp1 |
$TAXONKIT_PATH lineage --data-dir $TAXONKIT_DB |
$TAXONKIT_PATH reformat --data-dir $TAXONKIT_DB --format "{p};{c};{o};{f};{g};{s}" |
cut -f1,3 | sort -k1,1 |
uniq \
> $BLAST_OUT.tmp2;

##################################################
# Merge BLASTN and Taxonkit Output
##################################################

printf "\n>>> Adding lineage to blastn output\n\n" >&2
# join blast & lineage using tax-id
join -t$'\t' -1 16 -2 1 \
$BLAST_OUT.tmp1 \
$BLAST_OUT.tmp2 |
# remove tax-id info
cut -f2- \
> $BLAST_OUT;

# remove temporary files
rm $BLAST_OUT.tmp*;
