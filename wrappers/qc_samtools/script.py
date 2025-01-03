######################################
# wrapper for rule: qc_samtools
######################################
import subprocess
from snakemake.shell import shell
shell.executable("/bin/bash")
log_filename = str(snakemake.log)

f = open(log_filename, 'wt')
f.write("\n##\n## RULE: qc_samtools \n##\n")
f.close()

version = str(subprocess.Popen("conda list 2>&1", shell=True, stdout=subprocess.PIPE).communicate()[0], 'utf-8')
f = open(log_filename, 'at')
f.write("## CONDA:\n"+version+"\n")
f.close()


command = "$(which time) samtools idxstats "+snakemake.input.bam+" > "+snakemake.output.idxstats+" 2>> "+log_filename+" "
f = open(log_filename, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)

command ="$(which time) samtools flagstat "+snakemake.input.bam+" > "+snakemake.output.flagstats+" 2>> "+log_filename+" "
f = open(log_filename, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)

command ="$(which time) samtools stats "+snakemake.input.bam+" > "+snakemake.output.stats+" 2>> "+log_filename+" "
f = open(log_filename, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)
