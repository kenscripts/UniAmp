#! /bin/bash

# returns sequences that are not duplicated or similar \
# and that are not found in query;
# sequences are considered similar if:
# query coverage is > 75 % and percent identity is > 75 % 

BLASTN=$1

awk '$5>75 && $6>75 {print $1}' $BLASTN |
sort |
uniq -c |
awk '$1 == 1 {print $2}'
