# mirna_pipeline
--------------------------------------
Bioinformatic pipeline to analyze micro RNA sequencing data

## Results of the analysis

Mapping all reads (trimmed, containing no adapters and adequate sequence length)
to the full database of microRNAs from all organisms using `bowtie`.

**Mapping against mature microRNA**

Numbers of reads mapped to microRNAs from known species:
- [all species](https://github.com/jknightlab/mirna_pipeline/blob/master/mature_miRNA_all_samples_matrix_all.txt)
- [ten](https://github.com/jknightlab/mirna_pipeline/blob/master/mature_miRNA_all_samples_matrix_most_representes.txt) species to which the majority of reads was mapped to (on average for all samples)

Only a minority of reads was mapped to any known microRNAs (about **0.5%** per sample on average).

| number of mapped reads | percent of mapped reads |
| ---------------------- | ----------------------- |
| ![alt text](https://github.com/jknightlab/mirna_pipeline/blob/master/mature_miRNA_all_samples_numbers.png) | ![alt text](https://github.com/jknightlab/mirna_pipeline/blob/master/mature_miRNA_all_samples_distr.png) |

Legend for both bar graphs:

<img src="https://github.com/jknightlab/mirna_pipeline/blob/master/mature_miRNA_all_samples_legend.png" width="200">


**Mapping against hairpin microRNA**

Numbers of reads mapped to hairpin microRNAs from known species:
- [all species](https://github.com/jknightlab/mirna_pipeline/blob/master/hairpin_miRNA_all_samples_matrix_all.txt)
- [ten](https://github.com/jknightlab/mirna_pipeline/blob/master/hairpin_miRNA_all_samples_matrix_most_representes.txt) species to which the majority of reads was mapped to (on average for all samples)

Only a minority of reads was mapped to any known microRNAs (about **2.75%** per sample on average).

| number of mapped reads | percent of mapped reads |
| ---------------------- | ----------------------- |
| ![alt text](https://github.com/jknightlab/mirna_pipeline/blob/master/hairpin_miRNA_all_samples_numbers.png) | ![alt text](https://github.com/jknightlab/mirna_pipeline/blob/master/hairpin_miRNA_all_samples_distr.png) |

Legend for both bar graphs:

<img src="https://github.com/jknightlab/mirna_pipeline/blob/master/hairpin_miRNA_all_samples_legend.png" width="200">

*NOTE* that for each sample more reads were mapped to hairpin miRNAs than to mature miRNAs.




#### Designed by Irina Pulyakhina irina@well.ox.ac.uk
