#! /bin/bash

SC_GNOMES=$1
WD=$2

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

printf "\n>>> Making syncom directory\n"

for REF_GNOME in $(ls $SC_GNOMES/*.fna);
do
  # get name of referene genome file
  REF_NAME=$(basename $REF_GNOME | rev | cut -d"." -f2- | rev);
  printf "\n%s" "$REF_NAME";

  # make working directories
  REF_DIR="$WD/$REF_NAME";
  QUERY_DIR="$REF_DIR/syncom_queries";
  mkdir -p $QUERY_DIR;

  # copy reference genome to main directory
  cp $REF_GNOME $REF_DIR;

  # copy syncom genomes to query subdirectory
  cp $SC_GNOMES/*.fna $QUERY_DIR;

  # remove reference genome from query subdirectory
  rm $QUERY_DIR/$REF_NAME.fna;
done

printf "\n\n"
