######################################
# wrapper for rule: qc_dupradar_RNA
######################################
import os
import subprocess
from snakemake.shell import shell
import pdfkit
shell.executable("/bin/bash")
log_filename = str(snakemake.log)


DUP_RADAR = os.path.abspath(os.path.dirname(__file__)+"/dupRadar.R")
print(DUP_RADAR)


f = open(log_filename, 'a+')
f.write("\n##\n## RULE: qc_dupradar_RNA \n##\n")
f.close()

f = open(log_filename, 'at')
extra_flags_dupradar="single"
msg = "Running as single end"
if snakemake.params.pair == "PE":
  	extra_flags_dupradar="pair"
  	msg = "Running as paired end"
if snakemake.params.strandness == "fwd":
  	extra_flags_dupradar += " 1"
  	msg += " forward stranded experiment \n"
  	f.write(msg)
elif snakemake.params.strandness == "rev":
  	extra_flags_dupradar += " 2"
  	msg += " reverse stranded experiment \n"
  	f.write(msg)
else:
  	extra_flags_dupradar += " 0"
  	msg += " unstranded experiment \n"
  	f.write(msg)
f.close()

reads_thr = 20
mapped_count = str(subprocess.Popen("samtools view -F 4 "+str(snakemake.input.bam)+" | head -100 | wc -l",shell=True,stdout=subprocess.PIPE).communicate()[0], 'utf-8')
f = open(log_filename, 'at')
f.write("## Number of reads (min "+str(reads_thr)+"): "+str(mapped_count)+"\n")
f.close()

if int(mapped_count) >= reads_thr:
    command = "mkdir -p "+os.path.dirname(snakemake.output.dupraxpbox)+" >> "+log_filename+" 2>&1"
    f = open(log_filename, 'at')
    f.write("## COMMAND: "+command+"\n")
    f.close()
    shell(command)
    
    command ="Rscript "+ DUP_RADAR+" "+snakemake.input.bam+" "+snakemake.input.gtf+" "+extra_flags_dupradar+" "+os.path.dirname(snakemake.output.dupraxpbox)+" >> "+log_filename+" 2>&1"
    f = open(log_filename, 'at')
    f.write("## COMMAND: "+command+"\n")
    f.close()
    shell(command)

else:
  	f = open(log_filename, 'at')
  	f.write("## WARNING: Creating empty file ("+snakemake.output.dupraxpbox+") as input file ("+snakemake.input.bam+") doesn't contain enough mapped reads\n")
  	f.close()
  	pdfkit.from_string('Input file '+snakemake.input.bam+' doesn\'t contain enough mapped reads!', snakemake.output.dupraxpbox)
  	
  	f = open(log_filename, 'at')
  	f.write("## WARNING: Creating empty file ("+snakemake.output.exphist+") as input file ("+snakemake.input.bam+") doesn't contain enough mapped reads\n")
  	f.close()
  	pdfkit.from_string('Input file '+snakemake.input.bam+' doesn\'t contain enough mapped reads!', snakemake.output.exphist)
  	
  	f = open(log_filename, 'at')
  	f.write("## WARNING: Creating empty file ("+snakemake.output.dupraexpden+") as input file ("+snakemake.input.bam+") doesn't contain enough mapped reads\n")
  	f.close()
  	pdfkit.from_string('Input file '+snakemake.input.bam+' doesn\'t contain enough mapped reads!', snakemake.output.dupraexpden)
  	
  	f = open(log_filename, 'at')
  	f.write("## WARNING: Creating empty file ("+snakemake.output.multipergene+") as input file ("+snakemake.input.bam+") doesn't contain enough mapped reads\n")
  	f.close()
  	pdfkit.from_string('Input file '+snakemake.input.bam+' doesn\'t contain enough mapped reads!', snakemake.output.multipergene)
  	
  	f = open(log_filename, 'at')
  	f.write("## WARNING: Creating empty file ("+snakemake.output.readdist+") as input file ("+snakemake.input.bam+") doesn't contain enough mapped reads\n")
  	f.close()
  	pdfkit.from_string('Input file '+snakemake.input.bam+' doesn\'t contain enough mapped reads!', snakemake.output.readdist)
  	
  	command = "touch "+snakemake.output.txt+" >> "+log_filename+" 2>&1"
  	f = open(log_filename, 'at')
  	f.write("## WARNING: Creating empty file ("+snakemake.output.txt+") as input file ("+snakemake.input.bam+") doesn't contain enough mapped reads\n")
  	f.write("## COMMAND: "+command+"\n")
  	f.close()
  	shell(command)
