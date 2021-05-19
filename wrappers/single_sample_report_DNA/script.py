######################################
# wrapper for rule: single_sample_report_DNA
######################################
import os
import sys
import subprocess
sys.path.append(os.path.abspath(os.path.dirname(__file__)+"/../../../scripts/"))
from supply import html_report
from supply import unfold_list
from snakemake.shell import shell

f = open(snakemake.log.run, 'a+')
f.write("\n##\n## RULE: single_sample_report_DNA \n##\n")
f.close()

TOOL = "multiqc"

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

version = str(subprocess.Popen(TOOL+" --version 2>&1 ",shell=True,stdout=subprocess.PIPE).communicate()[0], 'utf-8')
f = open(snakemake.log.run, 'at')
f.write("## VERSION: "+version+"\n")
f.close()

multiqc_search_paths = snakemake.params.run_dir + "/*/"+snakemake.wildcards.sample + "* " + snakemake.params.run_dir + "/*/*/"+snakemake.wildcards.sample+"*"

shell("mkdir -p " + os.path.dirname(snakemake.params.multiqc_html))
command = TOOL+" -f --config " + snakemake.params.multiqc_config + " -n "\
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



# OLD STUFF:
#     run:
#         shell(" {MULTIQC} -f -n {params.name} -b 'Return to <a href=\"../{wildcards.run_name}.final_report.html\">start page</a>' {params.prefix} > {log.run} 2>&1 ")
#         html_report('''
# ---
# title: Sample '''+wildcards.sample+''' report
# ---
#
# Overview report of workflow done for sample '''+wildcards.sample+'''.
#
# ### Report files:
#
# '''+
# unfold_list("* [1st FastQC report (for raw data)](../1st_qc/",input.fastqc_1st,")")+
# unfold_list("* [Alignment report](../mapped/",input.alignment,")")+
# unfold_list("* [Samtools stats](../map_qc/",input.samtools,")")+
# unfold_list("* [Picard report](../map_qc/",input.picard,")")+
# unfold_list("* [Alfred report](../map_qc/",input.alfred,")")+
# unfold_list("* [Qualimap report](../map_qc/",input.qualimap,")")+
# unfold_list("* [MultiQC report](",params.name,")")+
# '''\n
# ---
# Return to [start page](../'''+wildcards.run_name+'''.final_report.html)
# ''',output.html)
