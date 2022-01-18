#!/bin/bash

mmseqs easy-search Uniprot_*.fasta ../secretome_v2.fa mmseq_results.res tmp

cut -f 2 mmseq_results.res | sort | uniq > enzymes.seq
grep '>' ../secretome_v2.fa | cut -d '>' -f 2 > secretome_entries.seq

cat enzymes.seq secretome_entries.seq | sort | uniq -c | grep -v ' 2 '| cut -d ' ' -f 5 > non_enzymes.seq

grep -A1 -F -f non_enzymes.seq ../secretome_v2.fa | grep -v '--' "^--$" > ../secretome_v3.fa
