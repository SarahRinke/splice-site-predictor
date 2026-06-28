# Splice Site Prediction with a CNN

Predicting donor splice sites in *Drosophila melanogaster* using a 1D convolutional neural network.

## Biological Background

Pre-mRNA splicing removes introns and joins exons. Splice sites are the positions where this cut happens and are marked by conserved short sequences: `GT` at the 5' (donor) end and `AG` at the 3' (acceptor) end of each intron. However, not every GT dinucleotide in a genome is a real splice site, so the model must learn the broader sequence context that makes a site functional.

## Task

Binary classification: given a 100 bp window centred on a GT dinucleotide (50 bp upstream + 50 bp downstream), predict whether it is a true donor splice site (label 1) or a non-functional GT dinucleotide (label 0).

## Repository Structure

```
splice-site-predictor/
├── download_data.sh                  # Download genome FASTA and GTF from Ensembl
├── data_prep.ipynb                   # Data processing and one-hot encoding
├── model_training.ipynb              # Local model training
├── model_training_on_kaggle.ipynb    # GPU model training on Kaggle (with evaluation)
└── data/
    ├── Drosophila_melanogaster.BDGP6.46.113.gtf       # Gene annotation
    ├── Drosophila_melanogaster.BDGP6.46.dna.toplevel.fa  # Genome sequence
    ├── positives.npy                 # One-hot encoded true donor sites (~150K)
    ├── positives.txt                 # Raw positive sequences
    ├── negatives.npy                 # One-hot encoded non-donor GT dinucleotides (~150K)
    └── negatives.txt                 # Raw negative sequences
```

## Workflow

### 1. Download data

Download the genome FASTA and GTF annotation files for *Drosophila melanogaster* (Ensembl release 113) into `data/`:

```bash
bash download_data.sh
```

### 2. Data preparation (`data_prep.ipynb`)

1. **Extract exons** from the GTF annotation file, grouped by transcript and strand.
2. **Derive introns** from consecutive exon pairs per transcript; introns shorter than 10 bp are discarded.
3. **Extract positive sequences** (true donor sites): 100 bp windows centred on the GT dinucleotide at each intron start, reverse-complemented for minus-strand introns.
4. **Extract negative sequences** (non-functional GT dinucleotides): 100 bp windows centred on all GT dinucleotides in the genome that are not annotated donor sites, then randomly subsampled to match the number of positives.
5. **One-hot encode** sequences (A/C/G/T → 4-channel vector per position; 100 positions → 400-element flat vector).
6. **Save** encoded arrays to `data/positives.npy` and `data/negatives.npy`.

### 3. Model training

Two training notebooks are provided:

- **`model_training.ipynb`** — for local CPU training.
- **`model_training_on_kaggle.ipynb`** — for GPU-accelerated training on [Kaggle](https://www.kaggle.com). Includes weight decay, early stopping, and full test-set evaluation with plots. Reads data from `/kaggle/input/datasets/sarahrinke/splice-sites-positives-negatives/`.

Both notebooks perform the same data loading and splitting:

| Split      | Samples  |
|------------|----------|
| Train      | ~240,000 |
| Validation | ~30,000  |
| Test       | ~30,000  |

Splits are stratified to maintain a 50/50 class balance.

## Model Architecture (`SpliceSiteCNN`)

A 1D CNN operating on sequences reshaped to `(batch, 4, 100)` — 4 nucleotide channels over a 100 bp window.

```
Input: (batch, 4, 100)
  └─ Conv1d(4→32,  kernel=9) + BatchNorm + ReLU + MaxPool → (batch, 32, 50)
  └─ Conv1d(32→64, kernel=8) + BatchNorm + ReLU + MaxPool → (batch, 64, 25)
  └─ Conv1d(64→128,kernel=8) + BatchNorm + ReLU + MaxPool → (batch, 128, 12)
  └─ Flatten → Linear(1536→256) + ReLU + Dropout(0.5)
  └─ Linear(256→1)
Output: (batch,) — raw logit per sample
```

**Training configuration (Kaggle version):**
- Loss: `BCEWithLogitsLoss`
- Optimiser: Adam (lr=0.001, weight_decay=1e-3)
- Scheduler: `ReduceLROnPlateau` (patience=3, factor=0.3)
- Early stopping: patience=5, min_delta=0.001
- Max epochs: 30, batch size: 256
- Best model saved to `best_model.pth`

## Evaluation

The Kaggle notebook evaluates the best saved model on the held-out test set and reports:

- Accuracy, AUROC, Precision, Recall, F1 score
- Confusion matrix (`confusion_matrix.png`)
- ROC curve (`roc_curve.png`)
- Training/validation loss curves (`loss_curves.png`)

## Dependencies

- [Biopython](https://biopython.org/) (`pip install biopython`)
- [NumPy](https://numpy.org/) (`pip install numpy`)
- [PyTorch](https://pytorch.org/) (`pip install torch`)
- [scikit-learn](https://scikit-learn.org/) (`pip install scikit-learn`)
- [Matplotlib](https://matplotlib.org/) (`pip install matplotlib`)