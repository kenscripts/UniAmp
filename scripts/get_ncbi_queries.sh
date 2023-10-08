#! /bin/bash

# Description:
# retrieves query genomes from NCBI that are a specific taxon with > 97% 16S rRNA sequence identity to reference genome sequence

# Usage:
# get_ncbi_queries.sh <REF_GNOME> <TAXON> <OUT_DIR>

# Arguments:
# <REF_GNOME> = filename of reference genome sequence
# <TAXON> = search for query genomes from a specific taxon
# <OUT_DIR> = path for output directory

# Dependencies:
# datasets
# rnammer
# blastn

##################################################
# Inputs
##################################################

REF_GNOME=$1
TAXON=$2
OUT_DIR=$3

##################################################
# Outputs
##################################################

# taxon accessions
ACCESSIONS="$OUT_DIR/ncbi_$TAXON.accessions"

# taxon genomes
QUERY_GNOMES="$OUT_DIR/ncbi_$TAXON.genomes.zip"

# reference 16S 
REF_NAME=$(basename $REF_GNOME | rev | cut -d"." -f2- | rev);
REF_16S="$OUT_DIR/$REF_NAME.16S.fna";

# query 16S
TAXON_BLAST="$OUT_DIR/ncbi_$TAXON.blast.tsv"
QACCESSIONS="$OUT_DIR/ncbi_queries.accessions"

# query genomes
NCBI_QUERY="$OUT_DIR/ncbi_query_gnomes"
mkdir -p $NCBI_QUERY

##################################################
# Taxon Accessions
##################################################

printf "\n>>> Retrieving $TAXON accessions\n\n"

# get tax accessions
$DATASETS_PATH summary genome taxon "$TAXON" --refseq |
$JQ_PATH \
-r \
'.assemblies[].assembly |
select(.assembly_level == "Complete Genome") |
.assembly_accession' \
> $ACCESSIONS

# get accession count
ACCESSION_COUNT=$(wc -l <$ACCESSIONS)
printf "Total number of $TAXON accessions: $ACCESSION_COUNT\n\n"

##################################################
# Taxon Genomes
##################################################

printf "\n>>> Downloading $TAXON genomes\n\n"

# download taxon genomes
$DATASETS_PATH \
download genome accession \
--inputfile $ACCESSIONS \
--filename $QUERY_GNOMES \
--exclude-gff3 \
--exclude-protein \
--exclude-rna;

# format directory
unzip $QUERY_GNOMES -d $OUT_DIR;
mv \
$OUT_DIR/ncbi_dataset/data/*/*_genomic.fna \
$OUT_DIR/ncbi_dataset/;
rm -r $OUT_DIR/ncbi_dataset/data;

##################################################
# Reference 16S rRNA Gene Sequence
##################################################

printf "\n>>> Searching for reference 16S rRNA gene sequences\n\n"

# get reference 16S seq
perl \
$RNAMMER_PATH \
-S bac \
-m ssu \
-f $REF_16S \
$REF_GNOME;
echo $REF_16S;

##################################################
# Find Similar 16S rRNA Gene Sequences
##################################################

printf "\n>>> %s\n\n" "Searching for queries from same species as reference (> 97 % 16S identity)"

# blast ref 16S against ncbi taxon genomes to find genomes of same species
$BLASTN_PATH \
-query $REF_16S \
-subject <(cat $OUT_DIR/ncbi_dataset/*_genomic.fna) \
-task megablast \
-evalue 1e-10 \
-max_hsps 1 \
-outfmt "6 qseqid sseqid qlen length qcovs pident nident mismatch gaps qstart qend sstart send evalue bitscore" \
> $TAXON_BLAST

# need to remove reference from query dataset; do that by removing queries with 100 % identity to reference
# retrieve species members by filtering for > 97 % identity
awk \
'$5 == 100 && $6 > 97 && $6 != 100' \
$OUT_DIR/ncbi_$TAXON.blast.tsv |
cut -f2 \
> $QACCESSIONS.tmp

# get names of assembly accessions for blast hits
for QUERY_GNOME in $(ls $OUT_DIR/ncbi_dataset/*_genomic.fna);
do
  # blast hits contain contig name; need to find assembly accession that contains contig name
  # determine if blast hit is found in taxon genome
  QUERY_PATH=$(grep -l -f $QACCESSIONS.tmp $QUERY_GNOME);
  if [ -n "$QUERY_PATH" ];
  then
      basename $QUERY_PATH >> $QACCESSIONS.tmp2;
  else
      continue
  fi
done

# remove duplicates
sort $QACCESSIONS.tmp2 |
uniq \
> $QACCESSIONS

# get query count
QUERY_COUNT=$(wc -l <$QACCESSIONS)
printf "Total number of query genomes: $QUERY_COUNT\n\n"

##################################################
# Get NCBI Query Genomes
##################################################

printf "\n>>> Building ncbi_queries directory\n"


# mv query genomes from ncbi_datases to ncbi_queries
while read QUERY;
do
  mv \
  $OUT_DIR/ncbi_dataset/${QUERY} \
  $NCBI_QUERY;
done <$QACCESSIONS; 

##################################################
# Clean-Up
##################################################

printf "\n>>> Cleaning up intermediary files\n\n"

# delete ncbi_datasets
rm -r $OUT_DIR/ncbi_dataset;
rm $OUT_DIR/ncbi_$TAXON.genomes.zip;

# remove tmp files
rm $QACCESSIONS.tmp*
