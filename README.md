# M.-tuberculosis-Gene-Categories-PAML
Detection of Positive Selection Sites in M. tuberculosis Gene Categories

# Introduction
Evidence of positive selection in a protein's amino acid sequence is generally assessed by comparing the nonsynonymous rate (dN) with the synonymous rate (dS)(Kimura 1977, Miyaga & Yasunaga 1980). When the rate ratio 

• ω = dN/dS > 1, the nonsynonymous rate is greater than the synonymous rate and this is interpreted as evidence for the action of positive selection. 

• Purifying selection is inferred when ω<1, 

• whereas neutral evolution is assumed when ω = 1

PAML (Yang Z. 2007) is widely used in the molecular evolution community, and its branch-site models can be used to detect evidence of positive selection that acted on a particular branch or set of branches


# What can I find in this repository?
In this repository, you will find step-by-step guidelines for reproducing the results in the CODEML protocol (Dekhil N & Mardassi H, 2023). Genes carrying SNPs were grouped according to the different classes of gene categories based on the classification of Tuberculist (Lew et al., 2011). For each gene category, a single file was created containing the concatenated sequences of all genes in that category. These files were used as input, for a branch-site analysis using CODEML as implemented in the PAML v4.10.6 package (Yang 2007).

# References
If you use any of the code we provide in this GitHub repository or consult the protocol for your own analyses, please cite:




