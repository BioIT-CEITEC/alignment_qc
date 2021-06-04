######################################
# wrapper for rule: snp_vaf_compute
######################################
import os
import subprocess
from snakemake.shell import shell


f = open(snakemake.log.run, 'a+')
f.write("\n##\n## RULE: snp_vaf_compute \n##\n")
f.close()


if os.stat(snakemake.input.snp_bed).st_size != 0:

    shell.executable("/bin/bash")

    version = str(subprocess.Popen("samtools --version 2>&1 | grep samtools",shell=True,stdout=subprocess.PIPE).communicate()[0], 'utf-8')
    f = open(snakemake.log.run, 'at')
    f.write("## VERSION: "+version+"\n")
    f.close()

    version = str(subprocess.Popen("bedtools --version 2>&1 ",shell=True,stdout=subprocess.PIPE).communicate()[0], 'utf-8')
    f = open(snakemake.log.run, 'at')
    f.write("## VERSION: "+version+"\n")
    f.close()

    if os.stat(snakemake.input.region_bed).st_size != 0:
        command = "bedtools intersect -a "+snakemake.input.snp_bed+" -b "+snakemake.input.region_bed+" > "+snakemake.params.intersect_bed+" 2>> "+snakemake.log.run
    else:
        command = " ln -s "+snakemake.input.snp_bed+" "+snakemake.params.intersect_bed+" >> "+snakemake.log.run+" 2>&1"
    f = open(snakemake.log.run, 'at')
    f.write("## COMMAND: "+command+"\n")
    f.close()
    shell(command)

    command = "samtools mpileup -v -A -u -t AD -f "+snakemake.input.ref+" --positions "+snakemake.params.intersect_bed+" "+snakemake.input.bam+" > "+snakemake.output.vcf+" 2>> "+snakemake.log.run
    f = open(snakemake.log.run, 'at')
    f.write("## COMMAND: "+command+"\n")
    f.close()
    shell(command)

    command = "rm "+snakemake.params.intersect_bed+" >> "+snakemake.log.run+" 2>&1"
    f = open(snakemake.log.run, 'at')
    f.write("## COMMAND: "+command+"\n")
    f.close()
    shell(command)

else:
    
    command = "touch "+snakemake.output.vcf
    f = open(snakemake.log.run, 'at')
    f.write("## COMMAND: "+command+"\n")
    f.close()
    shell(command)
