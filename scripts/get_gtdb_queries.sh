#! /bin/bash

# Description:
# retrieves query genomes from GTDB-tk ani_rep output that match target genome sequence

# Usage:
# get_gtdb_queries.sh <GTDBTK_DATA_PATH> <GTDB_DIR> <TARGET_GNOME> <OUT_DIR>

# Arguments:
# <GTDBTK_DATA_PATH> = path to GTDB-tk reference data
# <GTDB_DIR> = directory containing GTDB-tk ani_rep output
# <TARGET_GNOME> = filename of target genome sequence
# <OUT_DIR> = path to output directory

# Dependencies:
# output from GTDB-tk ani_rep
# GTDB-tk reference data

##################################################
# Inputs
##################################################

GTDBTK_DATA_PATH=${1%/};
GTDB_DIR=${2%/};
TARGET_GNOME=$3;
TARGET_NAME=$(basename $TARGET_GNOME | rev | cut -d"." -f2- | rev);
OUT_DIR=${4%/};

##################################################
# Outputs
##################################################

GTDB_MATCHES="$OUT_DIR/gtdb_matches.tsv"
GTDB_QUERY="$OUT_DIR/gtdb_query_genomes"
mkdir -p $GTDB_QUERY

##################################################
# Get GTDB Matches
##################################################

# remove possible matches to self
awk \
'$4 !~ /1.0/' \
$GTDB_DIR/gtdbtk.ani_summary.tsv |
grep "$TARGET_NAME" \
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
done < <(cut -f2 $GTDB_MATCHES);
