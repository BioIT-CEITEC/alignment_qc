######################################
# wrapper for rule: merge_single_sample_reports
######################################
import os
import sys
import math
import subprocess
from snakemake.shell import shell

shell.executable("/bin/bash")
log_filename = str(snakemake.log)

f = open(log_filename, 'a+')
f.write("\n##\n## RULE: merge_single_sample_reports \n##\n")
f.close()

version = str(subprocess.Popen("conda list", shell=True, stdout=subprocess.PIPE).communicate()[0], 'utf-8')
f = open(log_filename, 'at')
f.write("## CONDA: "+version+"\n")
f.close()

#### from all samples, into one sample report

## qc_biotypes_RNA
if hasattr(snakemake.input, 'biotype'):
    biotype = [file for file in snakemake.input.biotype if os.stat(file).st_size != 0]
    command = "Rscript " + os.path.dirname(__file__) + "/biotypes.r" + " " + snakemake.output.biotype_pdf + " " +  " ".join(biotype)+" >> "+log_filename+" 2>&1"
    with open(log_filename, 'at') as f:
        f.write("## COMMAND: " + command + "\n")
    shell(command)
else:
    shell("touch " + snakemake.output.biotype_pdf)


## qc_fastq_screen_RNA
if hasattr(snakemake.input, 'fastq_screen'):
    command = "gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress -sOutputFile=" + str(snakemake.output.fastq_screen_pdf) + " " + str(snakemake.input.fastq_screen)+" >> "+log_filename+" 2>&1"
    with open(log_filename, 'at') as f:
        f.write("## COMMAND: " + command + "\n")
    shell(command)
else:
    shell("touch " + snakemake.output.fastq_screen_pdf)


## qc_dupradar_RNA
if hasattr(snakemake.input, 'dupraxpbox'):
    command = "gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress -sOutputFile=" + str(snakemake.output.dupraxpbox_pdf) + " " + str(snakemake.input.dupraxpbox)+" >> "+log_filename+" 2>&1"
    with open(log_filename, 'at') as f:
        f.write("## COMMAND: " + command + "\n")
    shell(command)
else:
    shell("touch " + snakemake.output.dupraxpbox_pdf)

if hasattr(snakemake.input, 'exphist'):
    command = "gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress -sOutputFile=" + str(snakemake.output.exphist_pdf) + " " + str(snakemake.input.exphist)+" >> "+log_filename+" 2>&1"
    with open(log_filename, 'at') as f:
        f.write("## COMMAND: " + command + "\n")
    shell(command)
else:
    shell("touch " + snakemake.output.exphist_pdf)

if hasattr(snakemake.input, 'dupraexpden'):
    command = "gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress -sOutputFile=" + str(snakemake.output.dupraexpden_pdf) + " " + str(snakemake.input.dupraexpden)+" >> "+log_filename+" 2>&1"
    with open(log_filename, 'at') as f:
        f.write("## COMMAND: " + command + "\n")
    shell(command)
else:
    shell("touch " + snakemake.output.dupraexpden_pdf)

if hasattr(snakemake.input, 'multipergene'):
    command = "gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress -sOutputFile=" + str(snakemake.output.multipergene_pdf) + " " + str(snakemake.input.multipergene)+" >> "+log_filename+" 2>&1"
    with open(log_filename, 'at') as f:
        f.write("## COMMAND: " + command + "\n")
    shell(command)
else:
    shell("touch " + snakemake.output.multipergene_pdf)

if hasattr(snakemake.input, 'readdist'):
    command = "gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress -sOutputFile=" + str(snakemake.output.readdist_pdf) + " " + str(snakemake.input.readdist)+" >> "+log_filename+" 2>&1"
    with open(log_filename, 'at') as f:
        f.write("## COMMAND: " + command + "\n")
    shell(command)
else:
    shell("touch " + snakemake.output.readdist_pdf)


## QC extra for ChIP-seq    
if hasattr(snakemake.input, 'phantompeak'):
    command = "gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress -sOutputFile="+snakemake.output.phantompeak_pdf+" "+str(snakemake.input.phantompeak)+" >> "+log_filename+" 2>&1"
    f = open(log_filename, 'at')
    f.write("## COMMAND: "+command+"\n")
    f.close()
    shell(command)
else:
    shell("touch " + snakemake.output.phantompeak_pdf)
    
if hasattr(snakemake.input, 'phantompeak_dups'):
    command = "gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress -sOutputFile="+snakemake.output.phantompeak_dups_pdf+" "+str(snakemake.input.phantompeak_dups)+" >> "+log_filename+" 2>&1"
    f = open(log_filename, 'at')
    f.write("## COMMAND: "+command+"\n")
    f.close()
    shell(command)
else:
    shell("touch " + snakemake.output.phantompeak_dups_pdf)

