suppressPackageStartupMessages(library(ggplot2))
suppressPackageStartupMessages(library(GGally))
suppressPackageStartupMessages(library(plotly))
suppressPackageStartupMessages(library(htmlwidgets))


run_all <- function(output_file_base,cross_sample_data){
  
  load(cross_sample_data)
  if(exists("m1") && exists("m2")){
    cat(m1,file = paste0(output_file_base,".snps.tsv"))
    cat(m2,file = paste0(output_file_base,".snps.html"))
  } else {
    print_plotly(snps_matrix,"snps")
    print_plotly(var_freq_matrix,"var_freq")
  
    pdf(file = paste0(output_file_base,".scatter_matrix.pdf"),width = 14,height = 14)
    print(ggpairs(cast_variant_freq,columns = 3:ncol(cast_variant_freq)))
    dev.off()
  }
  
}

print_plotly <- function(round_matrix,value.var){
  write.table(round_matrix,sep = "\t",col.names = NA,file = paste0(output_file_base,".",value.var,".tsv"))
  p <- plot_ly(x = colnames(round_matrix),y = rownames(round_matrix),z = round_matrix, type = "heatmap")
  saveWidget(as_widget(p), paste0(output_file_base,".",value.var,".html"))
}


#to test
# output_file_base <- "test.cross_sample_correlation"
# vcf_files <- list.files(path = "/mnt/ssd/ssd_1/snakemake/library1314_170331_MOII_e15_tkane_20170331/map_qc/cross_sample_correlation/",pattern = ".snp.vcf",full.names = T)

#to run
args <- commandArgs(trailingOnly = T)
output_file_base <- args[1]
cross_sample_data <- args[2]
run_all(output_file_base,cross_sample_data)

