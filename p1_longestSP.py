#!/usr/bin/python3

import sys

infile = sys.argv[1]

keep = ''
list_of_keep = []

with open(infile, 'r') as fhand:
    title = ''
    for line in fhand:
        line_strip = line.rstrip()
        line_content = line_strip.split(']')
        if line_content[0] == title:
            continue
        else:
            title = line_content[0]
            replaced = line_strip.replace('[','\[').replace(']','\]')
            keep += f'{replaced}\n'
            list_of_keep.append(line.strip())

for element in list_of_keep:
    print(element)
