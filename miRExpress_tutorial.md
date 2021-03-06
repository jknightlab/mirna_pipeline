# mirna_pipeline
--------------------------------------
Bioinformatic pipeline to analyze micro RNA sequencing data

## General info

To run the bioinformatic analysis of microRNA NGS data described
[here](https://github.com/jknightlab/mirna_pipeline/edit/master/README.md),
I tried the [miRExpress](http://mirexpress.mbc.nctu.edu.tw/usage.php) tool.

### Tutorial

All tools are situated in `/well/jknight/Irina/Programs/miRExpress/src/Raw_data_parse`.

Everything here was performed on a small test subset of 2500 reads (pre-trimmed, as the
trimming step didn't work):

```
head -10000 ../QC/WTCHG_189135_275_1.QC/WTCHG_189135_275_1.trimmed.fastq > test.fastq

Raw_data_parse -i test.fastq

statistics_reads -i test.fastq.merge

alignmentSIMD -r /well/jknight/Irina/Programs/miRExpress/data_miRBase_19/hsa_precursor.txt \
    -i test.fastq.merge -o alignment_results/
```

The alignment results file doesn't exist. Assuming it happens because none of my reads
map to the database, I am rerunning the whole pipeline with the full fastq file (trimmed).

#### written by Irina Pulyakhina irina@well.ox.ac.uk
