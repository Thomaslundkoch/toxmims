#!/bin/bash

#Remove the proteins with TM domains and create secretome_v2.fa
../../../scripts/03b_tm.sh

cd Uniprot
../../../scripts/04_remove_enzymes.sh
cd ..
