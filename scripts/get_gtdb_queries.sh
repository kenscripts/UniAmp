#! /bin/bash

##################################################
# Inputs
##################################################

GTDB_DIR=${1%/}
REF_GNOME=$2
REF_NAME=$(basename $REF_GNOME | rev | cut -d"." -f2- | rev);
OUT_DIR=${3%/}

##################################################
# Edit GTDB Files
##################################################

# output
GTDB_SUM="$GTDB_DIR/gtdbtk.ani_summary.noself.tsv"

# remove possible matches to self
awk \
'$4 !~ /1.0/' \
$GTDB_DIR/gtdbtk.ani_summary.tsv \
> $GTDB_SUM

##################################################
# Build GTDB Query Directory
##################################################

# output
GTDB_MATCHES="$OUT_DIR/gtdb_matches.ids"
QUERY_DIR="$OUT_DIR/gtdb_queries"
mkdir -p $QUERY_DIR

# get matches to reference
grep "$REF_NAME" $GTDB_SUM |
cut -f2 \
> $GTDB_MATCHES;

# get genomes for matches
while read LINE;
do
  cp \
  $GTDBTK_DATA_PATH/fastani/database/*/*/*/*/${LINE}_genomic.fna.gz \
  $QUERY_DIR;
  gunzip $QUERY_DIR/${LINE}_genomic.fna.gz;
done <$GTDB_MATCHES
