#! /bin/bash

UNIFASTA=$1
REMOTEBLAST=$2

# search for matches with percent identity and coverage > 50%
# 50 % is a more stricter threshold; helps to identify really unique sequences
for SEQ in $(grep ">" $UNIFASTA | sed 's/>//g')
do
  paste \
  <(echo $SEQ) \
  <(
    grep \
    -c "$SEQ" \
    <(awk -v OFS="\t" '$5>50 && $6>50' $REMOTEBLAST) \
  );
done
