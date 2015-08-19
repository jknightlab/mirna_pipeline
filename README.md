# mirna_pipeline
--------------------------------------
Bioinformatic pipeline to analyze micro RNA sequencing data

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

### Step 1 -- quality check and adjustment

Temporary code:

```
i="../miRNA/WTCHG_189136_281_1.fastq.gz"
j=`echo $i | sed s/.*WTCHG/WTCHG/g | sed s/\.fastq.*//g`
zcat $i > $j.fastq
mkdir $j.fastqc_output
fastqc -o $j.fastqc_output $j.fastq
unzip $j.fastqc_output/$j*zip
cat $j*fastqc/fastqc_data.txt  | grep Over -A 100 | grep 'Illumina\|TruSeq' | grep -P '^[A-Z]' | nl | awk '{print ">" $1 "_adapter\n" $2}' > $j.adapters.fa
cutadapt -a file:$j.adapters.fa --minimum-length=15 --maximum-length=35 -o $j.trimmed.fastq $j.fastq
mkdir $j.QC
mv $j* $j.QC
```

#### Designed by Irina Pulyakhina irina@well.ox.ac.uk
