# mirna_pipeline
--------------------------------------
bioinformatics pipeline to analyze micro RNA sequencing data

## General description

This pipeline is designed to work with micro RNA next generation
sequencing data. The aims of the pipeline are to identify known
microRNAs present in different samples and compare the expression
of microRNAs common for both samples.

## Analysis workflow
- Checking quality of the initial fastq files: checking whether any adapters can be found; whether reads contain low quality bases; what is the length of the reads.
- Cleaning the fastq files: removing adapters found during the previous analysis step; trimming low quality bases at the end of the reads; discarding reads shorter than 15nt or longer than 26nt.
- Rerunning quality control on trimmed fastq files.
- Running the alignment on trimmed fastq files.
- Performing quality check on the alignments.
- Overlapping the alignment files with the database of known microRNAs.
- Extracting the experssion (normalized read counts) for microRNAs present in the sample.
- For microRNAs common for at least two samples, comparing the expression between the two conditions.
- Extracting differentially expressed microRNAs.

#### Designed by Irina Pulyakhina irina@well.ox.ac.uk
