######################################
# wrapper for rule: qc_fastq_screen_RNA
######################################
import os
import subprocess
from snakemake.shell import shell
shell.executable("/bin/bash")
log_filename = str(snakemake.log)


f = open(log_filename, 'a+')
f.write("\n##\n## RULE: qc_fastq_screen_RNA \n##\n")
f.close()

read_count = str(subprocess.Popen("gunzip -c "+str(snakemake.input.fastq)+" | head -20 | wc -l",shell=True,stdout=subprocess.PIPE).communicate()[0], 'utf-8')

if sum(1 for line in open(snakemake.input.fastqscreen_conf)) == 0 or int(read_count) < 20:
  # there are no data to process so an empty plot is generated
  f = open(log_filename, 'at')
  f.write("## INFO: there are no data to process so a plot with a notice is generated\n")
  f.close()

  # it is important to create a text file (formated) so it can be converted into image. DO NOT remove empty lines without a reason!!
  command = """echo '





WARNING: There are no valid data to process, because of the missing rRNA and tRNA annotated sequences in the genome!








' > """ + snakemake.output.tmp_image + " 2>> " + log_filename
  f = open(log_filename, 'at')
  f.write("## COMMAND: "+command+"\n")
  f.close()
  shell(command)

  command = "fmt < " + snakemake.output.tmp_image + " | convert -size 1000x400 xc:white -font DejaVu-Sans-Mono -pointsize 20 -fill black -annotate +50+25 @- " + snakemake.output.fastqscreen + " >> " + log_filename + " 2>&1"
  f = open(log_filename, 'at')
  f.write("## COMMAND: "+command+"\n")
  f.close()
  shell(command)

else:
  version = str(subprocess.Popen("fastq_screen --version 2>&1", shell=True, stdout=subprocess.PIPE).communicate()[0], 'utf-8')
  f = open(log_filename, 'at')
  f.write("## VERSION: "+version+"\n")
  f.close()

  # version = str(subprocess.Popen("bowtie2 --version | grep 'bowtie2' 2>&1", shell=True, stdout=subprocess.PIPE).communicate()[0], 'utf-8')
  # f = open(log_filename, 'at')
  # f.write("## VERSION: "+version+"\n")
  # f.close()


  command = "mkdir -p "+os.path.dirname(snakemake.output.fastqscreen)+" >> "+log_filename+" 2>&1"
  f = open(log_filename, 'at')
  f.write("## COMMAND: "+command+"\n")
  f.close()
  shell(command)

  # Subset just 500k reads, to use all reads put there 0 2>&1"
  command = "fastq_screen --subset 500000 --outdir "+os.path.dirname(snakemake.output.fastqscreen) +" --threads " + str(snakemake.threads) + \
  	" --conf " + str(snakemake.input.fastqscreen_conf)+ " --nohits --aligner bowtie2 --force " + snakemake.input.fastq + " >> " + log_filename + " 2>&1"
  f = open(log_filename, 'at')
  f.write("## COMMAND: "+command+"\n")
  f.close()
  shell(command)