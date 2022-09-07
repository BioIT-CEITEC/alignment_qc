######################################
# wrapper for rule: qc_picard_DNA_wgs_chart
######################################
import subprocess
from snakemake.shell import shell
shell.executable("/bin/bash")
log_filename = str(snakemake.log)

f = open(log_filename, 'wt')
f.write("\n##\n## RULE: qc_picard_DNA \n##\n")
f.close()

version = str(subprocess.Popen("conda list ", shell=True, stdout=subprocess.PIPE).communicate()[0], 'utf-8')
f = open(log_filename, 'at')
f.write("## CONDA: "+version+"\n")
f.close()


command = "picard -Xmx"+str(snakemake.resources.mem)+"g CollectWgsMetricsWithNonZeroCoverage -I "+snakemake.input.bam+" \
-O "+snakemake.output.table+" -R "+str(snakemake.input.ref)+" -CHART "+snakemake.output.metrics+" >> "+log_filename+" 2>&1"
f = open(log_filename, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)