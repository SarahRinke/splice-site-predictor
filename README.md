# Splice Site Prediction with a CNN

Predicting splice sites in *Drosophila melanogaster* genome.

## Biological Background

Pre-mRNA splicing removes introns and joins exons. Splice sites are the positions where this cut happens and are marked by conserved short
sequences: `GT` at the 5' (donor) end and `AG` at the 3' (acceptor)
end of each intron. However, not every GT or AG
dinucleotide in a genome is a real splice site so the model must learn
the broader sequence context, if there is one, that makes a site functional.

## Task

Binary classification:  
given a 200 bp window centred on a GT dinucleotide, predict whether
it is a true donor splice site (label 1) or a false positive (label 0).