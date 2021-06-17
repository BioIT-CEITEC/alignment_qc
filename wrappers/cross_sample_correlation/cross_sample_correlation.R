suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(vcfR))
suppressPackageStartupMessages(library(proxy))
# suppressPackageStartupMessages(library(ggplot2))
# suppressPackageStartupMessages(library(GGally))
# suppressPackageStartupMessages(library(plotly))
# suppressPackageStartupMessages(library(htmlwidgets))

MIN_SNPS_COUNT <<- 20
MIN_SNPS_COUNT_RATIO_TO_LIB_MEAN <<- 0.01
MIN_VALUES_TO_CORELATE <<- 5

run_all <- function(args){
  output_file <- args[1]
  vcf_files <- args[-1]
  if(length(vcf_files) > 1 & all(file.size(vcf_files) > 0)){
    
    all_snps <- lapply(vcf_files,function(vcf_file){

      vcf <- read.vcfR(vcf_file,verbose = F)
      sample <- gsub(".*\\/(.*)\\.snp.vcf$","\\1",vcf_file)
      if(nrow(vcf@fix) > 5){
        res <- data.table(sample = sample
                          ,chr = vcf@fix[,"CHROM"]
                          ,pos = as.integer(vcf@fix[,"POS"])
                          ,var_freq = extract.gt(vcf,element = "AD",as.numeric = T)[,1]
                          ,depth = extract.gt(vcf,element = "AD")[,1])
        
        res[,depth := sapply(strsplit(depth,","),function(x) sum(as.numeric(x[1:2])))]
        res[,var_freq := (depth - var_freq) / depth]
        res[,snps := round(var_freq * 2) / 2]
        
        res <- unique(res,by = c("sample","chr","pos"))
        return(res)
      }
      else return(NULL)

    })
    
    if(!all(sapply(all_snps,is.null))){
      all_snps <- rbindlist(all_snps)
      
      all_snps <- all_snps[depth > 2,]
      
      OK_samples <- all_snps[,.N,by = sample][N > mean(all_snps[,.N,by = sample]$N) * MIN_SNPS_COUNT_RATIO_TO_LIB_MEAN & N > MIN_SNPS_COUNT]$sample
      all_snps <- all_snps[sample %in% OK_samples]

      test_overlap_matrix <- as.matrix(dcast.data.table(all_snps,chr + pos ~ sample,value.var = "depth",fill = 0)[,!c(1,2)])
      test_overlap_matrix <- sign(test_overlap_matrix)
      test_overlap_matrix <- simil(test_overlap_matrix,method = function(x,y) {sum(x*y)},by_rows = F,diag = T,upper = T)
      test_overlap_matrix <- as.matrix(test_overlap_matrix)
      test_overlap_matrix[is.na(test_overlap_matrix)] <- 1

      if(any(test_overlap_matrix < MIN_VALUES_TO_CORELATE)){
        not_OK_samples_vec <- logical(nrow(test_overlap_matrix))
        while(any(test_overlap_matrix[!not_OK_samples_vec,!not_OK_samples_vec] < MIN_VALUES_TO_CORELATE) && sum(!not_OK_samples_vec) > 1){
          worse_sample <- which.max(apply(test_overlap_matrix[!not_OK_samples_vec,!not_OK_samples_vec],1,function(x) sum(x < MIN_VALUES_TO_CORELATE)))
          not_OK_samples_vec[!not_OK_samples_vec][worse_sample] <- T
        }
        all_snps <- all_snps[sample %in% rownames(test_overlap_matrix)[!not_OK_samples_vec]]
      }
      
      if(nrow(all_snps) > 0 && length(unique(all_snps$sample)) > 1){
        cast_variant_freq <- dcast.data.table(all_snps,formula = chr + pos ~ sample,value.var = "var_freq",fill = NA)
        snps_matrix <- print_plotly(all_snps,"snps")
        var_freq_matrix <- print_plotly(all_snps,"var_freq")
        
        save(snps_matrix,var_freq_matrix,cast_variant_freq,file = output_file)
      } else {
        m1 <- "not enough SNPs in the data intervals to asses sample correlation"
        m2<- '<font size="3" color="red">not enough SNPs in the data intervals to asses sample correlation</font>'
        save(m1,m2,file = output_file)
      }
    } else {
      m1 <- "not enough SNPs in the data intervals to asses sample correlation"
      m2<- '<font size="3" color="red">not enough SNPs in the data intervals to asses sample correlation</font>'
      save(m1,m2,file = output_file)
    }

    
  } else {
    m1 <- "Only 1 sample in library or SNPs not called in the samples (SNPs not known for the organism)"
    m2 <- '<font size="3" color="red">only 1 sample in library or SNPs not called in the samples (SNPs not known for the organism)</font>'
    save(m1,m2,file = output_file)
  }
}

print_plotly <- function(all_snps,value.var){
  matrix <- as.matrix(dcast.data.table(all_snps,chr + pos ~ sample,value.var = value.var,fill = NA)[,!c(1,2)])
  sim_matrix <- as.matrix(simil(matrix,method = cor,by_rows = F,diag = T,upper = T,use = "complete.obs"))
  diag(sim_matrix) <- 1
  sim_matrix[sim_matrix < 0] <- 0
  
  round_matrix <- round(sim_matrix,3)
  return(round_matrix)
}



#to run
args <- commandArgs(trailingOnly = T)
run_all(args)

