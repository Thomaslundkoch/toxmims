#!/bin/bash

cat Protein/protein_secretome.fa Transcriptome/transcriptome_secretome.cdhit.fa > tmp

cd-hit -i tmp -o secretome_v1.fa -c 0.99
rm tmp
