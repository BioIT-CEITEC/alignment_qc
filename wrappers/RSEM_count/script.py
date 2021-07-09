######################################
# wrapper for rule: gene_counts_RSEM
######################################
import os
import subprocess
from snakemake.shell import shell
shell.executable("/bin/bash")
log_filename = str(snakemake.log)



f = open(log_filename, 'a+')
f.write("\n##\n## RULE: gene_counts_RSEM \n##\n")
f.close()

version = str(subprocess.Popen("conda list 2>&1 | grep -i rsem",shell=True,stdout=subprocess.PIPE).communicate()[0], 'utf-8')
f = open(log_filename, 'at')
f.write("## VERSION: "+version+"\n")
f.close()

command = "mkdir -p "+os.path.dirname(snakemake.output.rsem_out)+" >> "+log_filename+" 2>&1"
f = open(log_filename, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)

if snakemake.params.paired == "PE" :
    extra_flags_rsem="--paired-end" # For RSEM
else:
    extra_flags_rsem = ""

if snakemake.params.strandness == "fwd":
    extra_flags_rsem += " --forward-prob 1"
elif snakemake.params.strandness == "rev":
    extra_flags_rsem += " --forward-prob 0"
else:
    extra_flags_rsem += " --forward-prob 0.5"
#--bam --estimate-rspd --calc-ci --seed $RSEM_RANDOM -p $THREADS --no-bam-output --ci-memory 30000 ${extra_flags_rsem} $i $SCRATCH/RSEM_index/$GEN_DIR $SCRATCH/gene_counts/rsem/${i%.*}.rsem

command = "samtools view "+str(snakemake.input.bam.replace(".bam",".transcriptome.bam"))+" | head -20 | wc -l"
mapped_count = str(subprocess.Popen(command,shell=True,stdout=subprocess.PIPE).communicate()[0], 'utf-8')
with open(log_filename, 'at') as f:
    f.write("## COMMAND: " + command + "\n")

if int(mapped_count) >= 20:
    command = "rsem-calculate-expression --bam --estimate-rspd --calc-ci --seed 12345 -p "+str(snakemake.threads)+" --no-bam-output --ci-memory "+str(snakemake.resources.mem)+"000 "+extra_flags_rsem \
                +" "+snakemake.input.bam.replace(".bam",".transcriptome.bam")+" "+snakemake.input.rsem_index.replace(".idx.fa","")+" "+snakemake.output.rsem_out.replace(".genes.results","")+" >> "+log_filename+" 2>&1 "

    f = open(log_filename, 'at')
    f.write("## COMMAND: "+command+"\n")
    f.close()
    shell(command)
else:
    command = "mkdir -p " + snakemake.output.rsem_out.replace(".genes.results",".stat")
    f = open(log_filename, 'at')
    f.write("## COMMAND: "+command+"\n")
    f.close()
    shell(command)
    command = "touch " + snakemake.output.rsem_out
    f = open(log_filename, 'at')
    f.write("## COMMAND: "+command+"\n")
    f.close()
    shell(command)
