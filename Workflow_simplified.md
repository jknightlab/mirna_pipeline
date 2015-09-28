Differential microRNA expression
--------------------------------------

The goal of this project was, starting from the
sequencing files provided by the Sequencing Core of
WTCHG, to generate a list of candidate microRNAs
differentially expressed in healthy controls versus
patients with ankylosing spondylitis for further
experimental validation. Sequencing project number
is **P150188**.


### Experimental Design

Two groups of cells -- [Th17](https://en.wikipedia.org/wiki/T_helper_17_cell) and non-Th17 -- were
separately sequenced for healthy controls and AS
patients. This table provides the names of the samples
and the names of the corresponding sequencing files.
Note that one of the samples -- **AS3-Th17** was not
sequenced due to failed library prep (message from
the core: *One sample, AS3-TH17, failed the library
prep and could not be included.*)

The miRNA samples were run on a HiSeq2500 Rapid mode. With *Rapid
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
containing sequenced reads' names, sequences and
sequencing
[quality scores](https://en.wikipedia.org/wiki/Phred_quality_score).

First eight lines of `WTCHG_189135_286_1.fastq`:

```
@HISEQ2500-09:311:H3K5LBCXX:1:1101:1471:1980 1:N:0:CTCAGCTG # read name
NAGGGAGGACTTCTCTGAGGAGATCGGAAGAGCACACGTCTGAACTCCAGT         # read sequence
+                                                           # delimiter line
#<DDDGHHHIIIIIIIIHIIHIIIIIIIIIIIIIIIIIIIIIIHIIIIIHI         # sequencing quality
@HISEQ2500-09:311:H3K5LBCXX:1:1101:3278:1986 1:N:0:CTCAGCTG # read name
NAAGTGGACGTATAGGGTGTGACGTAGATCGGAAGAGCACACGTCTGAACT         # read sequence
+                                                           # delimiter line
#<DDDIIIIIHIIIIIIIIIIIIIIIIIIIIIIIIIHHHIIIHIIIIIIIF         # sequencing quality
```

Analysis workflow starting from the `fastq` files:
- Checking quality of the initial `fastq` files: checking whether any
Illumina adapters used for sequencing can be found; whether reads
contain low quality bases; what is the length of the reads. This is
done with a tool called
[`fastQC`](http://www.bioinformatics.babraham.ac.uk/projects/fastqc/).
- Cleaning the `fastq` files: removing adapters ("Overrepresented
sequences" in the `fastQC` report) found during the previous analysis
step (bash command); trimming low quality bases at the end of the reads;
discarding reads shorter than 15nt or longer than 35nt
(tool [cutadapt](https://pypi.python.org/pypi/cutadapt/1.4.2)).
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
is why this check is expected to fail. Also, as we will see later,
adapters were not trimmed yet and are overrepresented -- their
sequence also biases the sequence content of the reads.
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
files -- per nucleotide sequence content) still fails -- as
expected (see the explanation above). Note that reads which are too short or
too long after removing adapters will be discarded, so the
number of reads in a file can change. This table contains the
information on the number of reads before and after cleaning.

| <sub>Sample type</sub> | <sub>File name1</sub> | <sub>Before trim</sub> | <sub>After trim</sub> | <sub>File name2</sub> | <sub>Before trim</sub> | <sub>After trim</sub> |
| ----------- | ---------------- | ---------- | ---------- | ---------------- | ---------- | ---------- |
| <sub>HC1-nonTh17</sub> | <sub>WTCHG_189135_274</sub> | <sub>16,658,312</sub> | <sub>10,307,964</sub> | <sub>WTCHG_189136_274</sub> | <sub>17,111,904</sub> | <sub>10,735,176</sub> |
| <sub>HC2-nonTh17</sub> | <sub>WTCHG_189135_276</sub> | <sub>23,180,836</sub> | <sub>12,294,948</sub> | <sub>WTCHG_189136_276</sub> | <sub>23,817,544</sub> | <sub>12,692,556</sub> |
| <sub>HC3-nonTh17</sub> | <sub>WTCHG_189135_278</sub> | <sub>28,641,100</sub> | <sub>14,340,808</sub> | <sub>WTCHG_189136_278</sub> | <sub>29,263,204</sub> | <sub>14,677,208</sub> |
| <sub>HC4-nonTh17</sub> | <sub>WTCHG_189135_280</sub> | <sub>27,021,828</sub> | <sub>14,380,188</sub> | <sub>WTCHG_189136_280</sub> | <sub>27,634,528</sub> | <sub>14,715,880</sub> |
|   |   |   |   |   |   |   |
| <sub>HC1-Th17</sub> | <sub>WTCHG_189135_275</sub> | <sub>18,712,164</sub> | <sub>11,088,016</sub> | <sub>WTCHG_189136_275</sub> | <sub>19,226,884</sub> | <sub>11,487,684</sub> |
| <sub>HC2-Th17</sub> | <sub>WTCHG_189135_277</sub> | <sub>25,634,288</sub> | <sub>12,997,776</sub> | <sub>WTCHG_189136_277</sub> | <sub>26,178,792</sub> | <sub>13,286,152</sub> |
| <sub>HC3-Th17</sub> | <sub>WTCHG_189135_279</sub> | <sub>24,934,788</sub> | <sub>12,534,560</sub> | <sub>WTCHG_189136_279</sub> | <sub>25,451,552</sub> | <sub>12,808,388</sub> |
| <sub>HC4-Th17</sub> | <sub>WTCHG_189135_281</sub> | <sub>36,458,196</sub> | <sub>20,089,092</sub> | <sub>WTCHG_189136_281</sub> | <sub>37,117,612</sub> | <sub>20,519,576</sub> |
|   |   |   |   |   |   |   |
| <sub>AS1-nonTh17</sub> | <sub>WTCHG_189135_282</sub> | <sub>77,242,220</sub> | <sub>43,030,708</sub> | <sub>WTCHG_189136_282</sub> | <sub>79,433,628</sub> | <sub>44,313,332</sub> |
| <sub>AS2-nonTh17</sub> | <sub>WTCHG_189135_284</sub> | <sub>20,299,204</sub> | <sub>13,918,564</sub> | <sub>WTCHG_189136_284</sub> | <sub>20,800,688</sub> | <sub>14,275,212</sub> |
| <sub>AS3-nonTh17</sub> | <sub>WTCHG_189135_286</sub> | <sub>23,372,832</sub> | <sub>14,729,640</sub> | <sub>WTCHG_189136_286</sub> | <sub>23,979,804</sub> | <sub>15,319,740</sub> |
| <sub>AS4-nonTh17</sub> | <sub>WTCHG_189135_288</sub> | <sub>31,656,996</sub> | <sub>16,691,080</sub> | <sub>WTCHG_189136_288</sub> | <sub>32,283,960</sub> | <sub>17,033,808</sub> |
|   |   |   |   |   |   |   |
| <sub>AS1-Th17</sub> | <sub>WTCHG_189135_283</sub> | <sub>30,916,908</sub> | <sub>16,576,272</sub> | <sub>WTCHG_189136_283</sub> | <sub>31,723,492</sub> | <sub>17,048,232</sub> |
| <sub>AS2-Th17</sub> | <sub>WTCHG_189135_285</sub> | <sub>23,164,272</sub> | <sub>19,867,816</sub> | <sub>WTCHG_189136_285</sub> | <sub>23,761,664</sub> | <sub>20,393,544</sub> |
| <sub>AS4-Th17</sub> | <sub>WTCHG_189135_289</sub> | <sub>39,985,232</sub> | <sub>30,642,800</sub> | <sub>WTCHG_189136_289</sub> | <sub>41,047,460</sub> | <sub>31,462,132</sub> |

After trimming and discarding reads, all samples have number of reads
sufficient for the downstream analysis.

**Aligning reads to the database of human microRNAs**

This table contains numbers of reads mapped to miRNAs (merged for two
sequenced files). Column `RNA` contains the information about the
input material (number of *ng*).

| <sub>Sample type</sub> | <sub>File name1</sub> | <sub>File name2</sub> | <sub>Number of mapped reads</sub> | <sub>RNA, ng</sub> |
| ---------------------- | --------------------- | --------------------- | ---------------------- | --- |
| <sub>HC1-nonTh17</sub> | <sub>WTCHG_189135_274</sub> | <sub>WTCHG_189136_274</sub> | <sub>42,748</sub> | <sub>90.83</sub> |
| <sub>HC2-nonTh17</sub> | <sub>WTCHG_189135_276</sub> | <sub>WTCHG_189136_276</sub> | <sub>995,035</sub>  | <sub>100.00</sub>|
| <sub>HC3-nonTh17</sub> | <sub>WTCHG_189135_278</sub> | <sub>WTCHG_189136_278</sub> | <sub>677,173</sub>  | <sub>100.00</sub>|
| <sub>HC4-nonTh17</sub> | <sub>WTCHG_189135_280</sub> | <sub>WTCHG_189136_280</sub> | <sub>450,159</sub>  | <sub>100.00</sub>|
|                        |                             |                             |                   |                  |
| <sub>HC1-Th17</sub>    | <sub>WTCHG_189135_275</sub> | <sub>WTCHG_189136_275</sub> | <sub>86,821</sub>  | <sub>85.03</sub> |
| <sub>HC2-Th17</sub>    | <sub>WTCHG_189135_277</sub> | <sub>WTCHG_189136_277</sub> | <sub>955,892</sub>  | <sub>69.76</sub> |
| <sub>HC3-Th17</sub>    | <sub>WTCHG_189135_279</sub> | <sub>WTCHG_189136_279</sub> | <sub>926,892</sub>  | <sub>74.42</sub> |
| <sub>HC4-Th17</sub>    | <sub>WTCHG_189135_281</sub> | <sub>WTCHG_189136_281</sub> | <sub>153,514</sub>  | <sub>49.08</sub> |
|                        |                             |                             |                   |                  |
| <sub>AS1-nonTh17</sub> | <sub>WTCHG_189135_282</sub> | <sub>WTCHG_189136_282</sub> | <sub>1,188,284</sub>| <sub>100.00</sub>|
| <sub>AS2-nonTh17</sub> | <sub>WTCHG_189135_284</sub> | <sub>WTCHG_189136_284</sub> | <sub>298,505</sub>    | <sub>36.46</sub> |
| <sub>AS3-nonTh17</sub> | <sub>WTCHG_189135_286</sub> | <sub>WTCHG_189136_286</sub> | <sub>665,606</sub>    | <sub>46.10</sub> |
| <sub>AS4-nonTh17</sub> | <sub>WTCHG_189135_288</sub> | <sub>WTCHG_189136_288</sub> | <sub>1,305,340</sub>  | <sub>77.02</sub> |
|                        |                             |                             |                   |                  |
| <sub>AS1-Th17</sub>    | <sub>WTCHG_189135_283</sub> | <sub>WTCHG_189136_283</sub> | <sub>574,407</sub>    | <sub>43.61</sub> |
| <sub>AS2-Th17</sub>    | <sub>WTCHG_189135_285</sub> | <sub>WTCHG_189136_285</sub> | <sub>10,110</sub>     | <sub>33.27</sub> |
| <sub>AS4-Th17</sub>    | <sub>WTCHG_189135_289</sub> | <sub>WTCHG_189136_289</sub> | <sub>706,156</sub>    | <sub>37.87</sub> |

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
you can find more bioinformatic details including commands (`R` code).

*Firstly,* pairwise differential expression analysis between
each pair of conditions was performed. Unfortunately this analysis
produced only one statistically significant difference in miRNA
expressions (see the description after the links to the files with
differential expression analysis results). The absence of almost
any differentially expressed miRNAs is most likely due to the low
amount of identified miRNAs and mainly low number of reads mapped
to miRNAs.

These two figures demonstrate how low number of identified miRNAs
affect the analysis. The first row of the figures contains scatter
plots with the [dispersion](https://en.wikipedia.org/wiki/Statistical_dispersion)
estimation. The second row of figures contains log2 fold change of
gene expression against the mean (average) of normalized counts
(significant differential expression is highlighted in red).

| Taejong's data | Public data |
| -------------- | ----------- |
| ![alt text](https://github.com/jknightlab/mirna_pipeline/blob/master/dispersion_estimation.png) | ![alt text](https://github.com/jknightlab/mirna_pipeline/blob/master/dispersion_estimate_public_example.png) |
| | |
| ![alt text](https://github.com/jknightlab/mirna_pipeline/blob/master/log_fold_change_HC_Th17_VS_HC_nonTh17.png) | ![alt text](https://github.com/jknightlab/mirna_pipeline/blob/master/diff_expression_public_example.png) |

We have four groups, *HC_Th17*, *HC_nonTh17*, *AS_Th17*, *AS_nonTh17*.
The results of pairwise differential miRNA expression analysis
for these groups can be found here:

- [HC_Th17 vs HC_nonTh17](https://github.com/jknightlab/mirna_pipeline/blob/master/diff_expression_HC_Th17_VS_HC_nonTh17.txt)
- [HC_Th17 vs AS_Th17](https://github.com/jknightlab/mirna_pipeline/blob/master/diff_expression_HC_Th17_VS_AS_Th17.txt)
- [HC_Th17 vs AS_nonTh17](https://github.com/jknightlab/mirna_pipeline/blob/master/diff_expression_HC_Th17_VS_AS_nonTh17.txt)
- [HC_nonTh17 vs AS_Th27](https://github.com/jknightlab/mirna_pipeline/blob/master/diff_expression_HC_nonTh17_VS_AS_Th17.txt)
- [HC_nonTh17 vs AS_nonTh27](https://github.com/jknightlab/mirna_pipeline/blob/master/diff_expression_HC_nonTh17_VS_AS_nonTh17.txt)
- [AS_Th17 vs AS_nonTh17](https://github.com/jknightlab/mirna_pipeline/blob/master/diff_expression_AS_Th17_VS_AS_nonTh17.txt)
- [HC vs AS](https://github.com/jknightlab/mirna_pipeline/blob/master/diff_expression_HC_VS_AS.pooled.txt) (all HC vs all AS)

One statistically significant hit: in the comparison
of HC Th17 vs AS Th17.
```
name_of_miRNA_	baseMean	baseMeanA	baseMeanB	foldChange	log2FoldChange	pvalue	padj
hsa-miR-10b-5p	29.11241	0.1963728	86.944483	442.752059	8.790355204839	1.5e-05	0.013
```
More information about the **hsa-miR-10b-5p** microRNA can be found
[here](http://www.mirbase.org/cgi-bin/mirna_entry.pl?acc=MI0000267).
Limited information about upregulation of miR-10b in cancers is available.
In this data, this microRNA is upregulated in `AS` versus `HC`. However,
the expression of this microRNA in `HC` is probably too low to select it
as a candidate for experimental validation with qPCR (qPCR might not be
sensivite enough). Raw numbers of reads mapped to this microRNA:

```
mirna         	HC1-Th17	HC2-Th17	HC3-Th17	HC4-Th17	AS1-Th17	AS4-nonTh17
hsa-miR-10b-5p	0       	0       	1       	0       	97      	22
```

*Secondly*, we performed ANOVA test across all four groups
of samples. It is done with an `R` package `limma`, and the
details (including commands) can be found
[here](https://github.com/jknightlab/mirna_pipeline/blob/master/ANOVA.md).

When running *limma* for only reasonably expressed
[microRNAs](https://github.com/jknightlab/mirna_pipeline/blob/master/limma_output)
(at least 750 reads mapped to a microRNA in all samples in total),
all microRNAs were identified as significantly differentially.
expressed Even when run for 1500
[microRNAs](https://github.com/jknightlab/mirna_pipeline/blob/master/limma_output_full),
(at least 1 read mapped to each microRNA in at least one of
the samples), *limma* gave significant pvalues. For absolutely
each microRNA.

As any other statistical test, ANOVA works best when the
assumptions -- in case of ANOVA, normal distribution of the
data and comparable standard deviation -- are true for the
analyzed dataset. Unfortunately, for this dataset the
number of expressed microRNAs and the levels of expression
are very low, which makes the data non-randomly distributed
(maybe rather a Poisson distribution?). Additionally, the
level of noise increases when the signal (number of mapped
reads) is so low.

*Thirdly*, we ignored pvalues and applied cutoffs on miRNA expression
under each condition and the fold change to create a list of miRNA
candidates for future experimental validation.

Filtering steps:
- remove lines containing `NA` -- this means that miRNA expression was
zero under both conditions.
- remove lines containing `Inf` -- this means that zero reads was mapped
in one of the samples. Genes and miRNAs never get absolute zero
expression (unless they are knocked out), so when zero reads map to an
miRNA, this indicates that not enough miRNA was sequenced or this
particular miRNA was not captured -- but not that it is 100% silenced.
- log2foldChange should be either below -2 or above 2 -- such filter
is common practice in any differential expression analysis (also for
genes), as it is believed/assumed that qPCR won''t capture smaller
differences in expression.
- average miRNA expression under one condition (`baseMeanA`) should be
above 5 -- lower expression probably won't be accurately measured by
qPCR.
- average miRNA expression under the second condition (`baseMeanB`)
should be above 5.

Commands used for filtering and creating candidate lists can be found
[here](https://github.com/jknightlab/mirna_pipeline/blob/master/Filtering_steps_code.md).

This figure illustrates which fold changes we select. All log2 of fold
changes are shown in black, the selected ones (above 2 or below -2) are
shown in red.

![alt text](https://github.com/jknightlab/mirna_pipeline/blob/master/HC_Th17_vs_AS_Th17_log2FC_scatter.png) 

This table contains number of miRNAs remaining after each filtering
step in each pairwise comparison.

| <sub>Filtering steps</sub> | <sub>HC Th17 vs HC nonTh17</sub>* | <sub>AS Th17 vs AS nonTh17</sub> | <sub>HC Th17 vs AS Th17</sub> | <sub>HC nonTh17 vs AS nonTh17</sub> | <sub>HC nonTh17 vs AS Th17</sub> | <sub>HC Th17 vs AS nonTh17</sub> |
| --------------- | ---- | ---- | ---- | ---- | ---- | ---- |
| initially       | 2576 | 2576 | 2576 | 2576 | 2576 | 2576 | 
| no NA           | 897  | 888  | 845  | 965  | 880  | 953  |
| no Inf          | 632  | 546  | 504  | 649  | 514  | 616  |
| log2FoldChange  | 70   | 63   | 70   | 66   | 90   | 93   |
| baseMeanA       | 4    | 12   | 27   | 13   | 28   | 15   |
| baseMeanB       | 2    | 1    | 11   | 5    | 13   | 8    |

`*` used cutoff of 4 instead of 5 at the baseMeanA step (one
of the potential candidate miRNAs had expression of 4.87).

Lists of miRNA candidates for validation can be found here: 

- [HC_Th17 vs HC_nonTh17](https://github.com/jknightlab/mirna_pipeline/blob/master/candidates_HC_Th17_VS_HC_nonTh17.txt)
- [HC_Th17 vs AS_Th17](https://github.com/jknightlab/mirna_pipeline/blob/master/candidates_HC_Th17_VS_AS_Th17.txt)
- [HC_Th17 vs AS_nonTh17](https://github.com/jknightlab/mirna_pipeline/blob/master/candidates_HC_Th17_VS_AS_nonTh17.txt)
- [HC_nonTh17 vs AS_Th27](https://github.com/jknightlab/mirna_pipeline/blob/master/candidates_HC_nonTh17_VS_AS_Th17.txt)
- [HC_nonTh17 vs AS_nonTh27](https://github.com/jknightlab/mirna_pipeline/blob/master/candidates_HC_nonTh17_VS_AS_nonTh17.txt)
- [AS_Th17 vs AS_nonTh17](https://github.com/jknightlab/mirna_pipeline/blob/master/candidates_AS_Th17_VS_AS_nonTh17.txt)

### Compare RNA-Seq and qPCR results

Four microRNAs -- **miR-155-5p**, **miR-146a-5p**, **miR-210-3p**
and **miR-21-5p** -- were previously experimentally validated with
qPCR. None of these microRNAs showed significant differences in
expression across different conditions due to the low fold change.
However, we decided to check expression levels of these miRNAs.
Here we compared changes in relative expression of these
microRNAs in qPCR vs RNA-Seq data (results of qPCR experiments
were provided by Taejong Kim). Unfortunately the results of
miRNA sequencing do not confirm the resuts of qPCR.

| miR-155-5p | HC Th17 | HC nonTh17 | AS Th17 | AS non Th17 | 
| ---------- | ------- | ---------- | ------- | ----------- |
| RNA-Seq    | 34,084  | 28,681     | 19,189  | 11,178      |
| qPCR       | 7.1     | 1.5        | 48      | 1           |

| miR-146a-5p| HC Th17 | HC nonTh17 | AS Th17 | AS non Th17 |
| ---------- | ------- | ---------- | ------- | ----------- |
| RNA-Seq    | 7,641   | 4,664      | 17,742  | 14,838      |
| qPCR       | 8.8     | 1.5        | 4.2     | 1           |

| miR-210-3p | HC Th17 | HC nonTh17 | AS Th17 | AS non Th17 |
| ---------- | ------- | ---------- | ------- | ----------- |
| RNA-Seq    | 33      | 43         | 40      | 35          |
| qPCR       | 11.2    | 2          | 25.5    | 2.1         |

| miR-21-5p | HC Th17  | HC nonTh17 | AS Th17 | AS non Th17 |
| --------- | -------- | ---------- | ------- | ----------- |
| RNA-Seq   | 286,653  | 175,452    | 239,449 | 211,160     |
| qPCR      | 9.5      | 2.4        | 1.4     | 0.7         |


![alt text](https://github.com/jknightlab/mirna_pipeline/blob/master/miR-155-5p_miR-146a-5p.png)

![alt text](https://github.com/jknightlab/mirna_pipeline/blob/master/miR-210-3p_miR-21-5p.png)




#### Designed by Irina Pulyakhina irina@well.ox.ac.uk
