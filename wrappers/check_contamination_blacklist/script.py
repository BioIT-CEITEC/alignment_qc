######################################
# wrapper for rule: check_contamination_blacklist
######################################
import os
import sys
import math
import subprocess
import re
from snakemake.shell import shell

shell.executable("/bin/bash")
log_filename = str(snakemake.log)

f = open(log_filename, 'a+')
f.write("\n##\n## RULE: check_contamination_blacklist \n##\n")
f.close()

version = str(subprocess.Popen("conda list", shell=True, stdout=subprocess.PIPE).communicate()[0], 'utf-8')
f = open(log_filename, 'at')
f.write("## CONDA: "+version+"\n")
f.close()

command = "samtools view"+\
          " -@ "+str(snakemake.threads)+\
          " -L "+snakemake.input.lst[0]+\
          " -U "+snakemake.output.bam_ok+\
          " -b -h "+snakemake.input.bam+\
          " > "+snakemake.output.bam_fail+\
          " 2>> "+log_filename
f = open(log_filename, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)

