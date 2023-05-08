# Parsing FASTA files

# 1. Create an alternative reference by combining a FASTA with a vcf
Tunisian L4.3/LAM Raw data were deposited in the European Nucleotide Archive (Accession No. PRJEB39509), [skhairia A et al., 2021](https://doi.org/10.1016/j.ijid.2020.11.195).
VCF files from [Novoalign](https://www.novocraft.com/) are converted to FASTA using GATK [FastaAlternateReferenceMaker](https://gatk.broadinstitute.org/hc/en-us/articles/360037594571-FastaAlternateReferenceMaker)

# 2. GFF2FASTA
We used gff2fasta.pl to parse genomes into genes, using h37rv.gff3 as Reference.

# 3. Genes concatenation 
We concatenated all genes belonging to the same Gene Category together to obtain a concatenated FASTA file using in-house script concat.sh
