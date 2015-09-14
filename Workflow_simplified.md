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




#### Designed by Irina Pulyakhina irina@well.ox.ac.uk
