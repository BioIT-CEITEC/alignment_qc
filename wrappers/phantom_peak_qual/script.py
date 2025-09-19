#########################################
# wrapper for rule: phantom_peak_qual
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
f.write("\n##\n## RULE: phantom_peak_qual \n##\n")
f.close()

version = str(subprocess.Popen("conda list 2>&1", shell=True, stdout=subprocess.PIPE).communicate()[0], 'utf-8')
f = open(log_filename, 'at')
f.write("## CONDA:\n"+version+"\n")
f.close()

command = "$(which time) run_spp.R"+\
          " -c="+snakemake.input.bam+\
          " -savp="+snakemake.output.plot+\
          " -out="+snakemake.output.stat+\
          " -tmpdir="+snakemake.params.tmpd+\
          " >> "+log_filename+" 2>&1"
f = open(log_filename, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)
