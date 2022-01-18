#!/bin/bash

tsa_folder="$1"
cd $tsa_folder

for i in *.nt.fa;
do
  mkdir "$i".proc
  cd "$i".proc

  cut -f 1 ../$i |cut -d ' ' -f 1 > transcriptome_renamed.nt.fa

  getorf -sequence transcriptome_renamed.nt.fa -outseq orfs.fa -minsize 150

  cd-hit -i orfs.fa -o orfs.cdhit.fa -c 0.99

  #Custom python program, that identifies all the potential start sites for the different ORFs
  starts -t prot orfs.cdhit.fa > orfs.starts.fa

# IF THE SIZE OF orfs.starts.fa IS TOO BIG, THEN SIGNALP CRASHES --> SPLIT IT INTO SMALLER SEGMENTS!!

  #Predict the sequences with signal peptides
  signalp6 --format txt --fastafile orfs.starts.fa --output_dir signalp

  #Remove the single sequence outputs (some bug in the signalp6 code doesnt allow to have 'none' as an output)
  find signalp/. -name "*_plot.txt" -delete

  #Identify the sequences with a signal peptide and remove the gff3-header
  cut -f 1 signalp/output.gff3 | grep -v '##' > secreted.seq

  #Custom python script that only extract the longest precursor with a signal peptide in the ORFs
  grep -F -A1 -f  secreted.seq orfs.starts.fa | grep -v '--' "^--$" > secreted.fa

  #Add sequences to master secretome
  cat secreted.fa >> ../venom_secretome.fa

  cd ..

done

cd-hit -i venom_secretome.fa -o venom_secretome.cdhit.fa -c 1

cd ..
