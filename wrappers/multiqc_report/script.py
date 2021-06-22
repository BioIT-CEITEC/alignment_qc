import subprocess
from snakemake.shell import shell
shell.executable("/bin/bash")
log_filename = str(snakemake.log)

f = open(log_filename, 'a+')
f.write("\n##\n## RULE: multiqc_report \n##\n")
f.close()

version = str(subprocess.Popen("echo $PATH 2>&1 ",shell=True,stdout=subprocess.PIPE).communicate()[0], 'utf-8')
f = open(log_filename, 'at')
f.write("## ECHO PATH: "+version+"\n")
f.close()

version = str(subprocess.Popen("conda list 2>&1 ",shell=True,stdout=subprocess.PIPE).communicate()[0], 'utf-8')
f = open(log_filename, 'at')
f.write("## CONDA LIST: "+version+"\n")
f.close()

version = str(subprocess.Popen("multiqc --version 2>&1 ",shell=True,stdout=subprocess.PIPE).communicate()[0], 'utf-8')
f = open(log_filename, 'at')
f.write("## VERSION: "+version+"\n")
f.close()

multiqc_search_paths = " /mnt/ssd/210615_alignment_qc_130/qc_reports/"+snakemake.wildcards.sample+ "/*/* /mnt/ssd/210615_alignment_qc_130/qc_reports/"+snakemake.wildcards.sample+"/*"

command = "multiqc -f --config " + snakemake.params.multiqc_config +" -n multiqc -o ./"+ snakemake.params.multiqc_path + multiqc_search_paths + " >> "+log_filename+" 2>&1 "
#command = "multiqc -f --config " + snakemake.params.multiqc_config +" -n multiqc" + multiqc_search_paths + " >> "+log_filename+" 2>&1 "
f = open(log_filename, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)
