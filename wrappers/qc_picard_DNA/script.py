######################################
# wrapper for rule: qc_picard_DNA
######################################
import os
import subprocess
from snakemake.shell import shell

f = open(snakemake.log.run, 'a+')
f.write("\n##\n## RULE: qc_picard_DNA \n##\n")
f.close()

shell.executable("/bin/bash")


if os.stat(snakemake.input.ilist).st_size != 0:

    version = str(subprocess.Popen("picard CollectHsMetrics --version 2>&1",shell=True,stdout=subprocess.PIPE).communicate()[0], 'utf-8')
    f = open(snakemake.log.run, 'at')
    f.write("## VERSION: Picard "+version+"\n")
    f.close()

    command = "picard -Xmx"+str(snakemake.resources.mem)+"g CollectHsMetrics I="+snakemake.input.bam+" O="+snakemake.output.table+" R="+str(snakemake.input.ref)+" BAIT_INTERVALS="+str(snakemake.input.ilist)+" \
PER_TARGET_COVERAGE="+snakemake.params.per_target+" TARGET_INTERVALS="+str(snakemake.input.ilist)+" VALIDATION_STRINGENCY=LENIENT 2>> "+snakemake.log.run+""
    f = open(snakemake.log.run, 'at')
    f.write("## COMMAND: "+command+"\n")
    f.close()
    shell(command)


else:
    # command = "touch " + snakemake.output.table
    # shell(command)
    version = str(subprocess.Popen("picard CollectWgsMetricsWithNonZeroCoverage --version 2>&1",shell=True,stdout=subprocess.PIPE).communicate()[0], 'utf-8')
    f = open(snakemake.log.run, 'at')
    f.write("## VERSION: Picard "+version+"\n")
    f.close()

    command = "picard -Xmx"+str(snakemake.resources.mem)+"g CollectWgsMetricsWithNonZeroCoverage I="+snakemake.input.bam+" \
O="+snakemake.output.table+" R="+str(snakemake.input.ref)+" CHART="+str(snakemake.params.wgs_chart)+" >> "+snakemake.log.run+" 2>&1"
    f = open(snakemake.log.run, 'at')
    f.write("## COMMAND: "+command+"\n")
    f.close()
    shell(command)
