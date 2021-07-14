######################################
# wrapper for rule: merge_single_sample_reports
######################################
import os
from snakemake.shell import shell
shell.executable("/bin/bash")
log_filename = str(snakemake.log)


#### from all samples, into one sample report

## qc_biotypes_RNA
if snakemake.input.biotype:
    biotype = [file for file in snakemake.input.biotype if os.stat(file).st_size != 0]
    command = "Rscript " + os.path.dirname(__file__) + "/biotypes.r" + " " + snakemake.output.biotype_pdf + " " +  " ".join(biotype)
    with open(log_filename, 'at') as f:
        f.write("## COMMAND: " + command + "\n")
    shell(command)
else:
    shell("touch " + snakemake.output.biotype_pdf)


## qc_fastq_screen_RNA
if snakemake.input.fastq_screen:
    command = "gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress -sOutputFile=" + str(snakemake.output.fastq_screen_pdf) + " " + str(snakemake.input.fastq_screen)
    with open(log_filename, 'at') as f:
        f.write("## COMMAND: " + command + "\n")
    shell(command)
else:
    shell("touch " + snakemake.output.fastq_screen_pdf)


## qc_dupradar_RNA
if snakemake.input.dupraxpbox:
    command = "gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress -sOutputFile=" + str(snakemake.output.dupraxpbox_pdf) + " " + str(snakemake.input.dupraxpbox)
    with open(log_filename, 'at') as f:
        f.write("## COMMAND: " + command + "\n")
    shell(command)
else:
    shell("touch " + snakemake.output.dupraxpbox_pdf)

if snakemake.input.exphist:
    command = "gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress -sOutputFile=" + str(snakemake.output.exphist_pdf) + " " + str(snakemake.input.exphist)
    with open(log_filename, 'at') as f:
        f.write("## COMMAND: " + command + "\n")
    shell(command)
else:
    shell("touch " + snakemake.output.exphist_pdf)

if snakemake.input.dupraexpden:
    command = "gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress -sOutputFile=" + str(snakemake.output.dupraexpden_pdf) + " " + str(snakemake.input.dupraexpden)
    with open(log_filename, 'at') as f:
        f.write("## COMMAND: " + command + "\n")
    shell(command)
else:
    shell("touch " + snakemake.output.dupraexpden_pdf)

if snakemake.input.multipergene:
    command = "gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress -sOutputFile=" + str(snakemake.output.multipergene_pdf) + " " + str(snakemake.input.multipergene)
    with open(log_filename, 'at') as f:
        f.write("## COMMAND: " + command + "\n")
    shell(command)
else:
    shell("touch " + snakemake.output.multipergene_pdf)

if snakemake.input.readdist:
    command = "gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress -sOutputFile=" + str(snakemake.output.readdist_pdf) + " " + str(snakemake.input.readdist)
    with open(log_filename, 'at') as f:
        f.write("## COMMAND: " + command + "\n")
    shell(command)
else:
    shell("touch " + snakemake.output.readdist_pdf)