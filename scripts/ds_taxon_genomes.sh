# /bin/bash


TAXON=$1
OUT_DIR=$2


# get accession for taxon complete genomes
datasets summary genome taxon $TAXON --refseq |
jq -r '.assemblies[].assembly | select(.assembly_level=="Complete Genome")' |
jq -r .assembly_accession > $OUT_DIR/ncbi_ds-$TAXON.acc


# download complete genomes
datasets download genome accession --inputfile $OUT_DIR/ncbi_ds-${TAXON}.acc --filename $OUT_DIR/ncbi_ds-${TAXON}.zip
