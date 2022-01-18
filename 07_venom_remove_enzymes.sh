#!/bin/bash

uniprot_db="$1"

cd-hit -i "$uniprot_db" -o "$uniprot_db".cdhit.fa -c 0.9

blastp -query "$uniprot_db".cdhit.fa -subject venom_secretome_v2.fa -evalue 1e-10 -outfmt 6 > uniprot.blastp.res

cut -f 2 uniprot.blast.res | sort | uniq > enzymes.seq
grep '>' venom_secretome_v2.fa | cut -d '>' -f 2 > secretome_entries.seq

cat enzymes.seq secretome_entries.seq | sort | uniq -c | grep -v ' 2 ' > non_enzymes.seq

grep -A1 -F -f non_enzymes.seq venom_secretome_v2.fa > secretome_v3.fa
