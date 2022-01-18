#!/bin/bash

while read p;do
  grep -A1 "$p" rolani.orfs.stars.fa
done < test_output.seq
