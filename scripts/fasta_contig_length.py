#!/usr/bin/env python

import argparse
import sys
import re


parser = argparse.ArgumentParser(
                                 description = "Find lengths of contigs in fasta file."
                                 )
parser.add_argument(
                    "-i",
                    "--fasta",
                    action = "store",
                    dest = "IN_FASTA",
                    help = "Fasta with sequences."
                    )
ARGS = parser.parse_args()


def parse_fasta(FASTA_FILE):
   with open(FASTA_FILE,"r") as FASTA_HANLDE:
      FASTA = FASTA_HANLDE.read().strip("\n")
      SEQ_D = {}
      if "\n\n>" in FASTA:
         SEQ_L = FASTA.split("\n\n") 
      else: 
         NEW_FASTA = FASTA.replace("\n>","\n\n>")
         SEQ_L = NEW_FASTA.split("\n\n") 
      for SEQ_INFO in SEQ_L:
         ID,SEQ = SEQ_INFO.split("\n",1)
         SEQ_D[ID.strip(">")] = SEQ.replace("\n","")

      return SEQ_D

def contig_length(SEQ_D):
   for SEQ_ID in sorted(SEQ_D.keys()):
      HEADER = re.search(
                         "^\S+",
                         SEQ_ID
                         ).group().strip("(),")
      LSEQ = len(SEQ_D[SEQ_ID])
      print(
            "%s\t%s" % (
                        HEADER,
                        LSEQ
                        )
            )
       

SEQ_D = parse_fasta(ARGS.IN_FASTA)
contig_length(SEQ_D)
