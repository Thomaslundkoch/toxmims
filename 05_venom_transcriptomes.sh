#!/bin/bash

for i in *.nt.fa;
do
  mkdir "$i".proc
  cd "$i".proc

  #Some of the names can become too long for singalp
  cut -f 1 ../$i |cut -d ' ' -f 1 > transcriptome_renamed.nt.fa

  getorf -sequence transcriptome_renamed.nt.fa -outseq orfs.fa -minsize 150

  cd-hit -i orfs.fa -o orfs.cdhit.fa -c 0.98

  #Custom python program, that identifies all the potential start sites for the different ORFs
  starts -t prot orfs.cdhit.fa > orfs.starts.fa

  #Test for size. If it is above 100 MB then split it into smaller segments of 100,000 fasta entries
  actualsize=$(wc -c < orfs.starts.fa)
  if [ $actualsize -ge 100000000 ]; then #100MB = 100000000
    #OVER maxmimum size
    mkdir chunks
    cd chunks

    #Split into smaller bites
    awk 'BEGIN {n=0;} /^>/ {if(n%100000==0){file=sprintf("chunk%d.fa",n);} print >> file; n++; next;} { print >> file; }' < ../orfs.starts.fa #100000

    for n in *.fa
    do
      #Split
      #Predict the sequences with signal peptides
      signalp6 --format txt --fastafile $n --output_dir "$n".signalp

      #Remove the single sequence outputs (some bug in the signalp6 code doesnt allow to have 'none' as an output)
      find "$n".signalp/. -name "*_plot.txt" -delete

      #Identify the sequences with a signal peptide and remove the gff3-header
      cut -f 1 "$n".signalp/output.gff3 | grep -v '##' > "$n".secreted.seq

      #Custom python script that only extract the longest precursor with a signal peptide in the ORFs
      grep -F -f "$n".secreted.seq $n | grep -v '--' "^--$"  | awk -F "]" '!_[$1]++' > "$n".secreted_nonred.seq
      grep -F -A1 -f  "$n".secreted_nonred.seq $n | grep -v '--' "^--$" > "$n".secreted.fa

      #Add sequences to master secretome
      cat "$n".secreted.fa >> ../secreted.fa
    done

    cd ..

    cat secreted.fa >> ../transcriptome_secretome.fa

    cd ..

  else
  #Predict the sequences with signal peptides
    signalp6 --format txt --fastafile orfs.starts.fa --output_dir signalp

    #Remove the single sequence outputs (some bug in the signalp6 code doesnt allow to have 'none' as an output)
    find signalp/. -name "*_plot.txt" -delete

    #Identify the sequences with a signal peptide and remove the gff3-header
    cut -f 1 signalp/output.gff3 | grep -v '##' > secreted.seq

    #only extract the longest precursor with a signal peptide in the ORFs
    grep -F -f secreted.seq orfs.starts.fa | grep -v '--' "^--$"  | awk -F "]" '!_[$1]++' > secreted_nonred.seq
    grep -F -A1 -f  secreted_nonred.seq orfs.starts.fa | grep -v '--' "^--$" > secreted.fa

    #Add sequences to master secretome
    cat secreted.fa >> ../transcriptome_secretome.fa

    cd ..
  fi

done

cd-hit -i transcriptome_secretome.fa -o transcriptome_secretome.cdhit.fa -c 0.98
