#! /bin/bash

# Description:
# retrieves query genomes containining a high ANI to a reference genome sequence

# Usage:
# get_gtdb_queries <GTDB_DIR> <REF_GNOME> <OUT_DIR>

# <GTDB_DIR> = directory containing gtdbtk output
# <REF_GNOME> = filename for reference genome sequence
# <OUT_DIR> = path for output directory

##################################################
# Inputs
##################################################

GTDB_DIR=${1%/};
REF_GNOME=$2;
REF_NAME=$(basename $REF_GNOME | rev | cut -d"." -f2- | rev);
OUT_DIR=${3%/};

##################################################
# Outputs
##################################################

GTDB_MATCHES="$OUT_DIR/gtdb_matches.tsv"
GTDB_QUERY="$OUT_DIR/gtdb_queries"
mkdir -p $GTDB_QUERY

##################################################
# Get GTDB Matches
##################################################

# remove possible matches to self
awk \
'$4 !~ /1.0/' \
$GTDB_DIR/gtdbtk.ani_summary.tsv |
grep "$REF_NAME" \
> $GTDB_MATCHES;

##################################################
# Build GTDB Query Directory
##################################################

# get genomes for matches
while read LINE;
do
  cp \
  $GTDBTK_DATA_PATH/fastani/database/*/*/*/*/${LINE}_genomic.fna.gz \
  $GTDB_QUERY;
  gunzip $GTDB_QUERY/${LINE}_genomic.fna.gz;
done <(cut -f2 $GTDB_MATCHES);
