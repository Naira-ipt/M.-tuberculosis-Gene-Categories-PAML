#!/bin/bash

#############################################################################################
#Before runing this script, create a folder for each gene category and adapt it to the script.
#Here is an example of "conserved hypothetical proteins" gene category.
#############################################################################################
for i in *.gene.fasta; do ./seqtk subseq $i hypothetic_list > hypothetic/$i.hypothetic.fasta ; done
cd hypothetic/
for file in *.FASTA.gene.fasta.hypothetic.fasta; do  sed -i "s/gene-/${file%%.*}_/" "$file"; done
#rm *.FASTA.gene.fasta
rename "s/FASTA.gene.fasta.hypothetic.fasta/hypothetic.fasta/" * 
for i in *.hypothetic.fasta; do cat $i | sed -e '1!{/^>.*/d;}' | sed  ':a;N;$!ba;s/\n//2g' > $i.hypoconcat.fasta;done
for i in *.hypoconcat.fasta; do sed -i "s/_Rv0025//" $i ; done
cat h37rv.hypothetic.fasta.hypoconcat.fasta ERR*.hypothetic.fasta.hypoconcat.fasta SRR*.hypothetic.fasta.hypoconcat.fasta TUN*.hypothetic.fasta.hypoconcat.fasta > L4_hypothetic.fasta

