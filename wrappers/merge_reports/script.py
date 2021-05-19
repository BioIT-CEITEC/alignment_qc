######################################
# wrapper for rule: merge_reports
######################################
import os
import sys
import math
import re
import subprocess
sys.path.append(os.path.abspath(os.path.dirname(__file__)+"/../../../scripts/"))
from supply import html_report
from supply import unfold_list
from snakemake.shell import shell

TOOL = "multiqc"

shell.executable("/bin/bash")

version = str(subprocess.Popen(TOOL+" --version 2>&1 ",shell=True,stdout=subprocess.PIPE).communicate()[0], 'utf-8')
f = open(snakemake.log.run, 'a+')
f.write("## VERSION: "+version+"\n")
f.close()

command = TOOL+" -f --config " + snakemake.params.multiqc_config + " -n "\
        +snakemake.params.multiqc_html+" -b 'Return to <a href=\"./"\
        +snakemake.params.lib_name+".final_report.html\">start page</a>' "+ snakemake.params.prefix +" >> "+snakemake.log.run+" 2>&1"

f = open(snakemake.log.run, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)

samples = [re.sub(r'.*sample_final_reports\/(.*).final_report.html', r'\1', i) for i in list(snakemake.input.html)]


if not snakemake.input.cross_html:
    cross_html_report_text = ""
else:
    cross_html_report_text = unfold_list("* [Cross sample correllation heatmap](map_qc/cross_sample_correlation/",snakemake.input.cross_html,")")


html_report('''
---
title: Final report (for run_name '''+snakemake.params.lib_name+''')
---

### Main report:

'''+
unfold_list("* [Multi-sample main QC summary (MultiQC)](",snakemake.params.multiqc_html,")")+
cross_html_report_text+
'''

---

### Individual samples reports:

'''+
'\n'.join(map(lambda index,item: '* [Sample '+item+' report](sample_final_reports/'+os.path.split(snakemake.input[index])[1]+')', range(len(samples)), samples))+'\n'+
'''

''',snakemake.output.html)

for html_file in list(snakemake.input.html):
     bam_file = re.sub(r'sample_final_reports\/(.*).final_sample_report.html', r'mapped/\1.bam', html_file)

     command = "samtools index " + bam_file
     f = open(snakemake.log.run, 'at')
     f.write("## COMMAND: "+command+"\n")
     f.close()
     shell(command)
