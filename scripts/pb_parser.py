#! /usr/bin/env python3

"""
Description:
parses the html output from Primer-BLAST"

Usage:
pb_parser.py <PB_HTML>

Arguments:
<PB_HTML> = html output from Primer-BLAST
"""

import sys
from bs4 import BeautifulSoup
import re

# create bs object from primer blast html
HTML = open(sys.argv[1])
SOUP = BeautifulSoup(HTML,"html.parser")

# get unique sequence name
UNISEQ = SOUP.find(class_="paramSummary").find("dd").get_text()

# primer pair info under tag <div class = "prPairInfo">
# get info for all primer pairs using .find_all
PRPAIRS = SOUP.find_all(class_="prPairInfo")

# loop through info for each primer pair
HEADER_PRINTED = False
for PRPAIR in PRPAIRS:
   #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~     
   # get primer pair stats
   #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~     

   # primer pair number
   PRPAIR_NO = int(PRPAIR.a["name"]) + 1

   # pcr product length
   PRODUCT_LENGTH = PRPAIR.table.find_all("tr")[4].get_text().replace(
                                                                      "Product length",
                                                                      ""
                                                                      )

   # 3 rows for header, forward primer, and reverse primer
   TABLE_ROWS = PRPAIR.table.find_all("tr")[0:3]
   
   # get column headers from primer pair table
   if HEADER_PRINTED == False:
      PRPAIR_HEADER = "\t".join(
                                [COL.get_text()
                                 for COL in TABLE_ROWS[0]]
                                ).replace(" ","_")
      print(
            "%s\t%s\t%s\t%s\t%s%s%s\t%s" % (
                                            "Unique_sequence",
                                            "Primer_pair",
                                            "Amplicon_length",
                                            "Templates_found",
                                            "Templates_amplified",
                                            PRPAIR_HEADER.replace(
                                                                  "Sequence",
                                                                  "For_pr_seq"
                                                                  ),
                                            PRPAIR_HEADER.replace(
                                                                  "Sequence",
                                                                  "Rev_pr_seq"
                                                                  ),
                                            "Total_prpair_complementarity"
                                            )
            )
      HEADER_PRINTED = True

   # get primer stats
   # add forward and reverse primer stats into one line
   PRPAIR_STATS = []
   for ROW in TABLE_ROWS:
      PRPAIR_STATS = PRPAIR_STATS + [COL.get_text() for COL in ROW.find_all("td")]
   PRPAIR_INFO = "\t".join(PRPAIR_STATS)

   # get total primer pair complementarity
   # add for and rev primer complementarity scores 
   COMP_SCORE_IDX = [7,8,16,17]
   COMP_SCORE_STR = list(
                         map(
                             PRPAIR_INFO.split("\t").__getitem__,
                             COMP_SCORE_IDX
                             )
                         )
   TOT_PRCOM = sum(
                   [
                    float(SCORE_STR)
                    for SCORE_STR in COMP_SCORE_STR
                    ]
                   )

   #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~     
   # determine number of unintended organisms amplified
   #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~     

   # info for unintended matches under tag <div class = "hidden shown">
   MATCHES = PRPAIR.find(class_="hidden shown")

   # info for each organism begins with ">" character 
   # ">" turns into "&gt;" for some reason
   # tried find_all(text = ">") but did not work
   ORGANISMS = str(MATCHES).split("\n&gt;")[1:]
   NO_ORGANISMS = len(ORGANISMS)

   # determine if organisms are amplified
   # organism not amplified if forward or reverse primer missing
   # organism not amplified if one primer contains 2 mismatches in last 2bps
   # organism not amplified if one primer contains 3 mismatches in last 5bps
   AMPLIFIED_ORGANISMS = 0
   for ORGANISM in ORGANISMS:
      AMPLIFIED = False
      ORGANISM_HTML = BeautifulSoup(ORGANISM,"html.parser")
      for PRPAIR_PRODUCT in ORGANISM_HTML.find_all("pre"):
         # see if both forward and reverse primers match organism
         FORWARD = [LINE for LINE in PRPAIR_PRODUCT.get_text().split("\n") if "Forward" in LINE]
         REVERSE = [LINE for LINE in PRPAIR_PRODUCT.get_text().split("\n") if "Reverse" in LINE]
         if FORWARD and REVERSE:
            # if both primers are found then determine if they both amplify
            PRIMERS_AMPLIFIED = 0
            PRPAIR_TEMPLATES = [LINE for LINE in PRPAIR_PRODUCT.get_text().split("\n") if "Template" in LINE]
            # determine if each primer will amplify
            # conservative threshold: 2 mismatches in last 3 bps will not amplify
            for PR_TEMPLATE in PRPAIR_TEMPLATES:
               PR_LAST3BPS = re.split("\s+",PR_TEMPLATE)[2][-3:]
               if len(re.findall(r'[ATCG]',PR_LAST3BPS)) == 2:
                  continue
               else:
                  PRIMERS_AMPLIFIED += 1
            if PRIMERS_AMPLIFIED == 2:
               AMPLIFIED = True
      if AMPLIFIED == True:
         AMPLIFIED_ORGANISMS += 1
   print("%s\t%s\t%s\t%s\t%s\t%s\t%s" % (
                                         UNISEQ,
                                         "pr%s" % PRPAIR_NO,
                                         PRODUCT_LENGTH,
                                         NO_ORGANISMS,
                                         AMPLIFIED_ORGANISMS,
                                         PRPAIR_INFO,
                                         TOT_PRCOM
                                         )
         )

HTML.close()
