#! /bin/bash

# link (source)
#https://ss64.com/bash/source.html

# remove forward slash in argument 
#https://stackoverflow.com/questions/9018723/what-is-the-simplest-way-to-remove-a-trailing-slash-from-each-parameter
export UNIAMP_PATH=${1%/}

# make files executable
chmod u+x $UNIAMP_PATH/scripts/*
chmod u+x $UNIAMP_PATH/bin/*

# add scripts to path
export PATH=$UNIAMP_PATH/scripts/:$PATH

# export paths of bins
export DATASETS_PATH="$UNIAMP_PATH/bin/datasets"
# modifying rnammer file
#https://www.biostars.org/p/9550142/
export RNAMMER_PATH="$UNIAMP_PATH/bin/rnammer-1.2/" 
export NUCMER_PATH="$UNIAMP_PATH/bin/nucmer"
export BEDTOOLS_PATH="$UNIAMP_PATH/bin/bedtools"
export BLASTN_PATH="$UNIAMP_PATH/bin/blastn"
export USEARCH_PATH="$UNIAMP_PATH/bin/usearch_v11"
export BIOAWK_PATH="$UNIAMP_PATH/bin/bioawk"
