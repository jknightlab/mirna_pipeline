Differential microRNA expression
--------------------------------------

#### Analysis workflow

Reads were mapped to the GRC37 reference sequence with `tophap2`. Duplicates
and non-unique reads were removed using `samtools`. Counts per gene were
assigned using `htseq-count`. Differential expression analysis was performed
with `DESeq2`.


#### Quality control

Eight mRNA samples were sequenced on HiSeq4000 using paired-edn sequencing
protocol (2x75bp). Data quality looks good, more than 10 mln reads mapped to
known genes for each samples, average duplication rate 25%.


| sequencing id    | sample name       | sequenced reads | mapped reads | nodup reads | uniq reads | reads mapped to genes | % reads mapped to genes of nodup |
| ---------------- | ----------------- | ---------- | ---------- | ---------- | ---------- | ---------- | ---- |
| WTCHG_260126_201 | miR-cont1(Kim)    | 33,118,323 | 28,940,226 | 22,861,259 | 20,903,213 | 18,655,111 | 81.6 |
| WTCHG_260126_202 | miR-cont2(Jeon)   | 40,382,477 | 35,098,464 | 26,064,426 | 23,685,281 | 22,279,843 | 85.5 |
| WTCHG_260126_203 | miR-cont3(Paul)   | 36,883,161 | 31,867,272 | 23,090,486 | 20,716,797 | 20,086,531 | 87   |
| WTCHG_260126_204 | miR-cont4(L-cone) | 32,600,347 | 28,311,673 | 21,460,462 | 19,431,429 | 18,548,390 | 86.4 |
| WTCHG_260126_205 | miR-10b1(Kim)     | 35,065,691 | 30,709,386 | 24,134,327 | 22,100,297 | 19,870,114 | 82.3 |
| WTCHG_260126_206 | miR-10b2(Jeon)    | 37,596,944 | 32,653,080 | 24,289,556 | 22,019,957 | 20,762,385 | 85.5 |
| WTCHG_260126_207 | miR-10b3(Paul)    | 38,668,642 | 33,371,257 | 23,685,806 | 21,237,491 | 20,725,176 | 87.5 |
| WTCHG_260126_208 | miR-10b4(L-cone)  | 37,182,862 | 32,017,247 | 23,593,110 | 21,280,150 | 20,862,969 | 88.4 |


#### Differential expression analysis

Unfortunately differential gene expression analysis did not discover any
significant hits. All genes had p-values between 0.01 and 0.99 and adjusted
p-values of 0.99. When we looked at the correlation between each gene
expression under two conditions (miR-cont and miR-10b), we saw that there was
indeed almots now difference in gene expression (Pearson correlation
coefficient 0.9995 with p-value < 2.2e-16).

![alt text](https://github.com/jknightlab/mirna_pipeline/blob/master/mRNA/gene_expression_correlation.png)

When we look at the fold change, we can see that the vast majority of genes
have a fold change around 1; a handful of genes which has higher/lower fold
change are extremely lowly expressed genes (which, therefore, also were not
significantly different).

![alt text](https://github.com/jknightlab/mirna_pipeline/blob/master/mRNA/fold_change.png)


Differential expression analysis results can be found
[here](https://github.com/jknightlab/mirna_pipeline/blob/master/mRNA/miR-10b.miR-cont.DE_results.txt).
Normalized gene expression can be found
[here](https://github.com/jknightlab/mirna_pipeline/blob/master/mRNA/miR-10b.miR-cont.normalized_counts.txt).



#### Designed by Irina Pulyakhina irina@well.ox.ac.uk
