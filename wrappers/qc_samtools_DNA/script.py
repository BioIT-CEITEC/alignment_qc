######################################
# wrapper for rule: qc_samtools_DNA
######################################
import subprocess
from snakemake.shell import shell

f = open(snakemake.log.run, 'a+')
f.write("\n##\n## RULE: qc_samtools_DNA \n##\n")
f.close()

shell.executable("/bin/bash")

version = str(subprocess.Popen("samtools --version 2>&1 | grep samtools", shell=True, stdout=subprocess.PIPE).communicate()[0], 'utf-8')
f = open(snakemake.log.run, 'at')
f.write("## VERSION: "+version+"\n")
f.close()

command = "samtools idxstats "+snakemake.input.bam+" > "+snakemake.output.idxstats+" 2>> "+snakemake.log.run+" "
f = open(snakemake.log.run, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)

command ="samtools flagstat "+snakemake.input.bam+" > "+snakemake.output.flagstats+" 2>> "+snakemake.log.run+" "
f = open(snakemake.log.run, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)
