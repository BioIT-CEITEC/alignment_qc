#
# Visualize featureCounts gene biotypes output - need parsed featureCounts output where each column represents sample and contains number of reads assigned to each feature
#

#setwd("/home/vasek/Documents/Dokumenty/phd/app_server/snakemake_test/")
#args <- c("bagr.pdf","v1Scrambled1.biotype_counts.txt")

args <- commandArgs(trailingOnly = TRUE)
outfile <- args[1]
featureCounts <- read.table(args[2], header=T, stringsAsFactors = F)
if (length(args) > 2) {
  for (i in 3:length(args)){
    sample <- read.table(args[i], header=T, stringsAsFactors = F)
    featureCounts <- merge(featureCounts,sample,by = "Geneid")
  }
}
row.names(featureCounts) <- featureCounts$Geneid
featureCounts$Geneid <- NULL
featureName<-strsplit(colnames(featureCounts), "[.]")[[1]][4] # Get analysis name

colnames(featureCounts)<-sapply(args[-1],function(x) gsub(".biotype_counts.txt","",basename(x)))  # Rename columns - split after first "_"

# Plot Pie plot for each sample
pdf(file=paste0(outfile), width = 10, height = 6)
par(mfrow=c(2,2))

for(featureColumnNum in 1:(ncol(featureCounts))){
  featureColumnMain<-as.matrix(featureCounts[, featureColumnNum]) # Get one column from the input
  pctMain<-round(featureColumnMain/(sum(featureColumnMain)/100), 2) # Make labels with percentages
  
  # Merge features < 5% to others, otherwise to many lables 
  pct<-pctMain[pctMain>=2] # Get abundant features
  pct<-c(pct, sum(pctMain[pctMain<2])) # Other features - added together to one
  lbls<-rownames(featureCounts)[pctMain>=2] # Labels
  lbls<-c(lbls, "other")
  lbls<-paste(lbls, pct) 
  lbls <- paste(lbls, "%", sep="") # ad % to labels     
  
  featureColumn<-featureColumnMain[pctMain>=2] # Get subset of the main table for the abundant
  featureColumn<-c(featureColumn, sum(featureColumnMain[pctMain<2])) # Get the others
  tryCatch({
    pie(featureColumn, labels = lbls, col=rainbow(length(lbls)), main=paste("Pie Chart of Gene Biotypes", 
      colnames(featureCounts)[featureColumnNum], sum(featureColumnMain), sep="\n"),cex=0.7)
  }, error=function(e){})
}
dev.off()
