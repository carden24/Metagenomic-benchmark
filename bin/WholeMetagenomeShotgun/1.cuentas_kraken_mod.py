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
    line = line.rstrip('\n')
    line = line.rstrip(' ')

    if line.startswith('U'):
        continue

    else:
        line0 = line.split('\t')

        # Store ID assigned to read
        ReadID = line0[2]
        Kdata = line0[4]
        Kdata = Kdata.split(' ')

        # Go through data
        total_count = 0
        agrees = 0

        for item in Kdata:
            item2 = item.split(':')
            KmerID = item2[0]
            KmerCount = item2[1]

            # Skip when the "|:|" marker is found
            if KmerID == "|":
                continue

            else:
                total_count = total_count + int(KmerCount)
                if KmerID == ReadID:
                    agrees = agrees + int(KmerCount)
                else:
                    continue

        # Create percentage for the line
        positives = (agrees * 100) / float(total_count)
        negatives = 100 - positives
        fileout.write('%s\t%s\t%s\n' % (line, positives, negatives))

filein.close()
fileout.close()
