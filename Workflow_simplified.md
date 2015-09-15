Differential microRNA expression
--------------------------------------

The goal of this project was, starting from the
sequencing files provided by the Sequencing Core of
WTCHG, generate a list of candidate microRNAs
differentially expressed in healthy controls versus
patients with ankylosing spondylitis for further
experimental validation. Sequencing project number
is **P150188**.


### Experimental Design

Two groups of cells -- Th17 and non-Th27 -- were
separately sequenced for healthy controls and AS
patients. This table provides the names of the samples
and the names of the corresponding sequencing files.
Note that one of the samples -- **AS3-Th17** was not
sequenced due to failed library prep (message from
the core: *One sample, AS3-TH17, failed the library
prep and could not be included.*)

The miRNA were run on a HiSeq2500 Rapid mode. With *Rapid
mode* the libraries are run on a single sequencing
flowcell that has two lanes, so two sequencing files
will be produced for one sample (message from the core:
*the data can be merged between the lanes*).

In this table `AS` stands for AS patients and `HC` stands
for healthy controls.

| Sample type | File names                         |
| ----------- | ---------------------------------- |
| HC1-nonTh17 | WTCHG_189135_274, WTCHG_189136_274 |
| HC2-nonTh17 | WTCHG_189135_276, WTCHG_189136_276 |
| HC3-nonTh17 | WTCHG_189135_278, WTCHG_189136_278 |
| HC4-nonTh17 | WTCHG_189135_280, WTCHG_189136_280 |
|             |                                    |
| HC1-Th17    | WTCHG_189135_275, WTCHG_189136_275 |
| HC2-Th17    | WTCHG_189135_277, WTCHG_189136_277 |
| HC3-Th17    | WTCHG_189135_279, WTCHG_189136_279 |
| HC4-Th17    | WTCHG_189135_281, WTCHG_189136_281 |
|             |                                    |
| AS1-nonTh17 | WTCHG_189135_282, WTCHG_189136_282 |
| AS2-nonTh17 | WTCHG_189135_284, WTCHG_189136_284 |
| AS3-nonTh17 | WTCHG_189135_286, WTCHG_189136_286 |
| AS4-nonTh17 | WTCHG_189135_288, WTCHG_189136_288 |
|             |                                    |
| AS1-Th17    | WTCHG_189135_283, WTCHG_189136_283 |
| AS2-Th17    | WTCHG_189135_285, WTCHG_189136_285 |
| AS4-Th17    | WTCHG_189135_289, WTCHG_189136_289 |


### Bioinformatic pipeline to analyze miRNA sequencing data

