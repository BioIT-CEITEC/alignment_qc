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

version = str(subprocess.Popen("conda list", shell=True, stdout=subprocess.PIPE).communicate()[0], 'utf-8')
f = open(log_filename, 'at')
f.write("## CONDA: "+version+"\n")
f.close()
    
command = f"$(which time) --verbose run_spp.R"+\
          " -c={snakemake.input.bam}"+\
          " -savp={snakemake.output.plot}"+\
          " -out={snakemake.output.stat}"+\
          " -tmpdir={snakemake.params.tmpd}"+\
          " >> {log_filename} 2>&1"
f = open(log_filename, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)

# command = "sed -i '1i \#Name\tNumMappedReads\tEstFragLen\tEstFragLenCorr\tReadLen\tReadLenCorr\tMinCrossCorrInsertSize\tMinCrossCorrValue\tNSC\tRSC\tQTag' "+snakemake.output.stat+" >> "+log_filename+" 2>&1"
# f = open(log_filename, 'at')
# f.write("## COMMAND: "+command+"\n")
# f.close()
# shell(command)

