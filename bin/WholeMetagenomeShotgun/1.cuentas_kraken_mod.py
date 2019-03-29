#!/usr/bin/env python
# Usage python 1.cuentas_kraken_mod.py <input_table>

import sys

filein = open(sys.argv[1], 'r')
filein_fp = sys.argv[1]
parts = filein_fp.rsplit('.', 1)
fileout_fp = parts[0] + '_parsed.txt'
fileout = open(fileout_fp, 'w')


for line in filein:
    # Skip it read is unclassified
    if line.startswith('U'):
        continue
    else:
        line0 = line.rstrip('\n')
        line0 = line0.split('\t')

        # Store ID assigned to read
        ReadID = line0[0]
        Kdata = line0[4]
        Kdata = Kdata.split(' ')

        # Go through data
        total_count = 0
        agrees = 0
        disagrees = 0
        for item in Kdata:
            item = item.split(':')
            KmerID = item[0]
            KmerCount = int(item[1])
            if KmerID == ReadID:
                total_count = total_count + KmerCount
                agrees = agrees + KmerCount
#            else:
#                total_count = total_count + KmerCount
#                disagrees = agrees + KmerCount

        # Create percentage for the line
        positives = (agrees * 100) / float(total_count)
        negatives = 100 - positives
        fileout.write('%s\t%s\t%s\n' % (line, positives, negatives))

filein.close()
fileout.close()
