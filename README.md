# Overview
UniAmp (Unique Amplicon) is a computational pipeline to generate PCR primers specific to a target genome.  \
\
The UniAmp pipeline can be conceptually split into 4 parts:
1. Build directory of query genomes with high sequence similarity to target genome.
2. Retrieve unique sequences in a target genome compared to query genomes.
3. Select unique target sequence for primer design.
4. Design primers to unique target sequence.


### Visual representation:
![UniAmp](https://github.com/kenscripts/UniAmp/blob/main/docs/UniAmp.v2.png)


# Dependencies
UniAmp is run on Linux and requires basic Linux utilities, python3, and perl.  \
\
UniAmp contains wrappers around public bioinformatics software. The following dependencies are included with UniAmp as binaries in the `bin` folder and do not need to be installed:  \
* [nucmer](https://sourceforge.net/projects/mummer/)  \
* [bedtools](https://github.com/arq5x/bedtools2)  \
* [bioawk](https://github.com/lh3/bioawk)
* [usearch](https://drive5.com/usearch/download.html)  \
* [blastn](https://www.ncbi.nlm.nih.gov/books/NBK52640/)  \
* [taxonkit](https://github.com/shenwei356/taxonkit)  \
* [datasets](https://www.ncbi.nlm.nih.gov/datasets)  \
* [RNAmmer](https://services.healthtech.dtu.dk/service.php?RNAmmer-1.2)\*  \
* [edirect](https://www.ncbi.nlm.nih.gov/books/NBK179288/)

\* To implement rnammer in UniAmp scripts, the `rnammer` script included with UniAmp was modified as described [here](https://www.biostars.org/p/9550142/). `rnammer` also requires the HMMER2 command `hmmsearch`, so the binary for this command is included in the UniAmp `bin` folder. \
\* rnammer requires the perl `XML::Simple` module. If not already installed, the module can be installed using the command `cpan install XML::Simple`. 


# Installation
Download repository from Github:  \
`git clone https://github.com/kenscripts/UniAmp.git`  \
\
Run the following script and specify UniAmp path:  \
`source <path to UniAmp>/UniAmp/setup_uniamp.sh <path to UniAmp>`


# Usage
For specific examples on how to use the UniAmp pipeline, see `*.workflow.txt` files in the `docs` folder. These files show the process for designing strain-specific primers to different bacteria.  \
\
The following is a general walkthrough of the UniAmp pipeline:
### Set up UniAmp scripts and dependencies
Before running UniAmp scripts, execute the following script and specify the path to UniAmp:  \
`source ./uniamp_setup.sh <path to UniAmp>`


### Build directory of query genomes with high sequence similarity to target genome
The target genome is compared to query genomes to find unique target sequences. This step controls how unique the target sequences can be. For example, if a synthetic community of organisms is being studied, then only the genomes of these community members can be used as queries. However, if a high level of uniqueness is desired for unique target sequences then the user should compare query genomes with high sequence similarity to target genome.  \
\
Below are some optional UniAmp scripts to obtain query genomes with high sequence similarity to a target genome:
```
get_gtdb_queries.sh <GTDBTK_DATA_PATH> <GTDB_DIR> <TARGET_GNOME> <OUT_DIR>

Description:
retrieves query genomes from GTDB-tk ani_rep output that match target genome sequence

Arguments:
<GTDBTK_DATA_PATH> = path to GTDB-tk reference data
<GTDB_DIR> = directory containing GTDB-tk ani_rep output
<TARGET_GNOME> = filename of target genome sequence
<OUT_DIR> = directory for output

Dependencies:
output from GTDB-tk ani_rep
GTDB-tk reference data
``` 
```
get_ncbi_queries.sh <TARGET_GNOME> <TAXON> <OUT_DIR>

Description:
retrieves query genomes from NCBI of the specified taxon with > 97% 16S rRNA sequence identity to target genome sequence

Arguments:
<TARGET_GNOME> = filename of target genome sequence
<TAXON> = search for query genomes from a specific taxon
<OUT_DIR> = path for output directory

Dependencies:
datasets
rnammer
blastn
```
Note: If target genome sequence has previously been deposited into NCBI database then user should check the query genomes returned by `get_ncbi_queries.sh` to make sure target genome sequence is not present.


### Retrieve unique target sequences
Once a directory with query genomes is assembled the following script is implemented:
```
uni_seq.sh <TARGET_GNOME> <QUERY_DIR> <OUT_DIR>

Description:
finds unique sequences in target genome compared to query genomes by performing pw genome alignment then local alignment

Arguments:
<TARGET_GNOME> = path to target genome sequence
<QUERY_DIR> = path to directory containing query genomes
<OUT_DIR> = path to directory for output

Dependencies:
gnome_uniseq.sh:::nucmer
gnome_uniseq.sh:::show-coords
gnome_uniseq.sh:::bedtools
bioawk
local_uniseq.sh:::blastn
```


### Select unique target sequence
The output from `uni_seq.sh` can produced many unique target sequences. This depends on how many query genomes were compared and how similiar these query genomes were to the target genome.  \
\
For the later steps in the UniAmp pipeline, unique target sequences are uploaded to the web server of Primer-BLAST. As a result, it is convienent to only have 1 or a few unique target sequences to work with. To accomplish this, selection criteria can be imposed to select the most optimal unique target sequence based on the user's preference.  \
\
In the original UniAmp publication, unique target sequences were filtered by size and GC content. The remaining sequences were than compared against the NCBI nucleotide collection database. The unique target sequence with no match or with the lowest similarity to any database sequence was used for primer design. This approach can be implemented by performing the following:

1\) use bioawk to filter unique target sequences by size and gc content
```
# size: 400-800 bp
# gc: 40-60 %
$BIOAWK_PATH \
-c fastx \
'length($seq) > 400 && length($seq) <800 && gc($seq) < 0.60 && gc($seq) > 0.40 {print ">"$name"\n"$seq"\n"}' \
$UNISEQ_DIR/uni_seq.sc.fasta \
> $UNISEQ_DIR/uni_seq.filtered.fasta;
```
2\) compare unique target sequences against NCBI database and select most unique sequence
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


### Design primers using Primer-BLAST
Once a unique target sequence is selected, this sequence is uploaded to the Primer-BLAST server (https://www.ncbi.nlm.nih.gov/tools/primer-blast/). Presently, no command-line tool exists for Primer-BLAST so the Primer-BLAST html output is saved and used in the next step.  \
\
Users can select different Primer-BLAST parameters depending on their specific needs. Below are URLs containing previously used settings for designing bacterial strain-specific primers:  \
[Settings to design primers for end-point PCR](https://www.ncbi.nlm.nih.gov/tools/primer-blast/index.cgi?LINK_LOC=bookmark&OVERLAP_5END=7&OVERLAP_3END=4&PRIMER_PRODUCT_MIN=400&PRIMER_PRODUCT_MAX=800&PRIMER_NUM_RETURN=500&PRIMER_MIN_TM=57.0&PRIMER_OPT_TM=60.0&PRIMER_MAX_TM=63.0&PRIMER_MAX_DIFF_TM=3&PRIMER_ON_SPLICE_SITE=0&SEARCHMODE=0&SPLICE_SITE_OVERLAP_5END=7&SPLICE_SITE_OVERLAP_3END=4&SPLICE_SITE_OVERLAP_3END_MAX=8&SPAN_INTRON=off&MIN_INTRON_SIZE=1000&MAX_INTRON_SIZE=1000000&SEARCH_SPECIFIC_PRIMER=on&EXCLUDE_ENV=off&EXCLUDE_XM=off&TH_OLOGO_ALIGNMENT=off&TH_TEMPLATE_ALIGNMENT=off&ORGANISM=bacteria%20%28taxid%3A2%29&PRIMER_SPECIFICITY_DATABASE=nt&TOTAL_PRIMER_SPECIFICITY_MISMATCH=4&PRIMER_3END_SPECIFICITY_MISMATCH=1&MISMATCH_REGION_LENGTH=3&TOTAL_MISMATCH_IGNORE=6&MAX_TARGET_SIZE=4000&ALLOW_TRANSCRIPT_VARIANTS=off&HITSIZE=50000&EVALUE=30000&WORD_SIZE=7&MAX_CANDIDATE_PRIMER=500&PRIMER_MIN_SIZE=18&PRIMER_OPT_SIZE=22&PRIMER_MAX_SIZE=26&PRIMER_MIN_GC=40&PRIMER_MAX_GC=60&GC_CLAMP=0&NUM_TARGETS_WITH_PRIMERS=1000&NUM_TARGETS=20&MAX_TARGET_PER_TEMPLATE=100&POLYX=5&SELF_ANY=8.00&SELF_END=3.00&PRIMER_MAX_END_STABILITY=9&PRIMER_MAX_END_GC=5&PRIMER_MAX_TEMPLATE_MISPRIMING_TH=40.00&PRIMER_PAIR_MAX_TEMPLATE_MISPRIMING_TH=70.00&PRIMER_MAX_SELF_ANY_TH=45.0&PRIMER_MAX_SELF_END_TH=35.0&PRIMER_PAIR_MAX_COMPL_ANY_TH=45.0&PRIMER_PAIR_MAX_COMPL_END_TH=35.0&PRIMER_MAX_HAIRPIN_TH=24.0&PRIMER_MAX_TEMPLATE_MISPRIMING=12.00&PRIMER_PAIR_MAX_TEMPLATE_MISPRIMING=24.00&PRIMER_PAIR_MAX_COMPL_ANY=8.00&PRIMER_PAIR_MAX_COMPL_END=3.00&PRIMER_MISPRIMING_LIBRARY=AUTO&NO_SNP=off&LOW_COMPLEXITY_FILTER=on&MONO_CATIONS=50.0&DIVA_CATIONS=1.5&CON_ANEAL_OLIGO=50.0&CON_DNTPS=0.6&SALT_FORMULAR=1&TM_METHOD=1&PRIMER_INTERNAL_OLIGO_MIN_SIZE=18&PRIMER_INTERNAL_OLIGO_OPT_SIZE=20&PRIMER_INTERNAL_OLIGO_MAX_SIZE=27&PRIMER_INTERNAL_OLIGO_MIN_TM=57.0&PRIMER_INTERNAL_OLIGO_OPT_TM=60.0&PRIMER_INTERNAL_OLIGO_MAX_TM=63.0&PRIMER_INTERNAL_OLIGO_MAX_GC=80.0&PRIMER_INTERNAL_OLIGO_OPT_GC_PERCENT=50&PRIMER_INTERNAL_OLIGO_MIN_GC=20.0&PICK_HYB_PROBE=off&NEWWIN=off&NEWWIN=off&SHOW_SVIEWER=true)  \
[Settings to design primers for qPCR](https://www.ncbi.nlm.nih.gov/tools/primer-blast/index.cgi?LINK_LOC=bookmark&OVERLAP_5END=7&OVERLAP_3END=4&PRIMER_PRODUCT_MIN=75&PRIMER_PRODUCT_MAX=150&PRIMER_NUM_RETURN=500&PRIMER_MIN_TM=57.0&PRIMER_OPT_TM=60.0&PRIMER_MAX_TM=63.0&PRIMER_MAX_DIFF_TM=3&PRIMER_ON_SPLICE_SITE=0&SEARCHMODE=0&SPLICE_SITE_OVERLAP_5END=7&SPLICE_SITE_OVERLAP_3END=4&SPLICE_SITE_OVERLAP_3END_MAX=8&SPAN_INTRON=off&MIN_INTRON_SIZE=1000&MAX_INTRON_SIZE=1000000&SEARCH_SPECIFIC_PRIMER=on&EXCLUDE_ENV=off&EXCLUDE_XM=off&TH_OLOGO_ALIGNMENT=off&TH_TEMPLATE_ALIGNMENT=off&ORGANISM=bacteria%20%28taxid%3A2%29&PRIMER_SPECIFICITY_DATABASE=nt&TOTAL_PRIMER_SPECIFICITY_MISMATCH=4&PRIMER_3END_SPECIFICITY_MISMATCH=1&MISMATCH_REGION_LENGTH=3&TOTAL_MISMATCH_IGNORE=6&MAX_TARGET_SIZE=4000&ALLOW_TRANSCRIPT_VARIANTS=off&HITSIZE=50000&EVALUE=30000&WORD_SIZE=7&MAX_CANDIDATE_PRIMER=500&PRIMER_MIN_SIZE=18&PRIMER_OPT_SIZE=22&PRIMER_MAX_SIZE=26&PRIMER_MIN_GC=40&PRIMER_MAX_GC=60&GC_CLAMP=0&NUM_TARGETS_WITH_PRIMERS=1000&NUM_TARGETS=20&MAX_TARGET_PER_TEMPLATE=100&POLYX=5&SELF_ANY=8.00&SELF_END=3.00&PRIMER_MAX_END_STABILITY=9&PRIMER_MAX_END_GC=5&PRIMER_MAX_TEMPLATE_MISPRIMING_TH=40.00&PRIMER_PAIR_MAX_TEMPLATE_MISPRIMING_TH=70.00&PRIMER_MAX_SELF_ANY_TH=45.0&PRIMER_MAX_SELF_END_TH=35.0&PRIMER_PAIR_MAX_COMPL_ANY_TH=45.0&PRIMER_PAIR_MAX_COMPL_END_TH=35.0&PRIMER_MAX_HAIRPIN_TH=24.0&PRIMER_MAX_TEMPLATE_MISPRIMING=12.00&PRIMER_PAIR_MAX_TEMPLATE_MISPRIMING=24.00&PRIMER_PAIR_MAX_COMPL_ANY=8.00&PRIMER_PAIR_MAX_COMPL_END=3.00&PRIMER_MISPRIMING_LIBRARY=AUTO&NO_SNP=off&LOW_COMPLEXITY_FILTER=on&MONO_CATIONS=50.0&DIVA_CATIONS=1.5&CON_ANEAL_OLIGO=50.0&CON_DNTPS=0.6&SALT_FORMULAR=1&TM_METHOD=1&PRIMER_INTERNAL_OLIGO_MIN_SIZE=18&PRIMER_INTERNAL_OLIGO_OPT_SIZE=20&PRIMER_INTERNAL_OLIGO_MAX_SIZE=27&PRIMER_INTERNAL_OLIGO_MIN_TM=57.0&PRIMER_INTERNAL_OLIGO_OPT_TM=60.0&PRIMER_INTERNAL_OLIGO_MAX_TM=63.0&PRIMER_INTERNAL_OLIGO_MAX_GC=80.0&PRIMER_INTERNAL_OLIGO_OPT_GC_PERCENT=50&PRIMER_INTERNAL_OLIGO_MIN_GC=20.0&PICK_HYB_PROBE=off&NEWWIN=off&NEWWIN=off&SHOW_SVIEWER=true)


### Tabulate Primer-BLAST output and test specificity of primer pairs 

In the last step of the UniAmp pipeline, the Primer-BLAST html output is parsed and a text file is created. The specificity of these primers is then tested by performing in-silico PCR on a set of input genomes, containing the target genome as well as non-target genomes.  \
\
To perform in-silico PCR, a text file needs to be created containing the paths of the target genome and non-target genomes. This file can be created using the following shell command:
```
realpath <GNOME_DIR> > ispcr.gnome_paths.tsv

Argument:
<GNOME_DIR> = directory containing target genome and non-target genomes to test primer pair specificity
```
\
Once the text file containing paths to the target genome and non-target genomes is created, the following script can be implemented:
```
uni_pcr.sh <PB_HTML> <GNOME_PATHS> <TARGET_GNOME> <OUT_DIR>

Description:
parses primer blast output and uses primers to perform in-silico PCR on target and non-target genomes

Arguments:
<PB_HTML> = path to Primer-BLAST html output
<GNOME_PATHS> = path to file containing paths to target and non-target genome files
<TARGET_GNOME> = path to target genome sequence
<OUT_DIR> = path to output directory

Dependencies:
pb_parser.py:::BeautifulSoup4 python package
run_isPCR.sh:::usearch
```
