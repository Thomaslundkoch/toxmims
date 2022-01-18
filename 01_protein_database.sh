#!/bin/bash

protein_database="$1"

awk '/^>/ {printf("\n%s\n",$0);next; } { printf("%s",$0);}  END {printf("\n");}' < "$protein_database" | tail -n +2 | sed 's/ /_/g' > "$protein_database".oneline.fa
cd-hit -i "$protein_database".oneline.fa -o "$protein_database".oneline.cdhit.fa -c 0.95

#Predict the sequences with signal peptides
signalp6 --format txt --fastafile "$protein_database".oneline.cdhit.fa --output_dir signalp

#Remove the single sequence outputs (some bug in the signalp6 code doesnt allow to have 'none' as an output)
find signalp/. -name "*_plot.txt" -delete

#Identify the sequences with a signal peptide and remove the gff3-header
cut -f 1 signalp/output.gff3 | grep -v '##' > secreted.seq

#Get sequences
grep -A1 -F -f secreted.seq "$protein_database".oneline.cdhit.fa | grep -v '--' "^--$" > protein_secretome.fa
