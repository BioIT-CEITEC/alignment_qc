######################################
# wrapper for rule: qc_picard_DNA
######################################
import subprocess
from snakemake.shell import shell
shell.executable("/bin/bash")
log_filename = str(snakemake.log)

f = open(log_filename, 'wt')
f.write("\n##\n## RULE: qc_picard_DNA \n##\n")
f.close()

if snakemake.input.lib_ROI:
    version = str(subprocess.Popen("picard CollectHsMetrics --version 2>&1",shell=True,stdout=subprocess.PIPE).communicate()[0], 'utf-8')
    f = open(log_filename, 'at')
    f.write("## VERSION: Picard "+version+"\n")
    f.close()

    command = "picard -Xmx"+str(snakemake.resources.mem)+"g CollectHsMetrics -I "+snakemake.input.bam+" -O "+snakemake.output.table+" -R "+str(snakemake.input.ref)+" -BAIT_INTERVALS "+str(snakemake.input.lib_ROI)+" \
-PER_TARGET_COVERAGE "+snakemake.params.per_target+" -TARGET_INTERVALS "+str(snakemake.input.lib_ROI)+" -VALIDATION_STRINGENCY LENIENT 2>> "+log_filename+""

    f = open(log_filename, 'at')
    f.write("## COMMAND: "+command+"\n")
    f.close()
    shell(command)


else:
    version = str(subprocess.Popen("picard CollectWgsMetricsWithNonZeroCoverage --version 2>&1",shell=True,stdout=subprocess.PIPE).communicate()[0], 'utf-8')
    f = open(log_filename, 'at')
    f.write("## VERSION: Picard "+version+"\n")
    f.close()

    command = "picard -Xmx"+str(snakemake.resources.mem)+"g CollectWgsMetricsWithNonZeroCoverage -I "+snakemake.input.bam+" \
-O "+snakemake.output.table+" -R "+str(snakemake.input.ref)+" -CHART "+str(snakemake.params.wgs_chart)+" >> "+log_filename+" 2>&1"
    f = open(log_filename, 'at')
    f.write("## COMMAND: "+command+"\n")
    f.close()
    shell(command)
