#!/bin/bash

#Cannot get tmhmm2.0 to run - do it manually online, and download the results as tmhmm.tsv

grep 'PredHel=0' tmhmm.tsv | cut -f 1 > non_tm.seq
grep 'PredHel=1      ' tmhmm.tsv | grep -E 'Topology=[io][0-9]{1}-' | cut -f 1 >> non_tm.seq

grep -F -A1 -f  non_tm.seq venom_secretome.cdhit.fa | grep -v '--' "^--$" > venom_secretome_v2.fa
