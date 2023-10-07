# Overview
UniAmp (Unique Amplicon) is a pipeline used to generate primers complementary to a unique sequence in a reference genome.  \
\
The UniAmp pipeline can be conceptually split into 4 parts:
1. Build directory of query genomes.
2. Retrieve unique sequences in a reference genome compared to query genomes.
3. Select unique reference sequence for primer design.
4. Design primers to unique reference sequence.

### Visual representation:
![UniAmp](https://github.com/kenscripts/UniAmp/blob/main/UniAmp.v2.png)

# Dependencies
The UniAmp pipeline is composed of bash wrapper scripts around public bioinformatics software.  \
\
Besides basic Linux utilities and Python, the following software is implemented in the UniAmp pipeline:  \
(Optional)  \
[datasets](https://www.ncbi.nlm.nih.gov/datasets)  \
[RNAmmer](https://services.healthtech.dtu.dk/service.php?RNAmmer-1.2)  \
[GTDB-tk](https://github.com/Ecogenomics/GTDBTk)  \
\
(Required)  \
[nucmer](https://sourceforge.net/projects/mummer/)  \
[bedtools](https://github.com/arq5x/bedtools2)  \
[blastn](https://www.ncbi.nlm.nih.gov/books/NBK52640/)  \
[usearch](https://drive5.com/usearch/download.html)  \
[bioawk](https://github.com/lh3/bioawk)

# Installation
Download repository from Github:  \
`git clone https://github.com/kenscripts/UniAmp.git`  \
\
Run the following script and specify UniAmp path:  \
`source ./uniamp_setup.sh <path to UniAmp>` 
# Usage
For one example of how to use the UniAmp pipeline, see "uni_amp.workflow.txt". This was the workflow used in the original UniAmp publication for designing strain-specific primers to bacterial isolates.  \
\
The following is a walkthrough of the UniAmp pipeline.
### Set bash variables
Create bash variables for dependencies by running setup script as described above under "Installation".
\
### Build directory of query genomes
To find unique reference sequences, the reference genome is compared to query genomes. This step controls how unique the reference sequences can be. For example, if a synthetic community of organisms is being studied, then only the genomes of these community members can be used as queries. However, if a high level of uniqueness is desired for unique reference sequences then many query genomes can be used. \
\
At this step, the following scripts can be implemented:  \
```
get_gtdb_queries.sh <GTDB_DIR> <REF_GNOME> <OUT_DIR>

Description:
retrieves genomes of ani_rep to use as query genomes

Arguments:
GTDB_DIR directory containing GTDB-tk output
REF_GNOME filename for reference genome sequence
OUT_DIR directory for output

Dependencies:
None, just need output from GTDB-tk
```
\
`get_gtdb_queries.sh`  \
Description***: Parses output from GTDB-tk using reference genome to retrieve similiar query genomes \
***Inputs***: GTDB-tk output directory, reference genome path, output directory  \
***Dependencies***: None. Just need output from GTDB-tk using reference genome.  \
### Retrieve unique sequences
Once a directory with query genomes is assembled the following script is implemented:  \
`uni_seq.sh`  \
***Description***: Performs pairwise genome alignments between reference genome and each query genome (nucmer). From these alignments, unique reference genome intervals are found and used to extract unique reference sequences (bedtools). Small sequences (< 100 bp) are removed and local alignments (blastn) are performed to return only single-copy, unique reference sequences.  \
***Inputs***: reference genome path, query genome directory, output directory  \
***Main Outputs***: uni_seq.sc.fasta and other intermediary files \
***Dependencies***: nucmer, bedtools, bioawk
### Select unique reference sequence
The output from `uni_seq.sh` can produced many unique reference sequences. This depends on how many query genomes were compared and how similiar these query genomes were to the reference genome.  \
\
For the later steps in the UniAmp pipeline, unique reference sequences are manually entered in the online graphical interface of Primer-BLAST. As a result, it is convienent to only have 1 or a few unique reference sequences to use.  \
\
To accomplish this, selection criteria can be imposed to select the most optimal unique reference sequence based on the user's preference. In the original UniAmp publication, sequences with a size of 150-250 bp and GC content of 40-60 % were selected. The remaining unique reference sequences were than aligned against the NCBI nucleotide collection database. The unique reference sequence with the least amount of matches was used for primer design.
### Primer-BLAST
Once a unique reference sequence is selected, this sequence is uploaded to the Primer-BLAST server (https://www.ncbi.nlm.nih.gov/tools/primer-blast/). Presently, no command-line tool exists for Primer-BLAST so the Primer-BLAST html output is saved and used in the next step. 
### Tabulate primer pair info
The following script is implemented using Primer-BLAST output:  \
`uni_pcr.sh`  \
***Description***: First, html output from Primer-BLAST is parsed. Then, in-silico PCR is performed (usearch) on reference genome to determine the number of reference amplicons generated for each primer pair. In-silico PCR is also performed on query genome(s) as one final check for unique reference genome amplicons.  \
***Inputs***: Primer-BLAST html output, text file containing query paths, reference genome path  \
***Main Outputs***: \*uni_pcr.tsv, \*.ispcr.tsv \
***Dependencies***: nucmer, bedtools
