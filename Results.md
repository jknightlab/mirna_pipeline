# mirna_pipeline
--------------------------------------
Bioinformatic pipeline to analyze micro RNA sequencing data

## Results of the analysis

Mapping all reads (trimmed, containing no adapters and adequate sequence length)
to the full database of microRNAs from all organisms using `bowtie`.

**Mapping against mature microRNA**

![alt text](https://github.com/jknightlab/mirna_pipeline/blob/master/mature_miRNA_all_samples_distr.png)
![alt text](https://github.com/jknightlab/mirna_pipeline/blob/master/mature_miRNA_all_samples_numbers.png)

Legend for both bar graphs:

<img src="https://github.com/jknightlab/mirna_pipeline/blob/master/mature_miRNA_all_samples_legend.png" width="300">

Now a hred:


<a href="url"><img src="https://github.com/jknightlab/mirna_pipeline/blob/master/mature_miRNA_all_samples_legend.png" align="left" height="250" width="300" ></a>
<br>

Only a minority of reads was mapped to any known microRNAs (about **0.5%** per sample on average).

#### Designed by Irina Pulyakhina irina@well.ox.ac.uk
