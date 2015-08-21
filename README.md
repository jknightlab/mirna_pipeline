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

### Step 1 - quality check and adjustment

Temporary code:

```
i="../miRNA/WTCHG_189136_281_1.fastq.gz"
j=`echo $i | sed s/.*WTCHG/WTCHG/g | sed s/\.fastq.*//g`
zcat $i > $j.fastq
mkdir $j.fastqc_output
fastqc -o $j.fastqc_output $j.fastq
unzip $j.fastqc_output/$j*zip
cat $j*fastqc/fastqc_data.txt  | grep Over -A 100 | grep 'Illumina\|TruSeq' | \
    grep -P '^[A-Z]' | nl | awk '{print ">" $1 "_adapter\n" $2}' > $j.adapters.fa
cutadapt -a file:$j.adapters.fa --minimum-length=15 --maximum-length=35 \
         -o $j.trimmed.fastq $j.fastq
mkdir $j.QC
mv $j* $j.QC
```

### Step 2 - alignment

**Stampy**

Building indices for mirna database:
```
/apps/well/stampy/1.0.25r3363-py2.7/stampy.py --species=human_mirna --assembly=mirbase_21 -G human_hairpin_mirna Database_for_mirna/hairpin_dna_human.fa
/apps/well/stampy/1.0.25r3363-py2.7/stampy.py --species=human_mirna --assembly=mirbase_21 -G human_mature_mirna Database_for_mirna/mature_dna_human.fa
```
**BWA**

Building a hash file for mirna database:
```
/apps/well/stampy/1.0.25r3363-py2.7/stampy.py -g human_hairpin_mirna -H human_hairpin_mirna
/apps/well/stampy/1.0.25r3363-py2.7/stampy.py -g human_mature_mirna -H human_mature_mirna
```

Running the alignment:
```
/apps/well/stampy/1.0.25r3363-py2.7/stampy.py -g human_hairpin_mirna -h human_hairpin_mirna -M QC/WTCHG_189135_285_1.QC/WTCHG_189135_285_1.trimmed.fastq -o Alignment/Stampy/WTCHG_189135_285_1.trimmed.stampy.hairpin.sam
/apps/well/stampy/1.0.25r3363-py2.7/stampy.py -g human_mature_mirna  -h human_mature_mirna  -M QC/WTCHG_189135_285_1.QC/WTCHG_189135_285_1.trimmed.fastq -o Alignment/Stampy/WTCHG_189135_285_1.trimmed.stampy.mature.sam
```
**bowtie**

Building index:
```
/apps/well/bowtie/1.0.1/bowtie-build Database_for_mirna/hairpin_dna_human.fa hairpin_mirna
/apps/well/bowtie/1.0.1/bowtie-build Database_for_mirna/mature_dna_human.fa mature_mirna
```

Running the alignment:
```
/apps/well/bowtie/1.0.1/bowtie -l 8 mature_mirna  QC/WTCHG_189135_285_1.QC/WTCHG_189135_285_1.trimmed.fastq > Alignment/bowtie/WTCHG_189135_285_1.trimmed.bowtie.mature.sam
/apps/well/bowtie/1.0.1/bowtie -l 8 hairpin_mirna QC/WTCHG_189135_285_1.QC/WTCHG_189135_285_1.trimmed.fastq > Alignment/bowtie/WTCHG_189135_285_1.trimmed.bowtie.hairpin.sam
```

**bowtie2**

Building index:
```
/apps/well/bowtie2/2.2.5/bowtie2-build Database_for_mirna/mature_dna_human.fa  mature_mirna.bowtie2
/apps/well/bowtie2/2.2.5/bowtie2-build Database_for_mirna/hairpin_dna_human.fa hairpin_mirna.bowtie2
```

Running the alignment:
```
/apps/well/bowtie2/2.2.5/bowtie2 -L 8 -x mature_mirna.bowtie2  QC/WTCHG_189135_285_1.QC/WTCHG_189135_285_1.trimmed.fastq > Alignment/bowtie2/WTCHG_189135_285_1.trimmed.bowtie2.mature.sam
/apps/well/bowtie2/2.2.5/bowtie2 -L 8 -x hairpin_mirna.bowtie2 QC/WTCHG_189135_285_1.QC/WTCHG_189135_285_1.trimmed.fastq > Alignment/bowtie2/WTCHG_189135_285_1.trimmed.bowtie2.hairpin.sam
```

### *Evaluation of the alignment results*

| Aligner                      | Stampy     |
| ---------------------------- | ---------- |
| Reads mapped to hairpin      | 15,497     |
| Reads not mapped to hairpin  | 4,951,457  |
| Reads mapped to mature       | x  |
| Reads not mapped to mature   | x  |


#### Designed by Irina Pulyakhina irina@well.ox.ac.uk
