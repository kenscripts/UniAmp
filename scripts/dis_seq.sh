#! /bin/bash

COORS=$1
IDY=$2
GENOME=$3
QUERY_DIR=$4
WD_DIR=$(dirname $COORS)
OUTNAME=$(basename $COORS | cut -d"." -f1)
OUTPATH="$WD_DIR/$OUTNAME"

# use to check for empty lines
sequence_check(){
SEQIDS=$1
if [[ $(wc -l < $SEQIDS) -eq 0 ]]; 
then
echo "No sequences remaining";
exit;
fi
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

sleep 1
printf "\n>>> Running get_dseqs.sh\n\n"
sleep 1

get_dseqs.sh $COORS $IDY $GENOME

sequence_check <(grep ">" $OUTPATH.dseqs.fasta)

COUNT=$(grep -c ">" $OUTPATH.dseqs.fasta)
printf "Dissimilar sequences found: $COUNT\n"
sleep 1
grep ">" $OUTPATH.dseqs.fasta | sed 's/>//g'

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

sleep 1
printf "\n>>> Removing small sequences (<70 bp)\n\n"
sleep 1

fasta_contig_length.py -i $OUTPATH.dseqs.fasta |
awk '$2>70 {print $1}' \
> $OUTPATH.tmp

sequence_check $OUTPATH.tmp

extract_fastaseqs.py \
-z \
-i $OUTPATH.dseqs.fasta \
-f $OUTPATH.tmp \
> $OUTPATH.dseqs_v2.fasta

sleep 1
grep ">" $OUTPATH.dseqs_v2.fasta | sed 's/>//g'
sleep 1

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

sleep 1
printf "\n>>> Running local_blastn.sh\n\n"
sleep 1

# self blast to find duplicated sequences
local_blastn.sh \
$OUTPATH.dseqs_v2.fasta \
$GENOME \
> $OUTPATH.dseqs_v2.localblastn.tsv;

# blast against query to find common sequences
local_blastn.sh \
$OUTPATH.dseqs_v2.fasta \
<(cat $(find $QUERY_DIR -maxdepth 1 -type f )) \
>> $OUTPATH.dseqs_v2.localblastn.tsv;

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

sleep 1
printf ">>> Removing duplicated sequences\n\n"
sleep 1

local_unique.sh \
$OUTPATH.dseqs_v2.localblastn.tsv \
> $OUTPATH.tmp

sequence_check $OUTPATH.tmp

extract_fastaseqs.py \
-z \
-i $OUTPATH.dseqs_v2.fasta \
-f $OUTPATH.tmp \
> $OUTPATH.dseqs_v3.fasta 

sleep 1
grep ">" $OUTPATH.dseqs_v3.fasta | sed 's/>//g'
sleep 1

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

sleep 1
printf "\n>>> Running remote_blastn.sh\n\n"
sleep 1

for SEQ in $(grep ">" $OUTPATH.dseqs_v3.fasta | sed 's/>//g');
do
remote_blastn.sh \
<(
extract_fastaseqs.py \
-z \
-i $OUTPATH.dseqs_v3.fasta \
-d $SEQ \
2> $OUTPATH.err.log \
) >> $OUTPATH.dseqs_v3.remoteblastn.tsv;
remote_matches.sh \
<(echo ">$SEQ") \
<(grep "$SEQ" $OUTPATH.dseqs_v3.remoteblastn.tsv) |
tee -a $OUTPATH.dseqs_v3.remotematches.tsv;
done

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

sleep 1
printf "\n>>> Removing non-unique sequences (> 25 matches)\n\n"
sleep 1

awk \
'$2<25 {print $1}' \
$OUTPATH.dseqs_v3.remotematches.tsv \
> $OUTPATH.tmp

sequence_check $OUTPATH.tmp

extract_fastaseqs.py \
-z \
-i $OUTPATH.dseqs_v3.fasta \
-f $OUTPATH.tmp \
> $OUTPATH.dseqs_v4.fasta \

sleep 1
grep ">" $OUTPATH.dseqs_v4.fasta | sed 's/>//g'

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

rm $OUTPATH.tmp
