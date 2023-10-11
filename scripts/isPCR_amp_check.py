#! /usr/bin/env python3

"""
Description:
checks if primer pairs will amplify templates by looking at 3'end mismatches

Usage:
isPCR_amp_check.sh <ISPCR_OUT>

Arguments:
<ISPCR_OUT> = path to output from usearch -search_pcr
"""

import sys
import re

ISPCR_TSV = open(sys.argv[1],"r")

IS_HEADER = True
for LINE in ISPCR_TSV:
   LINE = LINE.strip("\n")

   # add header to file
   if IS_HEADER:
      HEADER = (
                "genome_file\t"
                "contig_name\t"
                "contig_start\t" 
                "contig_end\t" 
                "contig_len\t" 
                "primer_1.name\t"
                "primer_1.strand\t"
                "primer_1.dot_aln\t" 
                "primer_2.name\t" 
                "primer_2.strand\t" 
                "primer_2.dot_aln\t" 
                "amplicon.len\t" 
                "amplicon.seq\t" 
                "primer_1.diffs\t" 
                "primer_2.diffs\t" 
                "pr_pair.diffs\t" 
                "primer_1.annealed\t" 
                "primer_2.annealed\t" 
                "pr_pair.amplified"
                )
      print(HEADER)
      IS_HEADER = False

   # counter
   FPR_AMP = True
   RPR_AMP = True
   PR_PAIR_AMP = True

   # primer last 3 bps
   FPR_SEQ = LINE.split("\t")[7][-3:]
   RPR_SEQ = LINE.split("\t")[10][-3:]

   # determine amplification
   # forward primer annealed
   if len(re.findall(r'[ATCG]',FPR_SEQ)) > 1:
      FPR_AMP = False
   # reverse primer annealed
   if len(re.findall(r'[ATCG]',RPR_SEQ)) > 1:
      RPR_AMP = False
   # primer pair amplification
   if (not FPR_AMP) or (not RPR_AMP):
      PR_PAIR_AMP = False

   # print results
   print(
         "%s\t%s\t%s\t%s" % (
                             LINE,
                             FPR_AMP,
                             RPR_AMP,
                             PR_PAIR_AMP
                             )
         )
  
ISPCR_TSV.close()
