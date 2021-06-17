
out_name <- commandArgs(trailingOnly = T)[1]

#rmarkdown::rmarkdown_format("+smart")
rmarkdown::render(input=out_name,output_format='html_document',quiet=T)
