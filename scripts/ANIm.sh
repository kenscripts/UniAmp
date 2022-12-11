#! /bin/bash


COOR=$1


tail -n +5 $COOR | awk '{sum +=$10} END {printf ("%.0f\n", sum/NR)}'


# Reference
##################################################
# Richter, M. and Rosselló-Móra, R., 2009.
# Shifting the genomic gold standard for the prokaryotic species definition.
# Proceedings of the National Academy of Sciences, 106(45), pp.19126-19131.
##################################################


# CODE NOT USED
# remove header from coordinate file
#tail -n +6 $COOR | 
# find total number of identical matches per alignment
#awk '{MATCH=$7*($10/100); printf ("%.0f\t%s\n",MATCH,$15)}' | 
# find total number of identical matches per contig
# link: https://www.unix.com/shell-programming-and-scripting/51129-column-sum-group-uniq-records.html
#awk '{arr[$2]+=$1} END {for (i in arr) {print i, arr[i]}}' 
