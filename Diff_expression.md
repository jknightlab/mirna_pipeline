# mirna_pipeline
--------------------------------------
Bioinformatic pipeline to analyze micro RNA sequencing data

## Results of the analysis

**Mapping against the human genome**

-> Results from sequencing core: on average less than *1%* was mapped.

-> Results of my alignment: after trimming the adapters and removing too short
and too long reads, *87%* of reads was mapped to the human genome with `bowtie`
on average. `bowtie` does not split reads, so this is considered as DNA alignment.

Even though a lot of reads mapped perfectly and uniquely, when looking at the coverage
distribution, it looks pretty random; in fact, a lot of reads are mapped to to the same
location.

| Examples of some genes from chr1 |
| -------------------------------- |
| ![alt text](https://github.com/jknightlab/mirna_pipeline/blob/master/example_dcaf6.png) |
| |
| ![alt text](https://github.com/jknightlab/mirna_pipeline/blob/master/example_lmna.png) |


After removing potential PCR duplicates with `samtools rmdup`, only *15%* of reads are left.

**Mapping against human non-coding RNAs**

Mapping all reads (trimmed, containing no adapters and adequate sequence length)
to the database containing human [noncoding RNAs](http://www.noncode.org/index.php).
Unfortunately the database does not provide good annotation (what type of ncRNAs it
contains), the entries are named `NONHSAT000009` and similarly. However, mainly the
database contains *long noncoding RNAs*.

On average for all analyzed samples around *78%* of reads were mapped without mismatches.




**Mapping against mature microRNA**

Mapping all reads (trimmed, containing no adapters and adequate sequence length)
to the full database of microRNAs from all organisms using `bowtie`.

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
