#########################################
# wrapper for rule: dedup_bam
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
f.write("\n##\n## RULE: dedup_bam \n##\n")
f.close()

version = str(subprocess.Popen("conda list", shell=True, stdout=subprocess.PIPE).communicate()[0], 'utf-8')
f = open(log_filename, 'at')
f.write("## CONDA: "+version+"\n")
f.close()


command = "(time samtools view -b -h -F 1024"+\
          " -@ "+str(snakemake.threads)+\
          " "+snakemake.input.bam+\
          ") > "+snakemake.output.bam+\
          " 2>> "+log_filename+\
          " && (time samtools index"+\
          " -@ "+str(snakemake.threads)+\
          " "+snakemake.output.bam+\
          ") >> "+log_filename+" 2>&1"
f = open(log_filename, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)
