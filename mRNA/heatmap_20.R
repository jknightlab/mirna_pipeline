library(reshape2)
library(gplots)

genes <- read.table("counts_for_big_heatmap.txt", header=FALSE, sep='\t', row.names=1)
genes.M <- as.matrix(genes)
genes.M <- t(scale(t(genes.M)))
my_palette <- colorRampPalette(c("royalblue", "yellow"))(n = 50)


hr <- hclust(as.dist(1-cor(t(genes.M), method="pearson")), method="complete")
hc <- hclust(as.dist(1-cor(genes.M, method="spearman")), method="complete")

heatmap.2(nba_matrix, col = my_palette, scale="row",
Rowv=FALSE,Colv=FALSE, trace='none',
          symkey=FALSE, 
          symbreaks=FALSE, 
          dendrogram='none',
          cexRow=2,
          cexCol=2,
          density.info='none', 
          denscol=tracecol,
margins=c(10, 14))

