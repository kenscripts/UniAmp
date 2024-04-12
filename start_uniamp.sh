#! /bin/bash

# link (source)
#https://ss64.com/bash/source.html

# remove forward slash in argument 
#https://stackoverflow.com/questions/9018723/what-is-the-simplest-way-to-remove-a-trailing-slash-from-each-parameter
export UNIAMP_PATH=${1%/};

# export paths to scripts
export PATH=$UNIAMP_PATH/scripts/:$PATH;

# export paths to binaries
export DATASETS_PATH="$UNIAMP_PATH/bin/datasets";
export JQ_PATH="$UNIAMP_PATH/bin/jq";
export RNAMMER_PATH="$UNIAMP_PATH/bin/rnammer-1.2/rnammer" ;
export NUCMER_PATH="$UNIAMP_PATH/bin/nucmer";
export SHOWCOORDS_PATH="$UNIAMP_PATH/bin/show-coords";
export BEDTOOLS_PATH="$UNIAMP_PATH/bin/bedtools";
export BLASTN_PATH="$UNIAMP_PATH/bin/blastn";
export USEARCH_PATH="$UNIAMP_PATH/bin/usearch_v11";
export BIOAWK_PATH="$UNIAMP_PATH/bin/bioawk";
export TAXONKIT_PATH="$UNIAMP_PATH/bin/taxonkit";
export EDIRECT_PATH="$UNIAMP_PATH/bin/edirect";

# export paths to databases
export TAXONKIT_DB="$UNIAMP_PATH/lib/ncbi_taxdump/";
