data <- read.table("input_for_kruskal_wallis.txt", sep="\t", header=TRUE)

full <- data.frame()

for (i in seq(1:length(data[,1])))
{
kw_results <- kruskal.test(c(data[i,2], data[i,3], data[i,4], data[i,5]),
 c(data[i,6], data[i,7], data[i,8], data[i,9]), c(data[i,10], data[i,11],
 data[i,12], data[i,13]), c(data[i,14], data[i,15]))
full <- rbind (full,  cbind(data[i,], kw_results$p.value) )
}

write.table(full, file="kruskal_wallis_results", sep="\t", quote=FALSE, row.names=FALSE)

