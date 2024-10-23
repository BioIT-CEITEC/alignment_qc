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

# write python code to check if the string "Log.final.out" is in snakemake.input

if snakemake.input[0].find("Log.final.out") != -1:
    star_aln = " ./mapped/*/*_STARgenome/*"
else:
    star_aln = ""

if snakemake.wildcards.sample != "all_samples":
    multiqc_search_paths = " ./*/"+snakemake.wildcards.sample+"/"
else:
    multiqc_search_paths = star_aln + " ./qc_reports/*/*" + " ./mapped/*"


command = "multiqc -f --config " + snakemake.params.multiqc_config +" -n multiqc -o ./"+ snakemake.params.multiqc_path + multiqc_search_paths + " >> "+log_filename+" 2>&1 "

f = open(log_filename, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)
