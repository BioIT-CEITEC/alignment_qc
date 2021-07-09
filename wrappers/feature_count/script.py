######################################
# wrapper for rule: gene_counts_featureCounts
######################################
import os
import subprocess
from snakemake.shell import shell
shell.executable("/bin/bash")
log_filename = str(snakemake.log)



f = open(log_filename, 'a+')
f.write("\n##\n## RULE: gene_counts_featureCounts \n##\n")
f.close()

version = str(subprocess.Popen("featureCounts -v 2>&1 | grep featureCounts",shell=True,stdout=subprocess.PIPE).communicate()[0], 'utf-8')
f = open(log_filename, 'at')
f.write("## VERSION: "+version+"\n")
f.close()

command = "mkdir -p "+os.path.dirname(snakemake.output.feature_out)+" >> "+log_filename+" 2>&1"
f = open(log_filename, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)

if snakemake.params.paired == "PE" :
    extra_flags_feature = " -p -P -C" # For featureCounts; -B
else:
    extra_flags_feature = ""

if snakemake.params.strandness == "fwd":
    extra_flags_feature += " -s 1"
elif snakemake.params.strandness == "rev":
    extra_flags_feature += " -s 2"
else:
    extra_flags_feature += " -s 0"

command = "featureCounts -t "+snakemake.params.count_over+" -g gene_id "+extra_flags_feature+" -T "+str(snakemake.threads)+" -F GTF -Q 0 -d 1 -D 25000 -a " + \
            snakemake.input.gtf+" -o "+snakemake.output.feature_out+" "+snakemake.input.bam+" >> "+log_filename+" 2>&1 "
f = open(log_filename, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)