######################################
# wrapper for rule: qc_biotypes_RNA
######################################
import os
import subprocess
from snakemake.shell import shell
shell.executable("/bin/bash")
log_filename = str(snakemake.log)



f = open(log_filename, 'a+')
f.write("\n##\n## RULE: qc_biotypes_RNA \n##\n")
f.close()

version = str(subprocess.Popen("featureCounts -v 2>&1 | grep featureCounts",shell=True,stdout=subprocess.PIPE).communicate()[0], 'utf-8')
f = open(log_filename, 'at')
f.write("## VERSION: "+version+"\n")
f.close()

command = "mkdir -p "+os.path.dirname(snakemake.output.txt)+" >> "+log_filename+" 2>&1"
f = open(log_filename, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)


f = open(log_filename, 'at')
extra_flags_feature=""
msg = "Running as single end"
if snakemake.params.paired == "PE":
	extra_flags_feature+="-p"
	msg = "Running as paired end"
if snakemake.params.strandness == "fwd":
	extra_flags_feature += " -s 1"
	msg += " forward stranded experiment \n"
	f.write(msg)
elif snakemake.params.strandness == "rev":
	extra_flags_feature += " -s 2"
	msg += " reverse stranded experiment \n"
	f.write(msg)
else:
	extra_flags_feature += " -s 0"
	msg += " unstranded experiment \n"
	f.write(msg)
f.close()


biotype = ''
biotype = str(subprocess.Popen("cat "+snakemake.input.gtf+" | grep -w 'biotype' > /dev/null && echo 'biotype' ",shell=True,stdout=subprocess.PIPE).communicate()[0], 'utf-8').rstrip(" \t\n")
if biotype == '':
	biotype = str(subprocess.Popen("cat "+snakemake.input.gtf+" | grep -w 'gene_biotype' > /dev/null && echo 'gene_biotype' ",shell=True,stdout=subprocess.PIPE).communicate()[0], 'utf-8').rstrip(" \t\n")
	f = open(log_filename, 'at')
	f.write("## GENE BIOTYPE TAG:"+biotype+"\n")
	f.close()

if biotype == '':
  command = "touch "+snakemake.output.txt+" 2>> "+log_filename
  f = open(log_filename, 'at')
  f.write("## COMMAND: "+command+"\n")
  f.close()
  shell(command)
else:
  # get all feature types (e.g., exon, gene, etc.) containing biotype information in 9th column of annotation file
  command = "cat "+snakemake.input.gtf+" | grep '"+biotype+"' | cut -f 3 | sort -u "
  with open(log_filename, 'at') as f:
      f.write("## COMMAND: " + command + "\n")
  featuretype_list = str(subprocess.Popen(command,shell=True,stdout=subprocess.PIPE).communicate()[0], 'utf-8').split("\n")
  print(featuretype_list)
  # check if prefered featuretype in count_over is in the list so it can be used
  featuretype = snakemake.params.count_over
  if not featuretype in featuretype_list:
    if featuretype == "exon":
      featuretype = ""
    elif featuretype == "gene": 
      if "transcript" in featuretype_list:
        featuretype = "transcript"
      elif "mRNA" in featuretype_list:
        featuretype = "mRNA"
      else:
        featuretype = ""
    else:
      featuretype = ""

  f = open(log_filename, 'at')
  f.write("## BIOTYPE FEATURE:"+featuretype+"\n")
  f.close()
  
  if featuretype == "":
    command = "touch "+snakemake.output.txt+" 2>> "+log_filename
    f = open(log_filename, 'at')
    f.write("## COMMAND: "+command+"\n")
    f.close()
    shell(command)
    
  else:
    command = "featureCounts -t "+featuretype+" -g "+biotype+" -O -M --fraction "+extra_flags_feature+" -T "+str(snakemake.threads)+" -a "+snakemake.input.gtf+" -o "+snakemake.params.prefix+" "+snakemake.input.bam+" >> "+log_filename+" 2>&1 "
    f = open(log_filename, 'at')
    f.write("## COMMAND: "+command+"\n")
    f.close()
    shell(command)
  
    command = "cut -f 1,7- "+snakemake.params.prefix+" > "+snakemake.output.txt+" 2>> "+log_filename
    f = open(log_filename, 'at')
    f.write("## COMMAND: "+command+"\n")
    f.close()
    shell(command)


if os.stat(snakemake.output.txt).st_size != 0:
    # there are no data to process so an empty plot is generated
    command = "Rscript " + os.path.dirname(__file__) + "/biotypes.r" + " " + snakemake.output.pdf + " " + str(snakemake.output.txt)
    with open(log_filename, 'at') as f:
        f.write("## COMMAND: " + command + "\n")
    shell(command)
else:
    command = "echo \"WARNING: there are no Biotype data to process so a plot with a notice is generated.\n\" > " + snakemake.output.pdf + " 2>> " + log_filename
    f = open(log_filename, 'at')
    f.write("## COMMAND: "+command+"\n")
    f.close()
    shell(command)