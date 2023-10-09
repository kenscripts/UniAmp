# Overview
UniAmp (Unique Amplicon) is a pipeline used to generate primers complementary to a unique sequence in a reference genome.  \
\
The UniAmp pipeline can be conceptually split into 4 parts:
1. Build directory of query genomes.
2. Retrieve unique sequences in a reference genome compared to query genomes.
3. Select unique reference sequence for primer design.
4. Design primers to unique reference sequence.

### Visual representation:
![UniAmp](https://github.com/kenscripts/UniAmp/blob/main/docs/UniAmp.v2.png)


# Dependencies
The UniAmp pipeline is composed of bash wrappers around public bioinformatics software. These dependencies are included with UniAmp as binaries in the `bin` folder.  \
\
Besides basic linux utilities, python, and perl, the following software is implemented in the UniAmp pipeline:  \
[datasets](https://www.ncbi.nlm.nih.gov/datasets)  \
[RNAmmer](https://services.healthtech.dtu.dk/service.php?RNAmmer-1.2)\*  \
[taxonkit](https://github.com/shenwei356/taxonkit)  \
[nucmer](https://sourceforge.net/projects/mummer/)  \
[bedtools](https://github.com/arq5x/bedtools2)  \
[blastn](https://www.ncbi.nlm.nih.gov/books/NBK52640/)  \
[usearch](https://drive5.com/usearch/download.html)  \
[bioawk](https://github.com/lh3/bioawk)

\* To implement rnammer in UniAmp scripts, the `rnammer` script included with UniAmp was modified as described [here](https://www.biostars.org/p/9550142/). `rnammer` also requires the HMMER2 command `hmmsearch` so the binary for this command is included in the UniAmp `bin` folder. 


# Installation
Download repository from Github:  \
`git clone https://github.com/kenscripts/UniAmp.git`  \
\
Run the following script and specify UniAmp path:  \
`source ./uniamp_setup.sh <path to UniAmp>`  \
\
Download and unpack ncbi taxonomy in UniAmp lib directory:  \
`cd $UNIAMP_PATH/lib/ncbi_taxdump`  \
`wget https://ftp.ncbi.nlm.nih.gov/pub/taxonomy/taxdump.tar.gz`  \
`tar -xvf taxdump.tar.gz`


# Usage
For specific examples on how to use the UniAmp pipeline, see `*.workflow.txt` files in the `docs` folder. These files show the process for designing strain-specific primers to different bacteria.  \
\
The following is a general walkthrough of the UniAmp pipeline:

### Set bash variables
Create bash variables for dependencies by running setup script as described above under "Installation".

### Build directory of query genomes
To find unique reference sequences, the reference genome is compared to query genomes. This step controls how unique the reference sequences can be. For example, if a synthetic community of organisms is being studied, then only the genomes of these community members can be used as queries. However, if a high level of uniqueness is desired for unique reference sequences then many query genomes can be used. Below are some strategies to obtain query genomes with high sequence similarity to reference genome. \
\
At this step, the following scripts can be implemented:
```
get_gtdb_queries.sh <GTDBTK_DATA_PATH> <GTDB_DIR> <REF_GNOME> <OUT_DIR>

Description:
retrieves query genomes from GTDB-tk ani_rep output that match reference genome sequence

Arguments:
<GTDBTK_DATA_PATH> = path to GTDB-tk reference data
<GTDB_DIR> = directory containing GTDB-tk ani_rep output
<REF_GNOME> = filename of reference genome sequence
<OUT_DIR> = directory for output

Dependencies:
output from GTDB-tk ani_rep
GTDB-tk reference data
``` 
```
get_ncbi_queries.sh <REF_GNOME> <TAXON> <OUT_DIR>

Description:
retrieves query genomes from NCBI of the specified taxon with > 97% 16S rRNA sequence identity to reference genome sequence

Arguments:
<REF_GNOME> = filename of reference genome sequence
<TAXON> = search for query genomes from a specific taxon
<OUT_DIR> = path for output directory

Dependencies:
datasets
rnammer
blastn
```

### Retrieve unique reference sequences
Once a directory with query genomes is assembled the following script is implemented:
```
uni_seq.sh <REF_GNOME> <QUERY_DIR> <OUT_DIR>

Description:
find unique sequences in references compared to query genomes by performing pw genome alignment then local alignment

Arguments:
<REF_GNOME> = path to reference genome sequence
<QUERY_DIR> = path to directory containing query genomes
<OUT_DIR> = path to directory for output

Dependencies:
gnome_uniseq.sh:::nucmer
gnome_uniseq.sh:::show-coords
gnome_uniseq.sh:::bedtools
bioawk
local_uniseq.sh:::blastn
```

### Select unique reference sequence
The output from `uni_seq.sh` can produced many unique reference sequences. This depends on how many query genomes were compared and how similiar these query genomes were to the reference genome.  \
\
For the later steps in the UniAmp pipeline, unique reference sequences are uploaded to the web server of Primer-BLAST. As a result, it is convienent to only have 1 or a few unique reference sequences to use. To accomplish this, selection criteria can be imposed to select the most optimal unique reference sequence based on the user's preference.  \
\
In the original UniAmp publication, unique reference sequences were filtered by size and GC content. The remaining sequences were than compared against the NCBI nucleotide collection database. The unique reference sequence with no match or with the lowest similarity to any database sequence was used for primer design. This approach can be implemented by performing the following:

1\) use bioawk to filter unique reference sequences by size and gc content
```
# size: 400-800 bp
# gc: 40-60 %
$BIOAWK_PATH \
-c fastx \
'length($seq) > 400 && length($seq) <800 && gc($seq) < 0.60 && gc($seq) > 0.40 {print ">"$name"\n"$seq"\n"}' \
$UNISEQ_DIR/uni_seq.sc.fasta \
> $UNISEQ_DIR/uni_seq.filtered.fasta;
```
2\) compare unique reference sequences against NCBI database and select most unique sequence
```
get_remote_uniseq.sh <QUERY_FASTA> <BLASTDB> <TAXON> <OUT_DIR>

Description:
performs a remote blastn search and returns most unique query sequence

Arguments:
<QUERY_FASTA> = path for query fasta to use in blastn search
<BLAST_DB> = name of NCBI database to search against (e.g. nr)
<TAXON> = limit blastn search to specific taxon (used as entrez query for [organism])
<OUT_DIR> = path to output directory

Dependencies:
remote_blastn_lineage:::blastn
remote_blastn_lineage:::taxon
bioawk
```


### Primer-BLAST
Once a unique reference sequence is selected, this sequence is uploaded to the Primer-BLAST server (https://www.ncbi.nlm.nih.gov/tools/primer-blast/). Presently, no command-line tool exists for Primer-BLAST so the Primer-BLAST html output is saved and used in the next step. 

### Tabulate primer pair info
The following script is implemented using Primer-BLAST output:  \
`uni_pcr.sh`  \
***Description***: First, html output from Primer-BLAST is parsed. Then, in-silico PCR is performed (usearch) on reference genome to determine the number of reference amplicons generated for each primer pair. In-silico PCR is also performed on query genome(s) as one final check for unique reference genome amplicons.  \
***Inputs***: Primer-BLAST html output, text file containing query paths, reference genome path  \
***Main Outputs***: \*uni_pcr.tsv, \*.ispcr.tsv \
***Dependencies***: nucmer, bedtools
