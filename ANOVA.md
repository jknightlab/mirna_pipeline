# mirna_pipeline
--------------------------------------
Bioinformatic pipeline to analyze micro RNA sequencing data

### ANOVA and *limma*

ANOVA – analysis of variants – is a statistical test which, while analyzing more than two datasets, can point at observations which are different between at least two of the analyzed groups. When we want to compare microRNA expression between more than two conditions, a statistical `R` package [*limma*](http://www.bioconductor.org/packages/release/bioc/html/limma.html) can be used.

### Preparing for *limma*

*limma* requires files with count data without low counts or zero counts. Looking at all identified [microRNAs](https://github.com/jknightlab/mirna_pipeline/blob/master/mirna_matrix_no_285.xls), there are 2,577 human microRNAs in the list; 1,055 of them had at least one read in at least one sample mapped to them; 899 microRNAs have more than 1 read mapped to them; 497 microRNAs – more than 10 reads; 239 microRNAs – more than 100 reads; 116 microRNAs – more than 750 reads. *750* was taken as a cutoff – when more than 750 reads were mapped to a microRNA, this line from the input file was selected for further analysis. This way on average at least 50 reads were mapped to a microRNA in each sample.

```
cat mirna_matrix_no_285_DESeq_intput.txt | awk '$2+$3+$4+$5+$6+$7+$8+$9+$10+$11+$12+$13+$14+$15 > 750 {print $0}' | awk '{print $1 "\t" $2 "\t" $4 "\t" $6 "\t" $8 "\t" $3 "\t" $5 "\t" $7 "\t" $9 "\t" $10 "\t" $12 "\t" $13 "\t" $14 "\t" $11 "\t" $15}' >> limma_input
```

### Running *limma*

Note that **edgeR** also needs to be uploaded!

*limma* userguide can be found [here]
(http://www.bioconductor.org/packages/release/bioc/vignettes/limma/inst/doc/usersguide.pdf)

In `R`:
```
source("http://bioconductor.org/biocLite.R")
biocLite("limma")
library(limma)

#uploading the data
counts <- read.delim("limma_input", header=TRUE)
rownames(counts) <- counts$mirna
counts <- counts[,-1]

# creating a DGE object to make it convenient to perform TMM normalization
dge <- DGEList(counts=counts)
dge <- calcNormFactors(dge)

design <- rbind(c(1,0,0,0), c(1,0,0,0), c(1,0,0,0), c(1,0,0,0), c(0,1,0,0), c(0,1,0,0), c(0,1,0,0), c(0,1,0,0), c(0,0,1,0), c(0,0,1,0), c(0,0,1,0), c(0,0,1,0), c(0,0,0,1), c(0,0,0,1))

# applying the voom transformation
v <- voom(dge,design,plot=TRUE)

# for very noisy data, which our is:
png("normalization_expressed_mirnas.png")
v <- voom(counts,design,plot=TRUE,normalize="quantile")
dev.off()

# standard limma pipeline for differential expression analysis
fit <- lmFit(v,design)
fit <- eBayes(fit)
topTable(fit,coef=ncol(design))

write.table(fit, file="limma_output", quote=FALSE, sep="\t")
```


#### Designed by Irina Pulyakhina irina@well.ox.ac.uk
