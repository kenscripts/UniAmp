# Description
UniAmp (Unique Amplicon) is a pipeline that can be used to generate primers complementary to a unique sequence in a reference genome.

The UniAmp pipeline can be conceptually split into 4 parts:
1. Build directory of query genomes.
2. Retrieve unique sequences in a reference genome compared to query genomes.
3. Select 1 unique reference sequence for primer design.
4. Design primers to unique reference sequence.

# Overview



# Dependencies
The UniAmp pipeline is composed of bash wrapper scripts around public bioinformatic software. 

UniAmp uses the following software:
## Optional
datasets
RNAmmer
gtdb-tk

## Required
nucmer
bedtools
blastn
usearch

If you use the UniAmp wrapper scripts, please cite the corresponding software.


# Installation
git clone

Set following variables:
NUCMER_PATH=
BEDTOOLS_PATH=
BLASTN_PATH=
USEARCH_PATH=


# Usage
For one example of how to use the UniAmp pipeline, see "uni_amp.workflow.txt". This workflow was used in the publication XXX to design strain-specific primers to bacterial isolates.

The following is a walkthrough of the UniAmp pipeline.


*** mention script names and what they do
## Set paths
## Build directory of query genomes
## Retrieve unique sequences
pairwise alignment
unique genomic intervals
## Select 1 unique reference sequence
## Primer-BLAST
## Get primer info
