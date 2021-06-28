######################################
# wrapper for rule: qc_picard_RNA
######################################
import os
import subprocess
from snakemake.shell import shell
shell.executable("/bin/bash")
log_filename = str(snakemake.log)

f = open(log_filename, 'a+')
f.write("\n##\n## RULE: qc_picard_RNA \n##\n")
f.close()

version = str(subprocess.Popen("picard CollectRnaSeqMetrics --version 2>&1",shell=True,stdout=subprocess.PIPE).communicate()[0], 'utf-8')
f = open(log_filename, 'at')
f.write("## VERSION: Picard "+version+"\n")
#
# command = "mkdir -p "+os.path.dirname(snakemake.output.picard_out)+" >> "+log_filename+" 2>&1"
# f = open(log_filename, 'at')
# f.write("## COMMAND: "+command+"\n")
# f.close()
# shell(command)

f = open(log_filename, 'at')
if snakemake.params.strandness == "fwd":
	extra_flags_picard="FIRST_READ_TRANSCRIPTION_STRAND"
	f.write("Running as forward stranded experiment \n")
elif snakemake.params.strandness == "rev":
	extra_flags_picard="SECOND_READ_TRANSCRIPTION_STRAND"
	f.write("Running as reverse stranded experiment \n")
else:
    extra_flags_picard="NONE"
    f.write("Running as unstranded experiment \n")
f.close()

command = "picard CollectRnaSeqMetrics -Xmx"+str(snakemake.resources.mem)+"g " \
        " I=" +snakemake.input.bam+ \
        " O=" +snakemake.output.picard_out+ \
        " REF_FLAT=" + snakemake.input.flat+ \
        " STRAND="+extra_flags_picard+ \
        " CHART="+snakemake.output.picard_out_pdf+ \
        " VALIDATION_STRINGENCY=LENIENT >> "+log_filename+" 2>&1"
f = open(log_filename, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)

if not os.path.exists(snakemake.output.picard_out_pdf):
	shell("touch " + snakemake.output.picard_out_pdf)
