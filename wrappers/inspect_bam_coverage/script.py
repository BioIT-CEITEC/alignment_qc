#########################################
# wrapper for rule: inspect_bam_coverage
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
f.write("\n##\n## RULE: inspect_bam_coverage \n##\n")
f.close()

version = str(subprocess.Popen("conda list", shell=True, stdout=subprocess.PIPE).communicate()[0], 'utf-8')
f = open(log_filename, 'at')
f.write("## CONDA: "+version+"\n")
f.close()

extra = ""
if str(snakemake.params.effective_GS) != "unk":
  extra = "--effectiveGenomeSize "+str(snakemake.params.effective_GS)

if str(snakemake.params.frag_len) != "unk":
  extra = extra+" --extendReads "+str(snakemake.params.frag_len)

command = "export TMPDIR="+snakemake.params.tmpd+";"+\
          "bamCoverage"+\
          " -b "+snakemake.input.bam+\
          " -bs 5"+\
          " -o "+snakemake.output.bw+\
          " -p "+str(snakemake.threads)+\
          " "+extra+\
          " >> "+log_filename+" 2>&1"
f = open(log_filename, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)
