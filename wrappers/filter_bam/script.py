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

version = str(subprocess.Popen("conda list 2>&1", shell=True, stdout=subprocess.PIPE).communicate()[0], 'utf-8')
f = open(log_filename, 'at')
f.write("## CONDA:\n"+version+"\n")
f.close()

bad_tags = 4 # read_unmapped
command = "$(which time) samtools stats"+\
            " -@ "+str(snakemake.threads)+\
            " -F "+str(bad_tags)+\
            " "+snakemake.input.bam+\
            " > "+snakemake.params.prefix+".f1_unmap.stats"+\
            " 2>> "+log_filename
f = open(log_filename, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)

bad_tags = 260 # read_unmapped + not_primary_alignment
command = "$(which time) samtools stats"+\
            " -@ "+str(snakemake.threads)+\
            " -F "+str(bad_tags)+\
            " "+snakemake.input.bam+\
            " > "+snakemake.params.prefix+".f2_second.stats"+\
            " 2>> "+log_filename
f = open(log_filename, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)

bad_tags = 772 # read_unmapped + not_primary_alignment + read_fails_platform/vendor_quality_checks
command = "$(which time) samtools stats"+\
            " -@ "+str(snakemake.threads)+\
            " -F "+str(bad_tags)+\
            " "+snakemake.input.bam+\
            " > "+snakemake.params.prefix+".f3_failqc.stats"+\
            " 2>> "+log_filename
f = open(log_filename, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)

bad_tags = 2820 # read_unmapped + not_primary_alignment + read_fails_platform/vendor_quality_checks + supplementary_alignment
command = "$(which time) samtools stats"+\
            " -@ "+str(snakemake.threads)+\
            " -F "+str(bad_tags)+\
            " "+snakemake.input.bam+\
            " > "+snakemake.params.prefix+".f4_suppl.stats"+\
            " 2>> "+log_filename
f = open(log_filename, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)


if hasattr(snakemake.input, 'bed'):
  command = "$(which time) samtools view"+\
            " -@ "+str(snakemake.threads)+\
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
  f = open(log_filename, 'at')
  f.write("## COMMAND: "+command+"\n")
  f.close()
  shell(command)

  command = "$(which time) samtools stats"+\
            " -@ "+str(snakemake.threads)+\
            " "+snakemake.output.bam+\
            " > "+snakemake.params.prefix+".f5_blcklst.stats"+\
            " 2>> "+log_filename
  f = open(log_filename, 'at')
  f.write("## COMMAND: "+command+"\n")
  f.close()
  shell(command)

else:
  command = "$(which time) samtools view"+\
            " -@ "+str(snakemake.threads)+\
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

## samtools view mapped/1_Input.bam | cut -f 5 | sort -n | uniq -c | awk '{print $2,$1}' OFS='\t'
