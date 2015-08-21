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

For two samples something probably went wrong during adapter ligation -- after
trimming the adapters almost 90% of the reads were too short and hence discarded.
These were samples [WTCHG_189135_292_1](http://research-pub.gene.com/gmap/genomes/hg19.tar.gz)
and [WTCHG_189136_292_1](http://research-pub.gene.com/gmap/src/gmap-gsnap-2015-07-23.tar.gz).


### Step 2 - alignment

**Stampy**

Building indices for mirna database:
```
/apps/well/stampy/1.0.25r3363-py2.7/stampy.py --species=human_mirna --assembly=mirbase_21 \
    -G human_hairpin_mirna Database_for_mirna/hairpin_dna_human.fa
/apps/well/stampy/1.0.25r3363-py2.7/stampy.py --species=human_mirna --assembly=mirbase_21 \ 
    -G human_mature_mirna Database_for_mirna/mature_dna_human.fa
```
**BWA**

Building a hash file for mirna database:
```
/apps/well/stampy/1.0.25r3363-py2.7/stampy.py -g human_hairpin_mirna -H human_hairpin_mirna
/apps/well/stampy/1.0.25r3363-py2.7/stampy.py -g human_mature_mirna -H human_mature_mirna
```

Running the alignment:
```
/apps/well/stampy/1.0.25r3363-py2.7/stampy.py -g human_hairpin_mirna \
    -h human_hairpin_mirna -M QC/WTCHG_189135_285_1.QC/WTCHG_189135_285_1.trimmed.fastq
    -o Alignment/Stampy/WTCHG_189135_285_1.trimmed.stampy.hairpin.sam
/apps/well/stampy/1.0.25r3363-py2.7/stampy.py -g human_mature_mirna  \
    -h human_mature_mirna  -M QC/WTCHG_189135_285_1.QC/WTCHG_189135_285_1.trimmed.fastq \
    -o Alignment/Stampy/WTCHG_189135_285_1.trimmed.stampy.mature.sam
```

Converting bwa `sai` output into `sam`:
```
/apps/well/bwa/0.7.8/bwa samse -f WTCHG_189135_285_1.trimmed.bwa.mature.sam \
../../Database_for_mirna/mature_dna_human.fa WTCHG_189135_285_1.trimmed.bwa.mature.sai \
../../QC/WTCHG_189135_285_1.QC/WTCHG_189135_285_1.trimmed.fastq
/apps/well/bwa/0.7.8/bwa samse -f WTCHG_189135_285_1.trimmed.bwa.hairpin.sam \
../../Database_for_mirna/hairpin_dna_human.fa WTCHG_189135_285_1.trimmed.bwa.hairpin.sai \
../../QC/WTCHG_189135_285_1.QC/WTCHG_189135_285_1.trimmed.fastq
```

**bowtie**

Building index:
```
/apps/well/bowtie/1.0.1/bowtie-build Database_for_mirna/hairpin_dna_human.fa hairpin_mirna
/apps/well/bowtie/1.0.1/bowtie-build Database_for_mirna/mature_dna_human.fa mature_mirna
```

Running the alignment:
```
/apps/well/bowtie/1.0.1/bowtie -l 8 mature_mirna  \
    QC/WTCHG_189135_285_1.QC/WTCHG_189135_285_1.trimmed.fastq \
    > Alignment/bowtie/WTCHG_189135_285_1.trimmed.bowtie.mature.sam
/apps/well/bowtie/1.0.1/bowtie -l 8 hairpin_mirna \
    QC/WTCHG_189135_285_1.QC/WTCHG_189135_285_1.trimmed.fastq \
    > Alignment/bowtie/WTCHG_189135_285_1.trimmed.bowtie.hairpin.sam
```

**bowtie2**

Building index:
```
/apps/well/bowtie2/2.2.5/bowtie2-build Database_for_mirna/mature_dna_human.fa  mature_mirna.bowtie2
/apps/well/bowtie2/2.2.5/bowtie2-build Database_for_mirna/hairpin_dna_human.fa hairpin_mirna.bowtie2
```

Running the alignment:
```
/apps/well/bowtie2/2.2.5/bowtie2 -L 8 -x mature_mirna.bowtie2 \
    QC/WTCHG_189135_285_1.QC/WTCHG_189135_285_1.trimmed.fastq \
    > Alignment/bowtie2/WTCHG_189135_285_1.trimmed.bowtie2.mature.sam
/apps/well/bowtie2/2.2.5/bowtie2 -L 8 -x hairpin_mirna.bowtie2 \
    QC/WTCHG_189135_285_1.QC/WTCHG_189135_285_1.trimmed.fastq \
    > Alignment/bowtie2/WTCHG_189135_285_1.trimmed.bowtie2.hairpin.sam
```

### *Evaluation of the alignment results*

- number of mapped reads:
```
samtools view -F 4 WTCHG_189135_285_1.trimmed.bowtie2.mature.bam -c
```
- number of unmapped reads:
```
samtools view -f 4 WTCHG_189135_285_1.trimmed.bowtie2.mature.bam -c
```

| Aligner                      | Stampy     | bwa       | bowtie    | bowtie2   |
| ---------------------------- | ---------- | --------- | --------- | --------- |
| Reads mapped to hairpin      | 15,497     | 70,123    | 80,041    | 25,592    |
| Reads not mapped to hairpin  | 4,951,457  | 4,896,831 | 4,886,913 | 4,941,362 |
| Reads mapped to mature       | 29,580     | 15,314    | 18,999    | 10,224    |
| Reads not mapped to mature   | 4,937,374  | 4,951,640 | 4,947,955 | 4,956,730 |

For some reason so far all tools map less tha 0.5% to any of the databases...

Data generated by the sequencing core (so far we don't know how):

| sample name          | number of mapped reads | number of unmapped reads |
| -------------------- | ---------------------- | ------------------------ |
| WTCHG_189135_274.bam |  17714  | 4146864  |
| WTCHG_189135_275.bam |  2417   | 4675624  |
| WTCHG_189135_276.bam |  2269   | 5792940  |
| WTCHG_189135_277.bam |  1633   | 6406939  |
| WTCHG_189135_278.bam |  6534   | 7153741  |
| WTCHG_189135_279.bam |  1212   | 6232485  |
| WTCHG_189135_280.bam |  2125   | 6753332  |
| WTCHG_189135_281.bam |  5717   | 9108832  |
| WTCHG_189135_282.bam |  97491  | 19213064 |
| WTCHG_189135_283.bam |  732    | 7728495  |
| WTCHG_189135_284.bam |  464    | 5074337  |
| WTCHG_189135_285.bam |  16     | 5791052  |
| WTCHG_189135_286.bam |  487    | 5842721  |
| WTCHG_189135_288.bam |  1245   | 7913004  |
| WTCHG_189135_289.bam |  776    | 9995532  |
| WTCHG_189135_290.bam |  9868   | 4764155  |
| WTCHG_189135_291.bam |  58701  | 8421188  |
| WTCHG_189135_292.bam |  888    | 5877188  |
| WTCHG_189135_293.bam |  5031   | 6657707  |
| WTCHG_189136_274.bam |  18437  | 4259539  |
| WTCHG_189136_275.bam |  2425   | 4804296  |
| WTCHG_189136_276.bam |  2491   | 5951895  |
| WTCHG_189136_277.bam |  1666   | 6543032  |
| WTCHG_189136_278.bam |  6771   | 7309030  |
| WTCHG_189136_279.bam |  1265   | 6361623  |
| WTCHG_189136_280.bam |  2216   | 6906416  |
| WTCHG_189136_281.bam |  5940   | 9273463  |
| WTCHG_189136_282.bam |  101344 | 19757063 |
| WTCHG_189136_283.bam |  729    | 7930144  |
| WTCHG_189136_284.bam |  481    | 5199691  |
| WTCHG_189136_285.bam |  17     | 5940399  |
| WTCHG_189136_286.bam |  524    | 5994427  |
| WTCHG_189136_288.bam |  1353   | 8069637  |
| WTCHG_189136_289.bam |  771    | 10261094 |
| WTCHG_189136_290.bam |  10107  | 4878495  |
| WTCHG_189136_291.bam |  60468  | 8631533  |
| WTCHG_189136_292.bam |  885    | 6009893  |
| WTCHG_189136_293.bam |  5025   | 6805217  |


**BWA**

Building index:
```
/apps/well/bwa/0.7.8/bwa index -a is Database_for_mirna/hairpin_dna_human.fa
/apps/well/bwa/0.7.8/bwa index -a is Database_for_mirna/mature_dna_human.fa

samtools faidx Database_for_mirna/hairpin_dna_human.fa
samtools faidx Database_for_mirna/mature_dna_human.fa

java -jar  /apps/well/picard-tools/1.111/CreateSequenceDictionary.jar REFERENCE=Database_for_mirna/hairpin_dna_human.fa OUTPUT=Database_for_mirna/hairpin_dna_human.dict
java -jar  /apps/well/picard-tools/1.111/CreateSequenceDictionary.jar REFERENCE=Database_for_mirna/mature_dna_human.fa  OUTPUT=Database_for_mirna/mature_dna_human.dict
```

Running the alignment:
```
/apps/well/bwa/0.7.8/bwa aln -l 8 Database_for_mirna/hairpin_dna_human.fa QC/WTCHG_189135_285_1.QC/WTCHG_189135_285_1.trimmed.fastq > Alignment/bwa/WTCHG_189135_285_1.trimmed.bwa.hairpin.sai
/apps/well/bwa/0.7.8/bwa aln -l 8 Database_for_mirna/mature_dna_human.fa  QC/WTCHG_189135_285_1.QC/WTCHG_189135_285_1.trimmed.fastq > Alignment/bwa/WTCHG_189135_285_1.trimmed.bwa.mature.sai
```

#### Designed by Irina Pulyakhina irina@well.ox.ac.uk
