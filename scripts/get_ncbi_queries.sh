#! /bin/bash

REF_GNOME=$1
TAXON=$2
OUT_DIR=$3
mkdir -p $OUT_DIR

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

printf "\n>>> Retrieving $TAXON accessions\n\n"

# output
ACCESSIONS="$OUT_DIR/ncbi_$TAXON.accessions"

# get tax accessions
datasets summary genome taxon "$TAXON" --refseq |
jq \
-r \
'.assemblies[].assembly |
select(.assembly_level == "Complete Genome") |
.assembly_accession' \
> $ACCESSIONS

# get accession count
ACCESSION_COUNT=$(wc -l <$ACCESSIONS)
printf "Total number of $TAXON accessions: $ACCESSION_COUNT\n\n"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

printf "\n>>> Downloading $TAXON genomes\n\n"

# output
QUERY_GNOMES="$OUT_DIR/ncbi_$TAXON.genomes.zip"

# download taxon genomes
datasets \
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

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#printf "\n>>> Searching for query 16S rRNA gene sequences\n\n"

# output directory
#mkdir -p $OUT_DIR/query_16S
#QUERY_16S="$OUT_DIR/query_16S"

# get query 16S sequences
#for QUERY_FILE in $(ls $OUT_DIR/ncbi_dataset/*_genomic.fna);
#do 
#  QUERY_NAME=$(echo ${QUERY_FILE%_genomic.fna});
#  basename $QUERY_FILE;
#  perl \
#  $RNAMMER \
#  -S bac \
#  -m ssu \
#  -f $QUERY_NAME.16S.fna \
#  $QUERY_FILE;
#done

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

printf "\n>>> Searching for reference 16S rRNA gene sequences\n\n"

# output
REF_NAME=$(basename $REF_GNOME | rev | cut -d"." -f2- | rev);
REF_16S="$OUT_DIR/$REF_NAME.16S.fna";

# get reference 16S seq
perl \
$RNAMMER \
-S bac \
-m ssu \
-f $REF_16S \
$REF_GNOME;
echo $REF_16S;

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

printf "\n>>> %s\n\n" "Searching for queries from same species as reference (> 97 % 16S identity)"

# output
TAXON_BLAST="$OUT_DIR/ncbi_$TAXON.blast.tsv"
QACCESSIONS="$OUT_DIR/ncbi_queries.accessions"

# blast ref 16S against ncbi taxon genomes to find genomes of same species
blastn \
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

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

printf "\n>>> Building ncbi_queries directory\n"

# output
QUERY_DIR="$OUT_DIR/ncbi_queries"
mkdir -p $QUERY_DIR

# mv query genomes from ncbi_datases to ncbi_queries
while read QUERY;
do
  mv $OUT_DIR/ncbi_dataset/${QUERY} $QUERY_DIR;
done <$QACCESSIONS; 

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

printf "\n>>> Cleaning up intermediary files\n\n"

# delete ncbi_datasets
rm -r $OUT_DIR/ncbi_dataset;
rm $OUT_DIR/ncbi_$TAXON.genomes.zip;

# remove tmp files
rm $QACCESSIONS.tmp*
