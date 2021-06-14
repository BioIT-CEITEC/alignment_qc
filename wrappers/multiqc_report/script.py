import os
import subprocess
from snakemake.shell import shell


f = open(snakemake.log.run, 'a+')
f.write("\n##\n## RULE: multiqc_report \n##\n")
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

multiqc_search_paths = snakemake.params.run_dir+"*/*/"+snakemake.params.sample_name+ "* "+snakemake.params.run_dir+"*/*/*/"+str(snakemake.params.sample_name)+"*"

shell("mkdir -p " + os.path.dirname(snakemake.params.multiqc_html))

command = "multiqc -f --config " + snakemake.params.multiqc_config + " -n "\
            +snakemake.params.multiqc_html+" -b 'Return to <a href=\"../"\
            +snakemake.params.lib_name+".final_report.html\">start page</a>' " + multiqc_search_paths + " >> "+snakemake.log.run+" 2>&1 "
f = open(snakemake.log.run, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)

