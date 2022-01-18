#!/usr/bin/python3

import sys
nohead = sys.argv[1]
starts = sys.argv[2]

keep = ''
list_of_keep = []

with open(nohead, 'r') as fhand:
    title = ''
    for line in fhand:
        line_strip = line.rstrip()
        line_content = line_strip.split('#')
        if line_content[0] == title:
            continue
        else:
            title = line_content[0]
            replaced = line_strip.replace('[','\[').replace(']','\]')
            keep += f'{replaced}\n'
            list_of_keep.append(line.strip())

fastas = ''
signal_peptides = ''
mature_peptides = ''

with open(starts,'r') as infile:
    keep = False
    for line in infile:
        line = line.rstrip()
        if keep:
            fastas += f'{line}\n'
            signal_peptides += f'{line[0:20]}\n'
            mature_peptides += f'{line[20:]}\n'
            keep = False
        if line.startswith('>'):
            #print(line[1:])
            if line[1:] in list_of_keep:
                fastas += f'{line}\n'
                signal_peptides += f'{line}\n'
                mature_peptides += f'{line}\n'
                keep = True

with open('output_precursor.fa', 'w') as outfile:
    outfile.write(fastas)
with open('output_signalpeptides.fa', 'w') as outfile:
    outfile.write(signal_peptides)
with open('output_mature.fa', 'w') as outfile:
    outfile.write(mature_peptides)
