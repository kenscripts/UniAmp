#! /bin/bash

GNOME_DIR=$1
WD=$2

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

printf "\n>>> Making genome directories\n"

for REF_GNOME in $(ls $GNOME_DIR/*);
do
  # get name of referene genome file
  REF_NAME=$(basename $REF_GNOME | rev | cut -d"." -f2- | rev);
  printf "\n%s" "$REF_NAME";

  # make working directories
  REF_DIR="$WD/$REF_NAME";
  QUERY_DIR="$REF_DIR/query_gnomes";
  mkdir -p $QUERY_DIR;

  # copy reference genome to main directory
  cp $REF_GNOME $REF_DIR;

  # copy syncom genomes to query subdirectory
  cp $GNOME_DIR/* $QUERY_DIR;

  # remove reference genome from query subdirectory
  rm $QUERY_DIR/$REF_GNOME;
done

printf "\n\n"
