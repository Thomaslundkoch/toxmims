#!/bin/bash
#
# Extracts the secreted likely proteins from a transcriptome database in 'file'
#
# Note: created symlink from starts - symplinks should be the full path

file="$1"

#Create a folder for the output files and change into it
mkdir "$file"_secretome
cd "$file"_secretome

#Keep only the relevant part of the fasta-titles
#Maybe the deliminator should have several options ' ', '\t'
# COULD BE APOBLEMATIC STEP!!
cut -f 1 ../$file |cut -d ' ' -f 1 > transcriptome_renamed.nt.fa

#Translate into ORFs of at least 30aa in length
getorf -sequence transcriptome_renamed.nt.fa -outseq orfs.fa -minsize 90

#Custom python program, that identifies all the potential start sites for the different ORFs
starts -t prot orfs.fa > orfs.stars.fa

#Predict the sequences with signal peptides
signalp6 --format txt --fastafile orfs.stars.fa --output_dir signalp

#Remove the single sequence outputs (some bug in the signalp6 code doesnt allow to have 'none' as an output)
find signalp/. -name "*_plot.txt" -delete

#Identify the sequences with a signal peptide and remove the gff3-header
cut -f 1 signalp/output.gff3 > sp_redundant.seq
grep -v '##' sp_redundant.seq > sp_redundant_nohead.seq

#Custom python script that only extract the longest precursor with a signal peptide in the ORFs
find_secreted sp_redundant_nohead.seq orfs.stars.fa

#Remove redundant sequences with cd-hit
cd-hit -i output_mature.fa -o output_mature.cdhit.fa -c 0.99

# TODO
#
# 1. Create a wrapper script, that can loop over this one for multiple transcriptomes at once

cd ..
