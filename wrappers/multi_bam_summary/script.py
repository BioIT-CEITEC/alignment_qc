#########################################
# wrapper for rule: multi_bam_summary
#########################################
import os
import sys
import math
import subprocess
import re
from snakemake.shell import shell

shell.executable("/bin/bash")
log_filename = str(snakemake.log)

f = open(log_filename, 'a+')
f.write("\n##\n## RULE: multi_bam_summary \n##\n")
f.close()

version = str(subprocess.Popen("conda list 2>&1", shell=True, stdout=subprocess.PIPE).communicate()[0], 'utf-8')
f = open(log_filename, 'at')
f.write("## CONDA:\n"+version+"\n")
f.close()

ignore_dups = ""

command = "$(which time) multiBamSummary bins"+\
          " -bs 10000"+\
          " "+ignore_dups+\
          " --smartLabels"+\
          " -p "+str(snakemake.threads)+\
          " -o "+str(snakemake.params.matrix)+\
          " -b "+" ".join(snakemake.input.bam)+\
          " >> "+log_filename+" 2>&1"
f = open(log_filename, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)

command = "$(which time) plotCorrelation"+\
          " -in "+str(snakemake.params.matrix)+\
          " --whatToPlot heatmap"+\
          " --corMethod "+snakemake.params.corr_method+\
          " -o "+snakemake.output.plot+\
          " --outFileCorMatrix "+snakemake.output.table+\
          " --plotNumbers"+\
          " >> "+log_filename+" 2>&1"
f = open(log_filename, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)

command = "$(which time) plotFingerprint"+\
          " --outQualityMetrics "+snakemake.output.quality+\
          " --outRawCounts "+snakemake.output.counts+\
          " --smartLabels"+\
          " "+ignore_dups+\
          " -p "+str(snakemake.threads)+\
          " -o "+snakemake.output.finger+\
          " -b "+" ".join(snakemake.input.bam)+\
          " >> "+log_filename+" 2>&1"
f = open(log_filename, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)

