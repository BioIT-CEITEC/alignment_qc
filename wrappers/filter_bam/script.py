#########################################
# wrapper for rule: filter_bam
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
f.write("\n##\n## RULE: filter_bam \n##\n")
f.close()

if str(snakemake.params.qc_cutof) == "nan":
  raise Exception("quality_cutoff is wrongly set")

version = str(subprocess.Popen("conda list 2>&1", shell=True, stdout=subprocess.PIPE).communicate()[0], 'utf-8')
f = open(log_filename, 'at')
f.write("## CONDA:\n"+version+"\n")
f.close()

bad_tags = 772 # combination of read_unmapped, not_primary_alignment and read_fails_platform/vendor_quality_checks

if hasattr(snakemake.input, 'bed'):
  command = "$(which time) samtools view"+\
            " -@ "+str(snakemake.threads)+\
            " -q "+str(snakemake.params.qc_cutof)+\
            " -F "+str(bad_tags)+\
            " -b -h "+snakemake.input.bam+\
            " 2>> "+log_filename+\
            " | "+\
            "$(which time) samtools view"+\
            " -@ "+str(snakemake.threads)+\
            " -L "+snakemake.input.bed+\
            " -U "+snakemake.output.bam+\
            " -b -h -"+\
            " > "+snakemake.output.bam_fail+\
            " 2>> "+log_filename
else:
  command = "$(which time) samtools view"+\
            " -@ "+str(snakemake.threads)+\
            " -q "+str(snakemake.params.qc_cutof)+\
            " -F "+str(bad_tags)+\
            " -U "+snakemake.output.bam_fail+\
            " -b -h "+snakemake.input.bam+\
            " > "+snakemake.output.bam+\
            " 2>> "+log_filename
f = open(log_filename, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)

command = "$(which time) samtools index -@ "+str(snakemake.threads)+" "+snakemake.output.bam+" >> "+log_filename+" 2>&1"
f = open(log_filename, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)
