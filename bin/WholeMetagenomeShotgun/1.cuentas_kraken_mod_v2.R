#!/usr/bin/env Rscript
#  1.cuentas_kraken_mod_vw.R  
#  Copyright 2017- E. Ernestina Godoy Lozano (tinagodoy@gmail.com)
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.
#


# This script looks originally written in Spanish by Ernestina. I have added
# some English annotations and made other changes to make it compatible with
# parsing it as a product of running kraken2 with paired reads
# Erick Cardenas Poire, March 2019


# This whole part looks that it was intended to be able to work when using files
# not located in the pwd. The variable "name" is not used later on.
# The output just uses the same format. Looks incomplete.

# Reads arguments
args = commandArgs(trailingOnly=TRUE)
directory_table = args[1]
num_split <- length(strsplit(directory_table, "/")[[1]])
nombre <- strsplit(directory_table, "/")[[1]][num_split]


kraken_table <- read.delim(directory_table, header=F)

for (i in 1:dim(kraken_table)[1]) {
  kamero <- kraken_table$V3[i] #TaxId assigned to the read
  
  # The fifth column contains the information used for scoring the reads based
  # on the individual reads. The information is a list of elements in the form
  # taxId:count. When using paired reads there is an additional field that
  # separates the Data from the read 1 and read 2 (|:|).
  
  # Store the list of kmer:counts
  lista <- strsplit(as.character(kraken_table$V5[i]), " ")[[1]]
  num <- length(lista)
  
  # Dataframe used for the positive results, the counts for kmers assignments
  # that agree with the read assignment
  df_pos <- data.frame(1)
  df_neg <- data.frame(1) # As above but for kmers that do not agree

  # Parse list of kmer:frequency
  cuenta_total = 0 # This is a new variable
  
  for (j in 1:num){
    #TaxId for the kmer assignment
    kam <- strsplit(as.character(lista[j]), ":")[[1]][1]
    cuenta <- as.numeric(strsplit(as.character(lista[j]), ":")[[1]][2])
    
    if (kam == "|") {
      # This deals with the "|:|" that separated the data from the two reads
      next
      } else {
        if (kam == kamero){
          
          # current Kmer agrees with Kmer assigned for read
          df2_pos <- cuenta
          df_pos <- rbind(df_pos, df2_pos)
          cuenta_total = cuenta_total + cuenta
          
          } else {
            
            # current Kmer does not agree with Kmer assigned for read
            df2_neg <- cuenta
            df_neg <- rbind(df_neg, df2_neg)
            cuenta_total = cuenta_total + cuenta
          }
      }
    }
  
  # The original script is intended for single reads,
  # each one containing 70 kmers.
  # Instead we keep track of the number of kmers used in the
  # "cuenta_total" variable
  
  kraken_table$pos[i] <- ((sum(df_pos)-1) / cuenta_total) * 100
  kraken_table$neg[i] <- ((sum(df_neg)-1) / cuenta_total) * 100
  
  # Cute progress message 
  print(paste("estoy haciendo el num de la lista ", i ,
              " con ", num, " kameros", sep=""))
}

# New line to have a variable output
outfile = paste0(nombre, '.out') 

#write.table(kraken_table, "kraken_conteo_kmer.out", quote=F, sep="\t", col.names=F, row.names=F)
write.table(kraken_table, outfile, quote=F, sep="\t", col.names=F, row.names=F)

print("DONE kmer counts!!")