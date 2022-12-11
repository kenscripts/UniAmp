# Overview
UniAmp (Unique Amplicon) is a pipeline used to generate primers complementary to a unique sequence in a reference genome. \
\
\
The UniAmp pipeline can be conceptually split into 4 parts: \
1. Build directory of query genomes. \
2. Retrieve unique sequences in a reference genome compared to query genomes. \
3. Select 1 unique reference sequence for primer design. \
4. Design primers to unique reference sequence. \
\
\
Visual representation: \
\
![UniAmp](https://github.com/kenscripts/UniAmp/blob/main/UniAmp.v2.png) \
\
\
# Dependencies
The UniAmp pipeline is composed of bash wrapper scripts around public bioinformatic software. \
\
\
The following software is implemented in the UniAmp pipeline: \
\
(Optional) \
[datasets](https://www.ncbi.nlm.nih.gov/datasets) \
[RNAmmer](https://services.healthtech.dtu.dk/service.php?RNAmmer-1.2) \
[GTDB-tk](https://github.com/Ecogenomics/GTDBTk) \
\
(Required) \
[nucmer](https://sourceforge.net/projects/mummer/) \
[bedtools](https://github.com/arq5x/bedtools2) \
[blastn](https://www.ncbi.nlm.nih.gov/books/NBK52640/) \
[usearch](https://drive5.com/usearch/download.html) \
\
If you use the UniAmp wrapper scripts, please cite the corresponding software. \
\
# Installation
Download repository from Github: \
`git clone https://github.com/kenscripts/UniAmp.git` \
\
Make scripts executable: \
`chmod a+x ./UniAmp/scripts/*` \
\
Set following bash variables: \
`DATASETS_PATH=<path to datasets>` \
`RNAMMER_PATH=<path to rnammer>` \
`GTDBTK_PATH=<path to gtdb-tk>` \
`NUCMER_PATH=<path to nucmer>` \
`BEDTOOLS_PATH=<path to bedtools>` \
`BLASTN_PATH=<path to blastn>` \
`USEARCH_PATH=<path to usearch>` \
\
\
# Usage
For one example of how to use the UniAmp pipeline, see "uni_amp.workflow.txt". This workflow was used in the publication XXX to design strain-specific primers to bacterial isolates. \
\
The following is a walkthrough of the UniAmp pipeline. \
\
\
*** mention script names and what they do
## Set paths
## Build directory of query genomes
## Retrieve unique sequences
pairwise alignment
unique genomic intervals
## Select 1 unique reference sequence
## Primer-BLAST
## Get primer info
