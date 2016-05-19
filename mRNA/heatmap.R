args <- commandArgs(T)
input_parameter <- args[1]
input_name <- args[2]
output_name <- args[3]

library(reshape2)
library(gplots)

data <- read.table(input_parameter, sep='\t', header=FALSE)


nba_matrix <- data.matrix(data)
my_palette <- colorRampPalette(c("royalblue", "yellow"))(n = 50)

rownames(nba_matrix) <- c("ctrl1", "ctrl2", "ctrl3", "ctrl4", "miR1", "miR2", "miR3", "miR4")
colnames(nba_matrix) <- c("ctrl1", "ctrl2", "ctrl3", "ctrl4", "miR1", "miR2", "miR3", "miR4")

my_palette <- colorRampPalette(c("royalblue", "yellow"))(n = 50)
pdf(output_name)
heatmap.2(nba_matrix, dendrogram='none', Rowv=FALSE, Colv=FALSE,trace='none', density.info="none", main=input_name, tracecol=NA, col=my_palette, labRow=rownames(nba_matrix), margins=c(10, 10), cexRow=2, cexCol=2, keysize = 1)
dev.off()

