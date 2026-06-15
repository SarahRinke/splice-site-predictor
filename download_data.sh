#usr/bin/bash

mkdir -p data
cd data

BASE="https://ftp.ensembl.org/pub/release-113"

wget ${BASE}/fasta/drosophila_melanogaster/dna/Drosophila_melanogaster.BDGP6.46.dna.toplevel.fa.gz

wget ${BASE}/gtf/drosophila_melanogaster/Drosophila_melanogaster.BDGP6.46.113.gtf.gz

gunzip *.gz