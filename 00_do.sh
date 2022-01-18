#!/bin/bash

# FOLDER STRUCTURE
# Aplysia
#   - Protein
#     - NCBI_*_protein.fasta
#   - Transcriptome
#     - XXX1.nt.fa
#     - XXX2.nt.fa
#   - Uniprot
#     - Uniprot_*.fasta
# Run from 'Aplysia' or 'Capitella folder'

# Create Protein/protein_secretome.fa
cd Protein
../../../../scripts/01_protein_database.sh NCBI_*_protein.fasta
cd ..

# Create Transcriptome/transcriptome_secretome.cdhit.fa
cd Transcriptome
../../../../scripts/02_transcriptome_database.sh
cd ..

# Create secretome_v1.fa
../../../scripts/03a_cat.sh

# MANUAL STEP to provide tmhmm.tsv