Sequencing data is stored in `fastq` files -- text files
of a certain
[format](https://en.wikipedia.org/wiki/FASTQ_format)
containing sequenced reads names, sequences and
sequencing
[quality scores](https://en.wikipedia.org/wiki/Phred_quality_score).

Analysis workflow starting from the `fastq` files:
- Checking quality of the initial `fastq` files: checking whether any
Illumina adapters used for sequencing can be found; whether reads
contain low quality bases; what is the length of the reads. This is
done with a tool called
[`fastQC`](http://www.bioinformatics.babraham.ac.uk/projects/fastqc/).
- Cleaning the `fastq` files: removing adapters ("Overrepresented
sequences" in the `fastQC` report) found during the previous analysis
step (bash command); trimming low quality bases at the end of the reads
(tool [cutadapt](https://pypi.python.org/pypi/cutadapt/1.4.2));
discarding reads shorter than 15nt or longer than 26nt (bash command).
- Rerunning quality control on trimmed `fastq` files.
- [Aligning](https://en.wikipedia.org/wiki/Sequence_alignment)
trimmed `fastq` files to the database of known human
[miRNA](http://www.mirbase.org/) sequences with
[bowtie](http://bowtie-bio.sourceforge.net/index.shtml).
- Checking the quality of alignment: how many reads were aligned
perfectly (no mismatches) and uniquely (tool
[samtools](http://samtools.sourceforge.net/)).
- Extracting numbers of reads mapped to various microRNAs.
- Calculating expression of microRNAs -- normalizing the numbers
of mapped reads by the number of sequenced reads (library size)
and performing statistical test to find significant differential
expression (tool [DESeq](https://bioconductor.org/packages/release/bioc/html/DESeq.html)).

### Analysis workflow

**Checking quality control on initial fastq files**

An example report of quality checks on initial `fastq`
files for the sample AS2-Th17 can be found
[here](https://github.com/jknightlab/mirna_pipeline/blob/master/WTCHG_189136_285_1_fastqc.txt).
From the report we can see that the following checks failed:
- per base sequence content: this is expected, as the tool was
initially designed to work with whole genome reads. MicroRNAs
have a sequence content different from the whole genome, this
is why this check is expected to fail.
- sequence duplication level: this is expected, as the tool
was designed to work with DNA data, and RNA (and miRNA) has
expression, so fragments of certain reads are expected to
be highly represented.
- overrepresented sequences and adapter content: this failed
because the Sequencing Core has not trimmed Illumina sequencing
adapters after sequencing. We will remove these adapters.

**Cleaning the fastq files**

Identified adapters were removed from the 5' end of reads,
reads shorter than 15 or longer than 35 nucleotides were
discarded.

**Checking quality control on trimmed fastq files**

An example report of quality checks on trimmed `fastq`
files for the sample AS2-Th17 can be found
[here](https://github.com/jknightlab/mirna_pipeline/blob/master/WTCHG_189136_285_1_fastqc.trimmed.txt).
We can see that only sequence duplication level (and for some
files -- per nucleotide sequence content) still fail -- as
expected (see above). Note that reads which are too short or
too long after removing adapters will be discarded, so the
number of reads in a file can change. This table contains the
information on the number of reads before and after cleaning.

| Sample type | File name1       | Before trim| After trim | File name2       | Before trim| After trim |
| ----------- | ---------------- | ---------- | ---------- | ---------------- | ---------- | ---------- |
| <sub>HC1-nonTh17</sub> | <sub>WTCHG_189135_274</sub> | <sub>16,658,312</sub> | <sub>10,307,964</sub> | <sub>WTCHG_189136_274</sub> | <sub>17,111,904</sub> | <sub>10,735,176</sub> |
| <sub>HC2-nonTh17</sub> | <sub>WTCHG_189135_276</sub> | <sub>23,180,836</sub> | <sub>12,294,948</sub> | <sub>WTCHG_189136_276</sub> | <sub>23,817,544</sub> | <sub>12,692,556</sub> |
| <sub>HC3-nonTh17</sub> | <sub>WTCHG_189135_278</sub> | <sub>28,641,100</sub> | <sub>14,340,808</sub> | <sub>WTCHG_189136_278</sub> | <sub>29,263,204</sub> | <sub>14,677,208</sub> |
| <sub>HC4-nonTh17</sub> | <sub>WTCHG_189135_280</sub> | <sub>27,021,828</sub> | <sub>14,380,188</sub> | <sub>WTCHG_189136_280</sub> | <sub>27,634,528</sub> | <sub>14,715,880</sub> |
| <sub>HC1-Th17</sub> | <sub>WTCHG_189135_275</sub> | <sub>18,712,164</sub> | <sub>11,088,016</sub> | <sub>WTCHG_189136_275</sub> | <sub>19,226,884</sub> | <sub>11,487,684</sub> |
| <sub>HC2-Th17</sub> | <sub>WTCHG_189135_277</sub> | <sub>25,634,288</sub> | <sub>12,997,776</sub> | <sub>WTCHG_189136_277</sub> | <sub>26,178,792</sub> | <sub>13,286,152</sub> |
| <sub>HC3-Th17</sub> | <sub>WTCHG_189135_279</sub> | <sub>24,934,788</sub> | <sub>12,534,560</sub> | <sub>WTCHG_189136_279</sub> | <sub>25,451,552</sub> | <sub>12,808,388</sub> |
| <sub>HC4-Th17</sub> | <sub>WTCHG_189135_281</sub> | <sub>36,458,196</sub> | <sub>20,089,092</sub> | <sub>WTCHG_189136_281</sub> | <sub>37,117,612</sub> | <sub>20,519,576</sub> |
| <sub>AS1-nonTh17</sub> | <sub>WTCHG_189135_282</sub> | <sub>77,242,220</sub> | <sub>43,030,708</sub> | <sub>WTCHG_189136_282</sub> | <sub>79,433,628</sub> | <sub>44,313,332</sub> |
| <sub>AS2-nonTh17</sub> | <sub>WTCHG_189135_284</sub> | <sub>20,299,204</sub> | <sub>13,918,564</sub> | <sub>WTCHG_189136_284</sub> | <sub>20,800,688</sub> | <sub>14,275,212</sub> |
| <sub>AS3-nonTh17</sub> | <sub>WTCHG_189135_286</sub> | <sub>23,372,832</sub> | <sub>14,729,640</sub> | <sub>WTCHG_189136_286</sub> | <sub>23,979,804</sub> | <sub>15,319,740</sub> |
| <sub>AS4-nonTh17</sub> | <sub>WTCHG_189135_288</sub> | <sub>31,656,996</sub> | <sub>16,691,080</sub> | <sub>WTCHG_189136_288</sub> | <sub>32,283,960</sub> | <sub>17,033,808</sub> |
| <sub>AS1-Th17</sub> | <sub>WTCHG_189135_283</sub> | <sub>30,916,908</sub> | <sub>16,576,272</sub> | <sub>WTCHG_189136_283</sub> | <sub>31,723,492</sub> | <sub>17,048,232</sub> |
| <sub>AS2-Th17</sub> | <sub>WTCHG_189135_285</sub> | <sub>23,164,272</sub> | <sub>19,867,816</sub> | <sub>WTCHG_189136_285</sub> | <sub>23,761,664</sub> | <sub>20,393,544</sub> |
| <sub>AS4-Th17</sub> | <sub>WTCHG_189135_289</sub> | <sub>39,985,232</sub> | <sub>30,642,800</sub> | <sub>WTCHG_189136_289</sub> | <sub>41,047,460</sub> | <sub>31,462,132</sub> |

After trimming and discarding reads, all samples have number of reads
sufficient for the downstream analysis.

**Aligning reads to the database of human microRNAs**

This table contains numbers of reads mapped to miRNAs.

| Sample type | File name1 | Number of mapped reads |  File name2 | Number of mapped reads | RNA |
| ----------- | ---------- | ---------------------- | ----------- | ---------------------- | --- |
| <sub>HC1-nonTh17</sub> | <sub>WTCHG_189135_274</sub> | <sub>17,714</sub> | <sub>WTCHG_189136_274</sub> | <sub>18,437</sub> | <sub>90.83</sub> |
| <sub>HC2-nonTh17</sub> | <sub>WTCHG_189135_276</sub> | <sub>2,269</sub>  | <sub>WTCHG_189136_276</sub> | <sub>2,491</sub>  | <sub>100.00</sub>|
| <sub>HC3-nonTh17</sub> | <sub>WTCHG_189135_278</sub> | <sub>6,534</sub>  | <sub>WTCHG_189136_278</sub> | <sub>6,771</sub>  | <sub>100.00</sub>|
| <sub>HC4-nonTh17</sub> | <sub>WTCHG_189135_280</sub> | <sub>2,125</sub>  | <sub>WTCHG_189136_280</sub> | <sub>2,216</sub>  | <sub>100.00</sub>|
|                        |                             |                   |                             |                   |                  |
| <sub>HC1-Th17</sub>    | <sub>WTCHG_189135_275</sub> | <sub>2,417</sub>  | <sub>WTCHG_189136_275</sub> | <sub>2,425</sub>  | <sub>85.03</sub> |
| <sub>HC2-Th17</sub>    | <sub>WTCHG_189135_277</sub> | <sub>1,633</sub>  | <sub>WTCHG_189136_277</sub> | <sub>1,666</sub>  | <sub>69.76</sub> |
| <sub>HC3-Th17</sub>    | <sub>WTCHG_189135_279</sub> | <sub>1,212</sub>  | <sub>WTCHG_189136_279</sub> | <sub>1,265</sub>  | <sub>74.42</sub> |
| <sub>HC4-Th17</sub>    | <sub>WTCHG_189135_281</sub> | <sub>5,717</sub>  | <sub>WTCHG_189136_281</sub> | <sub>5,940</sub>  | <sub>49.08</sub> |
|                        |                             |                   |                             |                   |                  |
| <sub>AS1-nonTh17</sub> | <sub>WTCHG_189135_282</sub> | <sub>97,491</sub> | <sub>WTCHG_189136_282</sub> | <sub>101,344</sub>| <sub>100.00</sub>|
| <sub>AS2-nonTh17</sub> | <sub>WTCHG_189135_284</sub> | <sub>464</sub>    | <sub>WTCHG_189136_284</sub> | <sub>481</sub>    | <sub>36.46</sub> |
| <sub>AS3-nonTh17</sub> | <sub>WTCHG_189135_286</sub> | <sub>487</sub>    | <sub>WTCHG_189136_286</sub> | <sub>524</sub>    | <sub>46.10</sub> |
| <sub>AS4-nonTh17</sub> | <sub>WTCHG_189135_288</sub> | <sub>1,245</sub>  | <sub>WTCHG_189136_288</sub> | <sub>1,353</sub>  | <sub>77.02</sub> |
|                        |                             |                   |                             |                   |                  |
| <sub>AS1-Th17</sub>    | <sub>WTCHG_189135_283</sub> | <sub>732</sub>    | <sub>WTCHG_189136_283</sub> | <sub>729</sub>    | <sub>43.61</sub> |
| <sub>AS2-Th17</sub>    | <sub>WTCHG_189135_285</sub> | <sub>16</sub>     | <sub>WTCHG_189136_285</sub> | <sub>17</sub>     | <sub>33.27</sub> |
| <sub>AS4-Th17</sub>    | <sub>WTCHG_189135_289</sub> | <sub>776</sub>    | <sub>WTCHG_189136_289</sub> | <sub>771</sub>    | <sub>37.87</sub> |

Correlation between to sequencing runs is **0.99**. Correlation
between number of mapped reads and the amount of RNA input
material is **0.39**.

[Here](https://github.com/jknightlab/mirna_pipeline/blob/master/Alignment_process.md)
you can see how the aligner was chosen and all bioinformatic
details including commands.

**Checking alignment quality**

[Here](https://github.com/jknightlab/mirna_pipeline/blob/master/Alignment_results.md)
you can see other alignment results -- alignment to miRNAs from
other organisms than human, to human DNA, to all non-coding human
RNAs.

**Extracting reads mapped to miRNAs**

[This](https://github.com/jknightlab/mirna_pipeline/blob/master/mirna_matrix.xls)
table was generated by the Sequencing Core and contains
numbers of reads mapped to various human miRNAs. Note that this is
**not** expression data.

Looking at the number of reads mapped to miRNAs, one sample has too
low number of reads mapped to miRNAs and was excluded from further
analysis -- sample 285 a.k.a. AS2-Th17.

![alt text](https://github.com/jknightlab/mirna_pipeline/blob/master/reads_mapped_to_miRNAs.png)

[Here](https://github.com/jknightlab/mirna_pipeline/blob/master/mirna_matrix_no_285.xls)
is the file containing numbers of reads mapped to microRNAs, excluding
sample 285.

**Differential miRNA expression analysis**

Differential expression was performed by the `DESeq` package.
[Here](https://github.com/jknightlab/mirna_pipeline/blob/master/Diff_expression.md)
you can find more bioinformatic details on a pilot run on the
tool including commands (`R` code).

[Results](https://github.com/jknightlab/mirna_pipeline/blob/master/diff_expression_HC_Th17_VS_HC_nonTh17.txt)
of differential expression analysis between Th17 and nonTh17 cells in
healthy controls.

Dispersion estimation:

![alt text](https://github.com/jknightlab/mirna_pipeline/blob/master/dispersion_estimation.png)

Differential expression:

![alt text](https://github.com/jknightlab/mirna_pipeline/blob/master/log_fold_change_HC_Th17_VS_HC_nonTh17.png)



--------------------------------------

**TEMP -- technical issues**

Questions for the core:
- **Hc4 th17 40.9 49.08** ???
- The numbers -- sequencing results from the core, bam files --
and the expression data -- do not add up!!!!!!!!!!!


#### Designed by Irina Pulyakhina irina@well.ox.ac.uk
