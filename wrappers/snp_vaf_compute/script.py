######################################
# wrapper for rule: snp_vaf_compute
######################################
import os
import subprocess
from snakemake.shell import shell
shell.executable("/bin/bash")
log_filename = str(snakemake.log)

f = open(log_filename, 'wt')
f.write("\n##\n## RULE: snp_vaf_compute \n##\n")
f.close()

version = str(subprocess.Popen("conda list ", shell=True, stdout=subprocess.PIPE).communicate()[0], 'utf-8')
f = open(log_filename, 'at')
f.write("## CONDA: "+version+"\n")
f.close()

if os.stat(snakemake.input.snp_bed).st_size != 0:

    #shell.executable("/bin/bash")

    if os.stat(snakemake.input.lib_ROI).st_size != 0:
        command = "bedtools intersect -a "+snakemake.input.snp_bed+" -b "+snakemake.input.lib_ROI+" > "+snakemake.params.intersect_bed+" 2>> "+log_filename
    else:
        command = " ln -s "+snakemake.input.snp_bed+" "+snakemake.params.intersect_bed+" >> "+log_filename+" 2>&1"
    f = open(log_filename, 'at')
    f.write("## COMMAND: "+command+"\n")
    f.close()
    shell(command)

    command = "samtools mpileup -v -A -u -t AD -f "+snakemake.input.ref+" --positions "+snakemake.params.intersect_bed+" "+snakemake.input.bam+" > "+snakemake.output.vcf+" 2>> "+log_filename
    f = open(log_filename, 'at')
    f.write("## COMMAND: "+command+"\n")
    f.close()
    shell(command)

    command = "rm "+snakemake.params.intersect_bed+" >> "+log_filename+" 2>&1"
    f = open(log_filename, 'at')
    f.write("## COMMAND: "+command+"\n")
    f.close()
    shell(command)

else:
    
    command = "touch "+snakemake.output.vcf
    f = open(log_filename, 'at')
    f.write("## COMMAND: "+command+"\n")
    f.close()
    shell(command)
