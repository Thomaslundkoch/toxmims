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
# COULD BE A PROBLEMATIC STEP!!
cut -f 1 ../$file |cut -d ' ' -f 1 > transcriptome_renamed.nt.fa

#Translate into ORFs of at least 30aa in length
getorf -sequence transcriptome_renamed.nt.fa -outseq orfs.fa -minsize 90

#Custom python program, that identifies all the potential start sites for the different ORFs
python ../stats/starts.py -t prot orfs.fa > orfs.starts.fa

mkdir signalp
cd signalp

#Predict the sequences with signal peptides
signalp -fasta ../orfs.starts.fa -gff3

cd ..

#Identify the sequences with a signal peptide and remove the gff3-header
cut -f 1 signalp/orfs.starts.gff3 | grep -v '##' > sp_redundant.seq

#Custom python script that only extract the longest precursor with a signal peptide in the ORFs
python ../find_secreted.py sp_redundant.seq orfs.starts.fa

#Remove redundant sequences with cd-hit
cd-hit -i output_mature.fa -o output_mature.cdhit.fa -c 0.99


cd ..
