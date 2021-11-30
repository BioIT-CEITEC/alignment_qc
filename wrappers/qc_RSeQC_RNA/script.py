#####################################################
# wrapper for rule: qc_RSeQC_RNA
#####################################################
import os
import subprocess
from snakemake.shell import shell
shell.executable("/bin/bash")
log_filename = str(snakemake.log)


f = open(log_filename, 'a+')
f.write("\n##\n## RULE: qc_RSeQC_RNA \n##\n")
f.close()

version = str(subprocess.Popen("conda list ", shell=True, stdout=subprocess.PIPE).communicate()[0], 'utf-8')
f = open(log_filename, 'at')
f.write("## CONDA: "+version+"\n")
f.close()

command = "mkdir -p "+os.path.dirname(snakemake.output.read_distribution)+" >> "+log_filename+" 2>&1"
f = open(log_filename, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)


command = "samtools view "+str(snakemake.input.bam)+" | head -20 | wc -l"
with open(log_filename, 'at') as f:
    f.write("## COMMAND: " + command + "\n")
mapped_count = str(subprocess.Popen(command,shell=True,stdout=subprocess.PIPE).communicate()[0], 'utf-8')
f = open(log_filename, 'at')
f.write("## Number of reads (max 20): "+str(mapped_count)+"\n")
f.close()

if int(mapped_count) >= 20:

    command = "read_distribution.py -i "+snakemake.input.bam+" -r "+snakemake.input.bed+" > "+snakemake.output.read_distribution+" 2>> "+log_filename+" "
    f = open(log_filename, 'at')
    f.write("## COMMAND: "+command+"\n")
    f.close()
    shell(command)


    command = "infer_experiment.py -r "+snakemake.input.bed+" -i "+snakemake.input.bam+" > "+snakemake.output.infer_experiment+" 2>> "+log_filename+" "
    f = open(log_filename, 'at')
    f.write("## COMMAND: "+command+"\n")
    f.close()
    shell(command)


    command = "inner_distance.py -r "+snakemake.input.bed+" -i "+snakemake.input.bam+" -o "+snakemake.params.prefix+" &>> "+log_filename+" "
    f = open(log_filename, 'at')
    f.write("## COMMAND: "+command+"\n")
    f.close()
    shell(command)
else:
    command = "touch " + snakemake.output.read_distribution
    f = open(log_filename, 'at')
    f.write("## COMMAND: "+command+"\n")
    f.close()
    shell(command)
    command = "touch " + snakemake.output.infer_experiment
    f = open(log_filename, 'at')
    f.write("## COMMAND: "+command+"\n")
    f.close()
    shell(command)
    command = "touch " + snakemake.output.inner_distance
    f = open(log_filename, 'at')
    f.write("## COMMAND: "+command+"\n")
    f.close()
    shell(command)
