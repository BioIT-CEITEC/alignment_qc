######################################
# wrapper for rule: qc_fastq_screen_RNA
######################################
import os
import img2pdf
from PIL import Image
import subprocess
from snakemake.shell import shell
shell.executable("/bin/bash")
log_filename = str(snakemake.log)


f = open(log_filename, 'a+')
f.write("\n##\n## RULE: qc_fastq_screen_RNA \n##\n")
f.close()

version = str(subprocess.Popen("conda list ", shell=True, stdout=subprocess.PIPE).communicate()[0], 'utf-8')
f = open(log_filename, 'at')
f.write("## CONDA: "+version+"\n")
f.close()

### create fastq_screen.conf file
command = "echo 'THREADS " + str(snakemake.threads) + "' > " + snakemake.params.prefix + " 2>> " + log_filename
f = open(log_filename, 'at')
f.write("## COMMAND: " + command + "\n")
f.close()
shell(command)

command = "echo 'DATABASE " + str(snakemake.params.organism) + " " + str(snakemake.params.general_index) + "' >> " + str(snakemake.params.prefix) + " 2>> " + log_filename
f = open(log_filename, 'at')
f.write("## COMMAND: " + command + "\n")
f.close()
shell(command)

command = "echo 'DATABASE rRNA " + snakemake.params.rRNA_index + "' >> " + snakemake.params.prefix + " 2>> " + log_filename
f = open(log_filename, 'at')
f.write("## COMMAND: " + command + "\n")
f.close()
shell(command)

command = "echo 'DATABASE tRNA " + snakemake.params.tRNA_index + "' >> " + snakemake.params.prefix + " 2>> " + log_filename
f = open(log_filename, 'at')
f.write("## COMMAND: " + command + "\n")
f.close()
shell(command)


command = "gunzip -c "+str(snakemake.input.fastq)+" | head -20 | wc -l"
with open(log_filename, 'at') as f:
  f.write("## COMMAND: " + command + "\n")
read_count = str(subprocess.Popen(command,shell=True,stdout=subprocess.PIPE).communicate()[0], 'utf-8')

if sum(1 for line in open(snakemake.params.prefix)) == 0 or int(read_count) < 20:
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
  command = "mkdir -p "+os.path.dirname(snakemake.output.fastqscreen)+" >> "+log_filename+" 2>&1"
  f = open(log_filename, 'at')
  f.write("## COMMAND: "+command+"\n")
  f.close()
  shell(command)

  # Subset just 500k reads, to use all reads put there 0 2>&1"
  command = "fastq_screen --subset 500000 --threads " + str(snakemake.threads) + \
  	" --conf " +snakemake.params.prefix+ " --nohits --aligner bowtie2 --force " + snakemake.input.fastq + " >> " + log_filename + " 2>&1"
  f = open(log_filename, 'at')
  f.write("## COMMAND: "+command+"\n")
  f.close()
  shell(command)

  # mv results to output directory"
  command = "mv "+ os.path.basename(snakemake.input.fastq).replace(".fastq.gz","_screen*")+" "+  os.path.dirname(snakemake.output.fastqscreen) +"/"
  f = open(log_filename, 'at')
  f.write("## COMMAND: "+command+"\n")
  f.close()
  shell(command)

  # rm tmp files"
  command = "rm "+ os.path.basename(snakemake.input.fastq).replace(".fastq.gz",".tagged*")
  f = open(log_filename, 'at')
  f.write("## COMMAND: "+command+"\n")
  f.close()
  shell(command)


#### convert PNG to PDF in python
img_path = snakemake.output.fastqscreen
pdf_path = snakemake.output.fastqscreen_pdf

image = Image.open(img_path)
pdf_bytes = img2pdf.convert(image.filename)
file = open(pdf_path, "wb")
file.write(pdf_bytes)
image.close()
file.close()
