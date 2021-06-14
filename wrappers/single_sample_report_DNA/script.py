######################################
# wrapper for rule: single_sample_report_DNA
######################################
import os
import subprocess
from snakemake.shell import shell

f = open(snakemake.log.run, 'a+')
f.write("\n##\n## RULE: single_sample_report \n##\n")
f.close()

shell.executable("/bin/bash")

version = str(subprocess.Popen("echo $PATH 2>&1 ",shell=True,stdout=subprocess.PIPE).communicate()[0], 'utf-8')
f = open(snakemake.log.run, 'at')
f.write("## ECHO PATH: "+version+"\n")
f.close()

version = str(subprocess.Popen("conda list 2>&1 ",shell=True,stdout=subprocess.PIPE).communicate()[0], 'utf-8')
f = open(snakemake.log.run, 'at')
f.write("## CONDA LIST: "+version+"\n")
f.close()

version = str(subprocess.Popen("multiqc --version 2>&1 ",shell=True,stdout=subprocess.PIPE).communicate()[0], 'utf-8')
f = open(snakemake.log.run, 'at')
f.write("## VERSION: "+version+"\n")
f.close()

######## Multi QC for single sample reports
multiqc_search_paths = snakemake.params.run_dir + "alignment_qc/map_qc/*/* "  +snakemake.params.run_dir+ "alignment_qc/map_qc/*/*/* "+snakemake.params.run_dir+"raw_fastq_qc/raw_fastq_qc/* "

shell("mkdir -p " + os.path.dirname(snakemake.params.multiqc_html_single))
command = "multiqc -f --config " + snakemake.params.multiqc_config + " -n "\
            +snakemake.params.multiqc_html_single+" -b 'Return to <a href=\"../"\
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

######## Multi QC for all sample reports - not working yet

command = "multiqc -f --config " + snakemake.params.multiqc_config + " -n "\
        +snakemake.params.run_dir +"sample_final_reports/*.html -b 'Return to <a href=\"./"\
        +snakemake.params.lib_name+".final_report.html\">start page</a>' "+ snakemake.params.run_dir +" >> "+snakemake.log.run+" 2>&1"

f = open(snakemake.log.run, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)

#
# if not snakemake.input.raw_fastqc:
#     fastq_report_text = "Detailed raw fastq QC - (FastQC) - not available for merged BAMs"
# else:
#     fastq_report_text = unfold_list("* [Detailed raw fastq QC - (FastQC)](../raw_fastq_qc/",snakemake.input.raw_fastqc,")")
#
# html_report('''
# ---
# title: Sample '''+snakemake.wildcards.sample+''' report
# ---
#
# Overview report of workflow done for sample '''+snakemake.wildcards.sample+'''.
#
# ### Report files:
#
# '''+
# unfold_list("* [Main QC summary - (MultiQC)](",snakemake.params.multiqc_html,")")+
# unfold_list("* [Detailed mapping QC - (Qualimap)](../map_qc/qualimap/" + snakemake.wildcards.sample + "/",snakemake.input.qualimap,")")+
# fastq_report_text+
# '''\n
# ---
# Return to [start page](../'''+ snakemake.params.lib_name +'''.final_report.html)
# ''',snakemake.output.html)
