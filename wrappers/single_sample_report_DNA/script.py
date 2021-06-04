######################################
# wrapper for rule: single_sample_report_DNA
######################################
import os
import subprocess
from snakemake.shell import shell

f = open(snakemake.log.run, 'a+')
f.write("\n##\n## RULE: single_sample_report_DNA \n##\n")
f.close()

shell.executable("/bin/bash")

version = str(subprocess.Popen("echo $PATH 2>&1 ",shell=True,stdout=subprocess.PIPE).communicate()[0], 'utf-8')
f = open(snakemake.log.run, 'at')
f.write("## ECHO PATH: "+version+"\n")
f.close()

version = str(subprocess.Popen("which R 2>&1 ",shell=True,stdout=subprocess.PIPE).communicate()[0], 'utf-8')
f = open(snakemake.log.run, 'at')
f.write("## WHICH R: "+version+"\n")
f.close()

version = str(subprocess.Popen("conda list 2>&1 ",shell=True,stdout=subprocess.PIPE).communicate()[0], 'utf-8')
f = open(snakemake.log.run, 'at')
f.write("## CONDA LIST: "+version+"\n")
f.close()

version = str(subprocess.Popen("multiqc --version 2>&1 ",shell=True,stdout=subprocess.PIPE).communicate()[0], 'utf-8')
f = open(snakemake.log.run, 'at')
f.write("## VERSION: "+version+"\n")
f.close()

multiqc_search_paths = "./*/"+snakemake.wildcards.sample + "* " + "./*/*/"+snakemake.wildcards.sample+"*"

shell("mkdir -p " + os.path.dirname(snakemake.params.multiqc_html))
command = "multiqc -f --config " + os.path.dirname(__file__) + "/multiqc_config.txt -n "\
            +snakemake.params.multiqc_html+" -b 'Return to <a href=\"../"\
            +snakemake.params.lib_name+".final_report.html\">start page</a>' " + multiqc_search_paths + " >> "+snakemake.log.run+" 2>&1 "
f = open(snakemake.log.run, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)

f = open(snakemake.log.run, 'at')
command = "cat `ls -tr "+ os.path.dirname(snakemake.log.run) +"/*.log` > "+snakemake.output.whole_run_log
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)


def html_report(text,out_name):
    out_name = out_name.replace(".html",".Rmd")
    if os.path.isfile(out_name):
        os.remove(out_name)
    f = open(out_name,"w")
    f.write(text)
    f.close()

    command = "Rscript " + os.path.dirname(__file__) + "/render_markdown.R " + out_name
    subprocess.call(command, shell=True)


def unfold_list(str_start, what, str_end):
    if(isinstance(what,list)):
        return '\n'.join(map(lambda item: str_start+os.path.split(item)[1]+str_end, what))+'\n'
    else:
        return str_start+os.path.split(what)[1]+str_end+'\n'


if not snakemake.input.raw_fastqc:
    fastq_report_text = "Detailed raw fastq QC - (FastQC) - not available for merged BAMs"
else:
    fastq_report_text = unfold_list("* [Detailed raw fastq QC - (FastQC)](../raw_fastq_qc/",snakemake.input.raw_fastqc,")")

html_report('''
---
title: Sample '''+snakemake.wildcards.sample+''' report
---

Overview report of workflow done for sample '''+snakemake.wildcards.sample+'''.

### Report files:

'''+
unfold_list("* [Main QC summary - (MultiQC)](",snakemake.params.multiqc_html,")")+
unfold_list("* [Detailed mapping QC - (Qualimap)](../map_qc/qualimap/" + snakemake.wildcards.sample + "/",snakemake.input.qualimap,")")+
fastq_report_text+
'''\n
---
Return to [start page](../'''+ snakemake.params.lib_name +'''.final_report.html)
''',snakemake.output.html)
