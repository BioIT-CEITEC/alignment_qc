#############################################################
# wrapper for rule: cross_sample_correlation_viz
#############################################################
import os
from snakemake.shell import shell
shell.executable("/bin/bash")
log_filename = str(snakemake.log)

f = open(log_filename, 'wt')
f.write("\n##\n## RULE: cross_sample_correlation_viz \n##\n")
f.close()

output_file = snakemake.input.Rdata_for_viz.replace(".Rdata","")

command = " Rscript  " + os.path.abspath(os.path.dirname(__file__)) + "/cross_sample_correlation_viz.R " \
                       + " " + output_file + " " \
                       + snakemake.input.Rdata_for_viz \
                       + " 2>> " + log_filename
f = open(log_filename, 'a+')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)