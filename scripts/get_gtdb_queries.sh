#! /bin/bash

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
echo ""
echo "Description:"
echo "retrieves query genomes from GTDB-tk ani_rep output that match target genome sequence"

echo ""
echo "Usage:"
echo "get_gtdb_queries.sh <GTDBTK_DATA_PATH> <GTDB_DIR> <TARGET_GNOME> <OUT_DIR>"

echo ""
echo "Arguments:"
echo "<GTDBTK_DATA_PATH> = path to GTDB-tk reference data"
echo "<GTDB_DIR> = directory containing GTDB-tk ani_rep output"
echo "<TARGET_GNOME> = filename of target genome sequence"
echo "<OUT_DIR> = path to output directory"

echo ""
echo "Dependencies:"
echo "output from GTDB-tk ani_rep"
echo "GTDB-tk reference data"

echo ""
echo "Output:"
echo "gtdb_matches.tsv"
echo "gtdb_query_genomes"

echo ""
exit 1
fi

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
