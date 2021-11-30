######################################
# wrapper for rule: qc_qualimap_RNA
######################################
import os
import subprocess
from snakemake.shell import shell
shell.executable("/bin/bash")
log_filename = str(snakemake.log)


f = open(log_filename, 'a+')
f.write("\n##\n## RULE: qc_qualimap_RNA \n##\n")
f.close()

version = str(subprocess.Popen("conda list ", shell=True, stdout=subprocess.PIPE).communicate()[0], 'utf-8')
f = open(log_filename, 'at')
f.write("## CONDA: "+version+"\n")
f.close()


f = open(log_filename, 'at')
extra_flags_qualimap=""
msg = "Running as single end"
if snakemake.params.paired == "PE":
	extra_flags_qualimap+=" --paired"
	msg = "Running as paired end"
if snakemake.params.strandness == "fwd":
	extra_flags_qualimap += " --sequencing-protocol strand-specific-forward"
	msg += " forward stranded experiment \n"
	f.write(msg)
elif snakemake.params.strandness == "rev":
	extra_flags_qualimap += " --sequencing-protocol strand-specific-reverse"
	msg += " reverse stranded experiment \n"
	f.write(msg)
else:
	extra_flags_qualimap += " --sequencing-protocol non-strand-specific"
	msg += " unstranded experiment \n"
	f.write(msg)
f.close()


command = "mkdir -p $(dirname "+snakemake.output.html+") >> "+log_filename+" 2>&1"
f = open(log_filename, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)

command = "bash -c unset DISPLAY >> "+log_filename+" 2>&1"
f = open(log_filename, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)

command = "samtools view -F 4 "+str(snakemake.input.bam)+" | head -20 | wc -l"
with open(log_filename, 'at') as f:
	f.write("## COMMAND: " + command + "\n")
mapped_count = str(subprocess.Popen(command,shell=True,stdout=subprocess.PIPE).communicate()[0], 'utf-8')
f = open(log_filename, 'at')
f.write("## Number of reads (max 20): "+str(mapped_count)+"\n")
f.close()

if int(mapped_count) >= 20:
	if os.stat(snakemake.input.gtf).st_size != 0:
		params = " -gtf " +snakemake.input.gtf
	else:
		params = ""

	command = "export JAVA_OPTS='-Djava.io.tmpdir=/tmp/ -Xmx24G' && qualimap rnaseq -bam " + snakemake.input.bam + params + extra_flags_qualimap + " -outdir " + os.path.dirname(snakemake.output.html) + " >> " + log_filename + " 2>&1"
	f = open(log_filename, 'at')
	f.write("## COMMAND: "+command+"\n")
	f.close()
	shell(command)
else:
	command = "touch " + snakemake.output.html+" >> "+log_filename+" 2>&1"
	f = open(log_filename, 'at')
	f.write("## COMMAND: "+command+"\n")
	f.close()
	shell(command)
