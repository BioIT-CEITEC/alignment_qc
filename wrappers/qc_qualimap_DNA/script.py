######################################
# wrapper for rule: qc_qualimap_DNA
######################################
import os
import subprocess
from snakemake.shell import shell

f = open(snakemake.log.run, 'a+')
f.write("\n##\n## RULE: qc_qualimap_DNA \n##\n")
f.close()

TOOL = "qualimap"

shell.executable("/bin/bash")

version = str(subprocess.Popen(TOOL+" -v 2>&1 | grep QualiMap",shell=True,stdout=subprocess.PIPE).communicate()[0], 'utf-8')
f = open(snakemake.log.run, 'at')
f.write("## VERSION: "+version+"\n")
f.close()

command = "mkdir -p $(dirname "+snakemake.output.pdf+") >> "+snakemake.log.run+" 2>&1"
f = open(snakemake.log.run, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)

command = "bash -c unset DISPLAY >> "+snakemake.log.run+" 2>&1"
f = open(snakemake.log.run, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)

if os.stat(snakemake.input.bed).st_size != 0:
    command = TOOL+" bamqc -bam "+snakemake.input.bam+" -gff "+snakemake.input.bed+" -outdir "+snakemake.params.prefix+" -nt "+str(snakemake.threads)+" \
    --java-mem-size="+str(snakemake.resources.mem)+"G >> "+snakemake.log.run+" 2>&1"
else:
    command = TOOL+" bamqc -bam "+snakemake.input.bam+" -outdir "+snakemake.params.prefix+" -nt "+str(snakemake.threads)+" \
    --java-mem-size="+str(snakemake.resources.mem)+"G >> "+snakemake.log.run+" 2>&1"
f = open(snakemake.log.run, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)

command = "wkhtmltopdf "+ snakemake.params.html + " " + snakemake.output.pdf + " >> "+snakemake.log.run+" 2>&1"
f = open(snakemake.log.run, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)
