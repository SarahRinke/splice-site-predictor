# Splice Site Prediction with a CNN

Predicting donor splice sites in *Drosophila melanogaster* genome.

## Biological Background

Pre-mRNA splicing removes introns and joins exons. Splice sites are the positions where this cut happens and are marked by conserved short
sequences: `GT` at the 5' (donor) end and `AG` at the 3' (acceptor)
end of each intron. However, not every GT or AG
dinucleotide in a genome is a real splice site so the model must learn
the broader sequence context, if there is one, that makes a site functional.

## Task

Binary classification:  
given a 100 bp window centred on a GT dinucleotide (50 bp upstream + 50 bp downstream), predict whether
it is a true donor splice site (label 1) or a false positive (label 0).

## Download data

Download the latest versions of fasta and gtf files for *Drosophila melanogaster* using `download_data.sh`.

## Data processing

1. **Extract exons** from the GTF annotation file, grouped by transcript and strand.
2. **Derive introns** from consecutive exon pairs per transcript; introns shorter than 10 bp are discarded.
3. **Extract positive sequences** (true donor sites): 100 bp windows centred on the GT dinucleotide at each intron start, reverse-complemented for minus-strand introns.
4. **Extract negative sequences** (false GT dinucleotides): 100 bp windows centred on all GT dinucleotides in the genome that are not annotated donor sites, then randomly subsampled to match the number of positives.
5. **One-hot encode** sequences (A/C/G/T → 4-bit vector per position; 100 positions → 400-element vector).

## Dependencies

- [Biopython](https://biopython.org/) (`pip install biopython`)