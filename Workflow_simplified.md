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

*Checking quality control on initial fastq files*
An example report of quality checks on initial `fastq`
files for the sample AS2-Th17 can be found
[here](https://github.com/jknightlab/mirna_pipeline/blob/master/WTCHG_189136_285_1_fastqc.html).
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

*Cleaning the fastq files*
Identified adapters were removed from the 5' end of reads,
reads shorter than 15 or longer than 35 nucleotides were
discarded.

*Checking quality control on trimmed fastq files*
An example report of quality checks on trimmed `fastq`
files for the sample AS2-Th17 can be found
[here](https://github.com/jknightlab/mirna_pipeline/blob/master/WTCHG_189136_285_1.trimmed_fastqc.html).
We can see that only sequence duplication level (and for some
files -- per nucleotide sequence content) still fail -- as
expected (see above). Note that reads which are too short or
too long after removing adapters will be discarded, so the
number of reads in a file can change. This table contains the
information on the number of reads before and after cleaning.

| Sample type | File name1       | Before trim| After trim | File name2       | Before trim| After trim |
| ----------- | ---------------- | ---------- | ---------- | ---------------- | ---------- | ---------- |
| HC1-nonTh17 | WTCHG_189135_274 | 16,658,312 | 10,307,964 | WTCHG_189136_274 | 17,111,904 | 10,735,176 |
| HC2-nonTh17 | WTCHG_189135_276 | 23,180,836 | 12,294,948 | WTCHG_189136_276 | 23,817,544 | 12,692,556 | 
| HC3-nonTh17 | WTCHG_189135_278 | 28,641,100 | 14,340,808 | WTCHG_189136_278 | 29,263,204 | 14,677,208 |
| HC4-nonTh17 | WTCHG_189135_280 | 27,021,828 | 14,380,188 | WTCHG_189136_280 | 27,634,528 | 14,715,880 |
|             |                  |            |            |                  |            |            |
| HC1-Th17    | WTCHG_189135_275 | 18,712,164 | 11,088,016 | WTCHG_189136_275 | 19,226,884 | 11,487,684 |
| HC2-Th17    | WTCHG_189135_277 | 25,634,288 | 12,997,776 | WTCHG_189136_277 | 26,178,792 | 13,286,152 |
| HC3-Th17    | WTCHG_189135_279 | 24,934,788 | 12,534,560 | WTCHG_189136_279 | 25,451,552 | 12,808,388 |
| HC4-Th17    | WTCHG_189135_281 | 36,458,196 | 20,089,092 | WTCHG_189136_281 | 37,117,612 | 20,519,576 |
|             |                  |            |            |                  |            |            |
| AS1-nonTh17 | WTCHG_189135_282 | 77,242,220 | 43,030,708 | WTCHG_189136_282 | 79,433,628 | 44,313,332 |
| AS2-nonTh17 | WTCHG_189135_284 | 20,299,204 | 13,918,564 | WTCHG_189136_284 | 20,800,688 | 14,275,212 |
| AS3-nonTh17 | WTCHG_189135_286 | 23,372,832 | 14,729,640 | WTCHG_189136_286 | 23,979,804 | 15,319,740 |
| AS4-nonTh17 | WTCHG_189135_288 | 31,656,996 | 16,691,080 | WTCHG_189136_288 | 32,283,960 | 17,033,808 |
|             |                  |            |            |                  |            |            |
| AS1-Th17    | WTCHG_189135_283 | 30,916,908 | 16,576,272 | WTCHG_189136_283 | 31,723,492 | 17,048,232 |
| AS2-Th17    | WTCHG_189135_285 | 23,164,272 | 19,867,816 | WTCHG_189136_285 | 23,761,664 | 20,393,544 |
| AS4-Th17    | WTCHG_189135_289 | 39,985,232 | 30,642,800 | WTCHG_189136_289 | 41,047,460 | 31,462,132 |







#### Designed by Irina Pulyakhina irina@well.ox.ac.uk
