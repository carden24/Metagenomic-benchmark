#!/usr/bin/perl
use strict;
use warnings;

###  PROGRAM THAT GENERATES SHUFFLED SEQUENCES FROM A FASTA FILE AND PARAMETERS OF K-MER SIZE AND STEP ###
###  Alejandra Escobar, UUSMB, IBt, UNAM
###  07/September/2017

scalar@ARGV == 3 || die "usage: $0 <file.fasta[file]> <kmer_size[int]> <step[int]>
";

my$file = $ARGV[0];
my$kmer_size = $ARGV[1];
my$step = $ARGV[2];

## Abriendo el archivo fasta
open FASTAOUT, (">shuffled_kmer$kmer_size\_step$step.fasta") or die ("I cannot create the output file\n");
my$id_seq;
my@guide_rand=();
my@shuffled_rand=();
my@nucs=("A", "T", "G", "C");
open (FASTA, $file) or die ("I cannot open the file $file\n");
while (<FASTA>) {
        chomp;
        if ($_ =~ /^>/){
		$id_seq=$_;
	}else{
		my$seq=$_;
		my$long=length$seq;
		for (my$i=1; $i<$long; $i=$i+$step){
                        my$coord_fin=$i+$kmer_size;
			if ($coord_fin<$long){
				my$word=substr($seq,$i,$kmer_size);
				push(@guide_rand, $word);
			}
		}
		my$tope=$long/$kmer_size;
		for (my$j=1; $j<=$tope; $j++){
			push @shuffled_rand, splice @guide_rand, rand @guide_rand, 1;
		}
		
		my$new_seq_rand=join("", @shuffled_rand);
		my$missing_nuc=$long-length$new_seq_rand;
		if ($missing_nuc>0){
			for (my$k=1; $k<=$missing_nuc; $k++){
				push(@shuffled_rand, $nucs[ rand @nucs ]);
			}
			$new_seq_rand=join("", @shuffled_rand);
                }
		print FASTAOUT "$id_seq SHUFFLED\n$new_seq_rand\n";
		@shuffled_rand=();
	}
}
close(FASTAOUT);

