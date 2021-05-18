#############################################################
# wrapper for rule: cross_sample_correlation
#############################################################
import os
from snakemake.shell import shell

f = open(snakemake.log.run, 'wt')
f.write("\n##\n## RULE: cross_sample_correlation \n##\n")
f.close()


command = " Rscript  " + os.path.abspath(os.path.dirname(__file__)) + "/cross_sample_correlation.R " \
                       + " " + snakemake.params.output + " " \
                       + " ".join(snakemake.input.vcfs) \
                       + " 2>> " + snakemake.log.run
f = open(snakemake.log.run, 'a+')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)
